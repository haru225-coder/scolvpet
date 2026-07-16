package worker

import (
	"bytes"
	"context"
	"errors"
	"image"
	"image/color"
	"image/png"
	"strings"
	"testing"
	"time"
)

func testPNG(t *testing.T, width, height int) []byte {
	t.Helper()
	img := image.NewNRGBA(image.Rect(0, 0, width, height))
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			img.Set(x, y, color.NRGBA{R: uint8(x * 40), G: uint8(y * 40), B: 120, A: 255})
		}
	}
	var body bytes.Buffer
	if err := png.Encode(&body, img); err != nil {
		t.Fatal(err)
	}
	return body.Bytes()
}

type stubWebPEncoder struct {
	body []byte
	err  error
}

func (s stubWebPEncoder) Encode(ctx context.Context, img image.Image, quality int) ([]byte, error) {
	if s.err != nil {
		return nil, s.err
	}
	if s.body != nil {
		return s.body, nil
	}
	return []byte("WEBP"), nil
}

type stubVideoTranscoder struct {
	result VideoTranscodeResult
	probe  VideoProbe
	err    error
	calls  int
}

func (s *stubVideoTranscoder) Probe(ctx context.Context, source []byte) (VideoProbe, error) {
	s.calls++
	if s.err != nil {
		return VideoProbe{}, s.err
	}
	return s.probe, nil
}

func (s *stubVideoTranscoder) Transcode(ctx context.Context, source []byte) (VideoTranscodeResult, error) {
	s.calls++
	if s.err != nil {
		return VideoTranscodeResult{}, s.err
	}
	if len(s.result.Body) == 0 {
		return VideoTranscodeResult{
			Body: []byte("MP4"), ContentType: "video/mp4",
			Width: 640, Height: 360, DurationMS: 1500, Codec: "h264",
		}, nil
	}
	return s.result, nil
}

func TestDeriveMediaResizeAndCrop(t *testing.T) {
	source := testPNG(t, 4, 3)
	resized, err := deriveMedia(source, "image/png", "image_edit", []byte(`{
		"operations":[{"op":"resize","width":2,"height":2}],"output_format":"png"
	}`))
	if err != nil {
		t.Fatalf("resize: %v", err)
	}
	if resized.ContentType != "image/png" || resized.Width != 2 || resized.Height != 2 {
		t.Fatalf("resized metadata = %+v", resized)
	}
	if _, _, err := image.Decode(bytes.NewReader(resized.Body)); err != nil {
		t.Fatalf("resized image does not decode: %v", err)
	}

	cropped, err := deriveMedia(source, "image/png", "image_edit", []byte(`{
		"operations":[{"type":"crop","parameters":{"x":1,"y":1,"width":2,"height":1}}],"output_format":"png"
	}`))
	if err != nil {
		t.Fatalf("crop: %v", err)
	}
	if cropped.Width != 2 || cropped.Height != 1 {
		t.Fatalf("cropped metadata = %+v", cropped)
	}
}

func TestDeriveMediaRejectsWebPWithoutEncoder(t *testing.T) {
	_, err := deriveMedia(testPNG(t, 1, 1), "image/png", "image_edit", []byte(`{
		"operations":[],"output_format":"webp"
	}`))
	if err == nil || !errors.Is(err, ErrCodecUnavailable) {
		t.Fatalf("error = %v, want ErrCodecUnavailable", err)
	}
}

func TestDeriveMediaWebPWithInjectedEncoder(t *testing.T) {
	derived, err := deriveMediaWith(
		context.Background(),
		testPNG(t, 2, 2),
		"image/png",
		"image_edit",
		[]byte(`{"operations":[{"op":"resize","width":1,"height":1}],"output_format":"webp"}`),
		stubWebPEncoder{body: []byte("FAKEWEBP")},
		nil,
	)
	if err != nil {
		t.Fatalf("webp: %v", err)
	}
	if derived.ContentType != "image/webp" || string(derived.Body) != "FAKEWEBP" || derived.Width != 1 || derived.Height != 1 {
		t.Fatalf("derived = %+v", derived)
	}
}

func TestDeriveMediaVideoTranscodeSuccess(t *testing.T) {
	transcoder := &stubVideoTranscoder{result: VideoTranscodeResult{
		Body: []byte("transcoded"), ContentType: "video/mp4",
		Width: 320, Height: 180, DurationMS: 2500, Codec: "h264",
	}}
	derived, err := deriveMediaWith(
		context.Background(),
		[]byte("raw-video"),
		"video/mp4",
		"video_transcode",
		nil,
		nil,
		transcoder,
	)
	if err != nil {
		t.Fatalf("transcode: %v", err)
	}
	if string(derived.Body) != "transcoded" || derived.DurationMS != 2500 || derived.Codec != "h264" {
		t.Fatalf("derived = %+v", derived)
	}
	if transcoder.calls != 1 {
		t.Fatalf("calls = %d", transcoder.calls)
	}
}

func TestDeriveMediaVideoTranscodeFailure(t *testing.T) {
	_, err := deriveMediaWith(
		context.Background(),
		[]byte("raw-video"),
		"video/mp4",
		"video_transcode",
		nil,
		nil,
		&stubVideoTranscoder{err: errors.New("codec crashed")},
	)
	if err == nil || !strings.Contains(err.Error(), "codec crashed") {
		t.Fatalf("error = %v", err)
	}
}

func TestDeriveMediaVideoTranscodeMissingCodec(t *testing.T) {
	_, err := deriveMediaWith(
		context.Background(),
		[]byte("raw-video"),
		"video/mp4",
		"video_transcode",
		nil,
		nil,
		nil,
	)
	if !errors.Is(err, ErrCodecUnavailable) {
		t.Fatalf("error = %v, want ErrCodecUnavailable", err)
	}
}

func TestDeriveMediaVideoTranscodeTimeout(t *testing.T) {
	_, err := deriveMediaWith(
		context.Background(),
		[]byte("raw-video"),
		"video/mp4",
		"video_transcode",
		nil,
		nil,
		&stubVideoTranscoder{err: context.DeadlineExceeded},
	)
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("error = %v", err)
	}
}

func TestDeriveMediaPreviewDoesNotMutateOriginalBytes(t *testing.T) {
	source := testPNG(t, 3, 3)
	derived, err := deriveMedia(source, "image/png", "preview", nil)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(derived.Body, source) {
		t.Fatal("preview must keep original bytes")
	}
	if derived.Width != 3 || derived.Height != 3 {
		t.Fatalf("dimensions = %+v", derived)
	}
}

func TestDeriveMediaWebPEncoderFailureDetail(t *testing.T) {
	_, err := deriveMediaWith(
		context.Background(),
		testPNG(t, 1, 1),
		"image/png",
		"image_edit",
		[]byte(`{"operations":[],"output_format":"webp"}`),
		stubWebPEncoder{err: errors.New("cwebp exit 1: bad input")},
		nil,
	)
	if err == nil || !strings.Contains(err.Error(), "bad input") {
		t.Fatalf("error = %v", err)
	}
}

func TestNewMediaProcessorInjectsDefaultCodec(t *testing.T) {
	processor := NewMediaProcessor(nil, nil, nil)
	if processor.WebPEncoder == nil || processor.VideoTranscoder == nil {
		t.Fatal("default processor missing codecs")
	}
	if processor.LeaseDuration != time.Minute {
		t.Fatalf("lease = %s", processor.LeaseDuration)
	}
}
