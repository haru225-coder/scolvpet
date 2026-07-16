package worker

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync/atomic"
	"testing"
	"time"
)

type fakeRunner struct {
	calls  atomic.Int32
	run    func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error)
	last   string
	lastArgs []string
}

func (f *fakeRunner) Run(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
	f.calls.Add(1)
	f.last = name
	f.lastArgs = append([]string(nil), args...)
	if f.run != nil {
		return f.run(ctx, name, args, stdin)
	}
	return nil, nil, errors.New("fake runner not configured")
}

func testImage(t *testing.T) image.Image {
	t.Helper()
	img := image.NewNRGBA(image.Rect(0, 0, 2, 2))
	img.Set(0, 0, color.NRGBA{R: 255, A: 255})
	img.Set(1, 1, color.NRGBA{G: 255, A: 255})
	return img
}

func TestExternalCodecWebPEncodeSuccess(t *testing.T) {
	runner := &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
		if name != "/tools/cwebp" {
			t.Fatalf("binary = %q", name)
		}
		if len(stdin) == 0 {
			t.Fatal("expected PNG stdin")
		}
		if _, err := png.Decode(bytes.NewReader(stdin)); err != nil {
			t.Fatalf("stdin is not PNG: %v", err)
		}
		joined := strings.Join(args, " ")
		if !strings.Contains(joined, "-q 80") || !strings.Contains(joined, "-o -") {
			t.Fatalf("unexpected args: %v", args)
		}
		return []byte("WEBPFAKE"), nil, nil
	}}
	codec := NewExternalCodec(CodecConfig{
		CWebPPath: "/tools/cwebp",
		LookPath:  func(file string) (string, error) { return file, nil },
		Runner:    runner,
		Timeout:   time.Second,
	})
	body, err := codec.Encode(context.Background(), testImage(t), 80)
	if err != nil {
		t.Fatalf("Encode: %v", err)
	}
	if string(body) != "WEBPFAKE" {
		t.Fatalf("body = %q", body)
	}
	if runner.calls.Load() != 1 {
		t.Fatalf("calls = %d", runner.calls.Load())
	}
}

func TestExternalCodecWebPEncodeMissingBinary(t *testing.T) {
	codec := NewExternalCodec(CodecConfig{
		CWebPPath: "missing-cwebp",
		LookPath:  func(string) (string, error) { return "", exec.ErrNotFound },
		Runner:    &fakeRunner{},
	})
	_, err := codec.Encode(context.Background(), testImage(t), 80)
	if !errors.Is(err, ErrCodecUnavailable) {
		t.Fatalf("error = %v, want ErrCodecUnavailable", err)
	}
}

func TestExternalCodecWebPEncodeTimeout(t *testing.T) {
	runner := &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
		<-ctx.Done()
		return nil, nil, context.DeadlineExceeded
	}}
	codec := NewExternalCodec(CodecConfig{
		CWebPPath: "/tools/cwebp",
		LookPath:  func(file string) (string, error) { return file, nil },
		Runner:    runner,
		Timeout:   5 * time.Millisecond,
	})
	_, err := codec.Encode(context.Background(), testImage(t), 80)
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("error = %v, want deadline exceeded", err)
	}
}

