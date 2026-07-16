package worker

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"image"
	"image/png"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

// CommandRunner runs external codec tools with an argument vector (no shell).
// Tests inject fakes so unit suites never depend on a local ffmpeg/cwebp binary.
type CommandRunner interface {
	Run(ctx context.Context, name string, args []string, stdin []byte) (stdout []byte, stderr []byte, err error)
}

// ExecCommandRunner invokes real OS binaries through exec.CommandContext.
type ExecCommandRunner struct{}

func (ExecCommandRunner) Run(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
	if strings.TrimSpace(name) == "" {
		return nil, nil, errors.New("command name is empty")
	}
	cmd := exec.CommandContext(ctx, name, args...)
	if len(stdin) > 0 {
		cmd.Stdin = bytes.NewReader(stdin)
	}
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		if errors.Is(ctx.Err(), context.DeadlineExceeded) {
			return stdout.Bytes(), stderr.Bytes(), fmt.Errorf("command %s timed out: %w", name, context.DeadlineExceeded)
		}
		if errors.Is(ctx.Err(), context.Canceled) {
			return stdout.Bytes(), stderr.Bytes(), fmt.Errorf("command %s canceled: %w", name, context.Canceled)
		}
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) {
			detail := strings.TrimSpace(stderr.String())
			if detail == "" {
				detail = err.Error()
			}
			return stdout.Bytes(), stderr.Bytes(), fmt.Errorf("command %s failed: %s", name, detail)
		}
		if errors.Is(err, exec.ErrNotFound) || isPathErrorNotFound(err) {
			return stdout.Bytes(), stderr.Bytes(), fmt.Errorf("%w: %s", ErrCodecUnavailable, name)
		}
		return stdout.Bytes(), stderr.Bytes(), fmt.Errorf("command %s: %w", name, err)
	}
	return stdout.Bytes(), stderr.Bytes(), nil
}

func isPathErrorNotFound(err error) bool {
	var pathErr *os.PathError
	return errors.As(err, &pathErr) && errors.Is(pathErr.Err, os.ErrNotExist)
}

// CodecConfig injects external tool paths, timeouts and size guards.
type CodecConfig struct {
	CWebPPath       string
	FFmpegPath      string
	FFprobePath     string
	Timeout         time.Duration
	MaxInputBytes   int64
	MaxOutputBytes  int64
	WebPQuality     int
	VideoCRF        int
	VideoPreset     string
	VideoMaxWidth   int
	VideoMaxHeight  int
	TempDir         string
	LookPath        func(file string) (string, error)
	Runner          CommandRunner
}

// DefaultCodecConfig returns production-oriented defaults. Paths may still be
// overridden via environment variables at process startup.
func DefaultCodecConfig() CodecConfig {
	return CodecConfig{
		CWebPPath:      "cwebp",
		FFmpegPath:     "ffmpeg",
		FFprobePath:    "ffprobe",
		Timeout:        2 * time.Minute,
		MaxInputBytes:  512 << 20,
		MaxOutputBytes: 512 << 20,
		WebPQuality:    80,
		VideoCRF:       23,
		VideoPreset:    "veryfast",
		VideoMaxWidth:  1920,
		VideoMaxHeight: 1080,
		LookPath:       exec.LookPath,
		Runner:         ExecCommandRunner{},
	}
}

// ErrCodecUnavailable signals that a required external encoder is missing.
var ErrCodecUnavailable = errors.New("media codec unavailable")

// WebPEncoder encodes images to WebP. Implementations may call cwebp or a test fake.
type WebPEncoder interface {
	Encode(ctx context.Context, img image.Image, quality int) ([]byte, error)
}

// VideoProbe holds container-level facts extracted by ffprobe.
type VideoProbe struct {
	Width      int
	Height     int
	DurationMS int64
	CodecName  string
	FormatName string
}

// VideoTranscodeResult is a derived video object ready for ObjectStore.Put.
type VideoTranscodeResult struct {
	Body        []byte
	ContentType string
	Width       int
	Height      int
	DurationMS  int64
	Codec       string
}

