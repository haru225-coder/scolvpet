package worker

import (
	"bytes"
	"image"
	"image/color"
	"image/png"
	"testing"
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

func TestDeriveMediaRejectsUnsupportedWebPEncoding(t *testing.T) {
	_, err := deriveMedia(testPNG(t, 1, 1), "image/png", "image_edit", []byte(`{
		"operations":[],"output_format":"webp"
	}`))
	if err == nil {
		t.Fatal("webp encoding unexpectedly succeeded")
	}
}