func TestExternalCodecProbeAndTranscodeSuccess(t *testing.T) {
	probeJSON := []byte(`{
		"streams":[{"codec_type":"video","codec_name":"h264","width":1280,"height":720,"duration":"1.500"}],
		"format":{"duration":"1.500","format_name":"mov,mp4,m4a,3gp,3g2,mj2"}
	}`)
	var probeCalls, ffmpegCalls int
	runner := &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
		switch name {
		case "/tools/ffprobe":
			probeCalls++
			return probeJSON, nil, nil
		case "/tools/ffmpeg":
			ffmpegCalls++
			// last arg is the output path for the real ExternalCodec.Transcode invocation.
			out := args[len(args)-1]
			if err := os.WriteFile(out, []byte("MP4FAKE"), 0o600); err != nil {
				return nil, nil, err
			}
			return nil, nil, nil
		default:
			return nil, nil, fmt.Errorf("unexpected binary %s", name)
		}
	}}
	codec := NewExternalCodec(CodecConfig{
		FFmpegPath:  "/tools/ffmpeg",
		FFprobePath: "/tools/ffprobe",
		LookPath:    func(file string) (string, error) { return file, nil },
		Runner:      runner,
		TempDir:     t.TempDir(),
		Timeout:     time.Second,
	})
	result, err := codec.Transcode(context.Background(), []byte("raw-video-bytes"))
	if err != nil {
		t.Fatalf("Transcode: %v", err)
	}
	if string(result.Body) != "MP4FAKE" || result.ContentType != "video/mp4" {
		t.Fatalf("result = %+v", result)
	}
	if result.Width != 1280 || result.Height != 720 || result.DurationMS != 1500 || result.Codec != "h264" {
		t.Fatalf("metadata = %+v", result)
	}
	if probeCalls < 1 || ffmpegCalls != 1 {
		t.Fatalf("probeCalls=%d ffmpegCalls=%d", probeCalls, ffmpegCalls)
	}
}

func TestExternalCodecTranscodeMissingFFmpeg(t *testing.T) {
	codec := NewExternalCodec(CodecConfig{
		FFmpegPath:  "missing-ffmpeg",
		FFprobePath: "/tools/ffprobe",
		LookPath: func(file string) (string, error) {
			if file == "missing-ffmpeg" {
				return "", exec.ErrNotFound
			}
			return file, nil
		},
		Runner: &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
			return []byte(`{"streams":[{"codec_type":"video","width":64,"height":64}],"format":{"duration":"1.0"}}`), nil, nil
		}},
	})
	// Probe path is checked first inside Transcode before ffmpeg resolve in our implementation;
	// force missing ffmpeg after probe succeeds.
	codec = NewExternalCodec(CodecConfig{
		FFmpegPath:  "missing-ffmpeg",
		FFprobePath: "/tools/ffprobe",
		LookPath: func(file string) (string, error) {
			if strings.Contains(file, "ffmpeg") {
				return "", exec.ErrNotFound
			}
			return "/tools/ffprobe", nil
		},
		Runner: &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
			return []byte(`{"streams":[{"codec_type":"video","width":64,"height":64}],"format":{"duration":"1.0"}}`), nil, nil
		}},
		TempDir: t.TempDir(),
	})
	_, err := codec.Transcode(context.Background(), []byte("raw"))
	if !errors.Is(err, ErrCodecUnavailable) {
		t.Fatalf("error = %v, want ErrCodecUnavailable", err)
	}
}

func TestExternalCodecTranscodeTimeout(t *testing.T) {
	runner := &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
		if strings.Contains(name, "ffprobe") {
			return []byte(`{"streams":[{"codec_type":"video","width":64,"height":64}],"format":{"duration":"1.0"}}`), nil, nil
		}
		<-ctx.Done()
		return nil, nil, context.DeadlineExceeded
	}}
	codec := NewExternalCodec(CodecConfig{
		FFmpegPath:  "/tools/ffmpeg",
		FFprobePath: "/tools/ffprobe",
		LookPath:    func(file string) (string, error) { return file, nil },
		Runner:      runner,
		TempDir:     t.TempDir(),
		Timeout:     5 * time.Millisecond,
	})
	_, err := codec.Transcode(context.Background(), []byte("raw"))
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("error = %v, want deadline exceeded", err)
	}
}