// VideoTranscoder materializes a deterministic H.264/AAC MP4 derivative.
type VideoTranscoder interface {
	Probe(ctx context.Context, source []byte) (VideoProbe, error)
	Transcode(ctx context.Context, source []byte) (VideoTranscodeResult, error)
}

// ExternalCodec implements WebPEncoder and VideoTranscoder via CLI tools.
type ExternalCodec struct {
	Config CodecConfig
}

func NewExternalCodec(config CodecConfig) *ExternalCodec {
	defaults := DefaultCodecConfig()
	if strings.TrimSpace(config.CWebPPath) == "" {
		config.CWebPPath = defaults.CWebPPath
	}
	if strings.TrimSpace(config.FFmpegPath) == "" {
		config.FFmpegPath = defaults.FFmpegPath
	}
	if strings.TrimSpace(config.FFprobePath) == "" {
		config.FFprobePath = defaults.FFprobePath
	}
	if config.Timeout <= 0 {
		config.Timeout = defaults.Timeout
	}
	if config.MaxInputBytes <= 0 {
		config.MaxInputBytes = defaults.MaxInputBytes
	}
	if config.MaxOutputBytes <= 0 {
		config.MaxOutputBytes = defaults.MaxOutputBytes
	}
	if config.WebPQuality <= 0 {
		config.WebPQuality = defaults.WebPQuality
	}
	if config.VideoCRF <= 0 {
		config.VideoCRF = defaults.VideoCRF
	}
	if strings.TrimSpace(config.VideoPreset) == "" {
		config.VideoPreset = defaults.VideoPreset
	}
	if config.VideoMaxWidth <= 0 {
		config.VideoMaxWidth = defaults.VideoMaxWidth
	}
	if config.VideoMaxHeight <= 0 {
		config.VideoMaxHeight = defaults.VideoMaxHeight
	}
	if config.LookPath == nil {
		config.LookPath = defaults.LookPath
	}
	if config.Runner == nil {
		config.Runner = defaults.Runner
	}
	return &ExternalCodec{Config: config}
}

func (c *ExternalCodec) resolve(path string) (string, error) {
	path = strings.TrimSpace(path)
	if path == "" {
		return "", ErrCodecUnavailable
	}
	// Absolute paths are used as-is so tests can inject fake command names
	// without creating real files. Existence is enforced when the runner executes.
	if filepath.IsAbs(path) {
		return path, nil
	}
	if c.Config.LookPath == nil {
		return "", fmt.Errorf("%w: %s", ErrCodecUnavailable, path)
	}
	resolved, err := c.Config.LookPath(path)
	if err != nil {
		return "", fmt.Errorf("%w: %s", ErrCodecUnavailable, path)
	}
	return resolved, nil
}

func (c *ExternalCodec) withTimeout(parent context.Context) (context.Context, context.CancelFunc) {
	if parent == nil {
		parent = context.Background()
	}
	if _, ok := parent.Deadline(); ok {
		return context.WithCancel(parent)
	}
	return context.WithTimeout(parent, c.Config.Timeout)
}

func (c *ExternalCodec) Encode(ctx context.Context, img image.Image, quality int) ([]byte, error) {
	if img == nil {
		return nil, errors.New("webp encode: image is nil")
	}
	if quality <= 0 {
		quality = c.Config.WebPQuality
	}
	if quality > 100 {
		quality = 100
	}
	binary, err := c.resolve(c.Config.CWebPPath)
	if err != nil {
		return nil, err
	}
	var pngBody bytes.Buffer
	if err := png.Encode(&pngBody, img); err != nil {
		return nil, fmt.Errorf("webp encode: png intermediate: %w", err)
	}
	if int64(pngBody.Len()) > c.Config.MaxInputBytes {
		return nil, fmt.Errorf("webp encode: intermediate exceeds max input bytes (%d)", c.Config.MaxInputBytes)
	}
	runCtx, cancel := c.withTimeout(ctx)
	defer cancel()
	// cwebp reads PNG from stdin when - is used as input.
	stdout, stderr, err := c.Config.Runner.Run(runCtx, binary, []string{
		"-quiet",
		"-q", strconv.Itoa(quality),
		"-o", "-",
		"--", "-",
	}, pngBody.Bytes())
	if err != nil {
		if errors.Is(err, ErrCodecUnavailable) || errors.Is(err, context.DeadlineExceeded) {
			return nil, err
		}
		detail := strings.TrimSpace(string(stderr))
		if detail == "" {
			detail = err.Error()
		}
		return nil, fmt.Errorf("webp encode failed: %s", detail)
	}
	if len(stdout) == 0 {
		return nil, errors.New("webp encode produced empty output")
	}
	if int64(len(stdout)) > c.Config.MaxOutputBytes {
		return nil, fmt.Errorf("webp encode: output exceeds max bytes (%d)", c.Config.MaxOutputBytes)
	}
	return stdout, nil
}