func TestExternalCodecTranscodeCommandFailurePreservesDetail(t *testing.T) {
	runner := &fakeRunner{run: func(ctx context.Context, name string, args []string, stdin []byte) ([]byte, []byte, error) {
		if strings.Contains(name, "ffprobe") {
			return []byte(`{"streams":[{"codec_type":"video","width":64,"height":64}],"format":{"duration":"1.0"}}`), nil, nil
		}
		return nil, []byte("encoder not found"), errors.New("exit status 1")
	}}
	codec := NewExternalCodec(CodecConfig{
		FFmpegPath:  "/tools/ffmpeg",
		FFprobePath: "/tools/ffprobe",
		LookPath:    func(file string) (string, error) { return file, nil },
		Runner:      runner,
		TempDir:     t.TempDir(),
	})
	_, err := codec.Transcode(context.Background(), []byte("raw"))
	if err == nil || !strings.Contains(err.Error(), "encoder not found") {
		t.Fatalf("error = %v, want failure detail", err)
	}
}

func TestExternalCodecRejectsOversizedInput(t *testing.T) {
	codec := NewExternalCodec(CodecConfig{
		FFmpegPath:     "/tools/ffmpeg",
		FFprobePath:    "/tools/ffprobe",
		MaxInputBytes:  4,
		LookPath:       func(file string) (string, error) { return file, nil },
		Runner:         &fakeRunner{},
	})
	_, err := codec.Transcode(context.Background(), []byte("too-large"))
	if err == nil || !strings.Contains(err.Error(), "max input bytes") {
		t.Fatalf("error = %v", err)
	}
}

func TestParseFFProbeJSON(t *testing.T) {
	probe, err := parseFFProbeJSON([]byte(`{
		"streams":[
			{"codec_type":"audio","codec_name":"aac"},
			{"codec_type":"video","codec_name":"h264","width":640,"height":360,"duration":"2.25"}
		],
		"format":{"duration":"2.25","format_name":"mp4"}
	}`))
	if err != nil {
		t.Fatal(err)
	}
	if probe.Width != 640 || probe.Height != 360 || probe.DurationMS != 2250 || probe.CodecName != "h264" {
		t.Fatalf("probe = %+v", probe)
	}
}

func TestLiveCodecIntegrationWhenInstalled(t *testing.T) {
	cwebp, errC := exec.LookPath("cwebp")
	ffmpeg, errF := exec.LookPath("ffmpeg")
	ffprobe, errP := exec.LookPath("ffprobe")
	if errC != nil || errF != nil || errP != nil {
		t.Logf("待确认: live codec 集成测试跳过（cwebp=%v ffmpeg=%v ffprobe=%v）", errC, errF, errP)
		return
	}
	codec := NewExternalCodec(CodecConfig{
		CWebPPath:   cwebp,
		FFmpegPath:  ffmpeg,
		FFprobePath: ffprobe,
		TempDir:     t.TempDir(),
		Timeout:     30 * time.Second,
		WebPQuality: 70,
	})
	body, err := codec.Encode(context.Background(), testImage(t), 70)
	if err != nil {
		t.Fatalf("live cwebp Encode: %v", err)
	}
	if len(body) == 0 {
		t.Fatal("live cwebp returned empty body")
	}

	// Generate a tiny real MP4 with ffmpeg so Transcode exercises a real codec path.
	src := filepath.Join(t.TempDir(), "src.mp4")
	cmd := exec.Command(ffmpeg,
		"-y", "-hide_banner", "-loglevel", "error",
		"-f", "lavfi", "-i", "color=c=red:s=64x64:d=0.2",
		"-c:v", "libx264", "-pix_fmt", "yuv420p",
		src,
	)
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("seed ffmpeg: %v (%s)", err, out)
	}
	raw, err := os.ReadFile(src)
	if err != nil {
		t.Fatal(err)
	}
	result, err := codec.Transcode(context.Background(), raw)
	if err != nil {
		t.Fatalf("live Transcode: %v", err)
	}
	if result.ContentType != "video/mp4" || len(result.Body) == 0 || result.DurationMS <= 0 {
		t.Fatalf("live result = %+v body=%d", result, len(result.Body))
	}
	if result.Width < 1 || result.Height < 1 {
		t.Fatalf("live dimensions missing: %+v", result)
	}
}