func (c *ExternalCodec) Probe(ctx context.Context, source []byte) (VideoProbe, error) {
	if len(source) == 0 {
		return VideoProbe{}, errors.New("ffprobe: empty source")
	}
	if int64(len(source)) > c.Config.MaxInputBytes {
		return VideoProbe{}, fmt.Errorf("ffprobe: source exceeds max input bytes (%d)", c.Config.MaxInputBytes)
	}
	binary, err := c.resolve(c.Config.FFprobePath)
	if err != nil {
		return VideoProbe{}, err
	}
	inputPath, cleanup, err := c.writeTemp("source-*.bin", source)
	if err != nil {
		return VideoProbe{}, err
	}
	defer cleanup()

	runCtx, cancel := c.withTimeout(ctx)
	defer cancel()
	stdout, stderr, err := c.Config.Runner.Run(runCtx, binary, []string{
		"-v", "error",
		"-print_format", "json",
		"-show_format",
		"-show_streams",
		inputPath,
	}, nil)
	if err != nil {
		if errors.Is(err, ErrCodecUnavailable) || errors.Is(err, context.DeadlineExceeded) {
			return VideoProbe{}, err
		}
		detail := strings.TrimSpace(string(stderr))
		if detail == "" {
			detail = err.Error()
		}
		return VideoProbe{}, fmt.Errorf("ffprobe failed: %s", detail)
	}
	return parseFFProbeJSON(stdout)
}

func (c *ExternalCodec) Transcode(ctx context.Context, source []byte) (VideoTranscodeResult, error) {
	if len(source) == 0 {
		return VideoTranscodeResult{}, errors.New("ffmpeg: empty source")
	}
	if int64(len(source)) > c.Config.MaxInputBytes {
		return VideoTranscodeResult{}, fmt.Errorf("ffmpeg: source exceeds max input bytes (%d)", c.Config.MaxInputBytes)
	}
	binary, err := c.resolve(c.Config.FFmpegPath)
	if err != nil {
		return VideoTranscodeResult{}, err
	}
	probe, err := c.Probe(ctx, source)
	if err != nil {
		return VideoTranscodeResult{}, err
	}
	inputPath, cleanupIn, err := c.writeTemp("source-*.bin", source)
	if err != nil {
		return VideoTranscodeResult{}, err
	}
	defer cleanupIn()
	outputPath, cleanupOut, err := c.tempPath("transcode-*.mp4")
	if err != nil {
		return VideoTranscodeResult{}, err
	}
	defer cleanupOut()

	scaleFilter := fmt.Sprintf(
		"scale='min(%d,iw)':'min(%d,ih)':force_original_aspect_ratio=decrease",
		c.Config.VideoMaxWidth, c.Config.VideoMaxHeight,
	)
	args := []string{
		"-y",
		"-hide_banner",
		"-loglevel", "error",
		"-i", inputPath,
		"-vf", scaleFilter,
		"-c:v", "libx264",
		"-preset", c.Config.VideoPreset,
		"-crf", strconv.Itoa(c.Config.VideoCRF),
		"-pix_fmt", "yuv420p",
		"-c:a", "aac",
		"-b:a", "128k",
		"-movflags", "+faststart",
		outputPath,
	}
	runCtx, cancel := c.withTimeout(ctx)
	defer cancel()
	_, stderr, err := c.Config.Runner.Run(runCtx, binary, args, nil)
	if err != nil {
		if errors.Is(err, ErrCodecUnavailable) || errors.Is(err, context.DeadlineExceeded) {
			return VideoTranscodeResult{}, err
		}
		detail := strings.TrimSpace(string(stderr))
		if detail == "" {
			detail = err.Error()
		}
		return VideoTranscodeResult{}, fmt.Errorf("ffmpeg transcode failed: %s", detail)
	}
	body, err := os.ReadFile(outputPath)
	if err != nil {
		return VideoTranscodeResult{}, fmt.Errorf("ffmpeg: read output: %w", err)
	}
	if len(body) == 0 {
		return VideoTranscodeResult{}, errors.New("ffmpeg produced empty output")
	}
	if int64(len(body)) > c.Config.MaxOutputBytes {
		return VideoTranscodeResult{}, fmt.Errorf("ffmpeg: output exceeds max bytes (%d)", c.Config.MaxOutputBytes)
	}
	// Prefer post-transcode probe when available so dimensions/duration match the derivative.
	outProbe, probeErr := c.Probe(ctx, body)
	if probeErr == nil {
		probe = outProbe
	}
	width, height := probe.Width, probe.Height
	if width < 1 {
		width = c.Config.VideoMaxWidth
	}
	if height < 1 {
		height = c.Config.VideoMaxHeight
	}
	codec := probe.CodecName
	if codec == "" {
		codec = "h264"
	}
	return VideoTranscodeResult{
		Body:        body,
		ContentType: "video/mp4",
		Width:       width,
		Height:      height,
		DurationMS:  probe.DurationMS,
		Codec:       codec,
	}, nil
}

func (c *ExternalCodec) writeTemp(pattern string, body []byte) (string, func(), error) {
	path, cleanup, err := c.tempPath(pattern)
	if err != nil {
		return "", nil, err
	}
	if err := os.WriteFile(path, body, 0o600); err != nil {
		cleanup()
		return "", nil, fmt.Errorf("write temp media: %w", err)
	}
	return path, cleanup, nil
}

func (c *ExternalCodec) tempPath(pattern string) (string, func(), error) {
	dir := strings.TrimSpace(c.Config.TempDir)
	if dir == "" {
		dir = os.TempDir()
	}
	if err := os.MkdirAll(dir, 0o750); err != nil {
		return "", nil, fmt.Errorf("create media temp dir: %w", err)
	}
	file, err := os.CreateTemp(dir, pattern)
	if err != nil {
		return "", nil, fmt.Errorf("create temp media file: %w", err)
	}
	path := file.Name()
	if err := file.Close(); err != nil {
		_ = os.Remove(path)
		return "", nil, err
	}
	return path, func() { _ = os.Remove(path) }, nil
}

type ffprobePayload struct {
	Streams []struct {
		CodecType string `json:"codec_type"`
		CodecName string `json:"codec_name"`
		Width     int    `json:"width"`
		Height    int    `json:"height"`
		Duration  string `json:"duration"`
	} `json:"streams"`
	Format struct {
		Duration   string `json:"duration"`
		FormatName string `json:"format_name"`
	} `json:"format"`
}

func parseFFProbeJSON(raw []byte) (VideoProbe, error) {
	var payload ffprobePayload
	if err := json.Unmarshal(raw, &payload); err != nil {
		return VideoProbe{}, fmt.Errorf("ffprobe: parse json: %w", err)
	}
	probe := VideoProbe{FormatName: payload.Format.FormatName}
	for _, stream := range payload.Streams {
		if stream.CodecType != "video" {
			continue
		}
		probe.Width = stream.Width
		probe.Height = stream.Height
		probe.CodecName = stream.CodecName
		if stream.Duration != "" {
			if ms, err := secondsToMS(stream.Duration); err == nil {
				probe.DurationMS = ms
			}
		}
		break
	}
	if probe.DurationMS == 0 && payload.Format.Duration != "" {
		if ms, err := secondsToMS(payload.Format.Duration); err == nil {
			probe.DurationMS = ms
		}
	}
	return probe, nil
}

func secondsToMS(value string) (int64, error) {
	seconds, err := strconv.ParseFloat(strings.TrimSpace(value), 64)
	if err != nil {
		return 0, err
	}
	if seconds < 0 {
		return 0, fmt.Errorf("negative duration %q", value)
	}
	return int64(seconds*1000 + 0.5), nil
}
