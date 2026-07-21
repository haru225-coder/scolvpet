import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/core/media_url.dart';

void main() {
  group('resolveMediaUrl', () {
    test('keeps absolute http(s)', () {
      expect(
        resolveMediaUrl(
          'https://cdn.example/a.webp',
          apiBaseUrl: 'https://api.example/v1',
        ),
        'https://cdn.example/a.webp',
      );
    });

    test('joins relative /v1 media path to host root', () {
      expect(
        resolveMediaUrl(
          '/v1/media/abc/content',
          apiBaseUrl: 'https://api.example/v1',
        ),
        'https://api.example/v1/media/abc/content',
      );
      expect(
        resolveMediaUrl(
          '/v1/public/sites/s/media/m',
          apiBaseUrl: 'https://p.scolv.com:8443',
        ),
        'https://p.scolv.com:8443/v1/public/sites/s/media/m',
      );
    });

    test('keeps local assets and rejects empty', () {
      expect(
        resolveMediaUrl('assets/brand/x.png', apiBaseUrl: 'https://api/v1'),
        'assets/brand/x.png',
      );
      expect(resolveMediaUrl('', apiBaseUrl: 'https://api/v1'), isNull);
      expect(resolveMediaUrl(null, apiBaseUrl: 'https://api/v1'), isNull);
    });
  });

  group('isPrivateMediaContentUrl', () {
    test('detects private content path', () {
      expect(
        isPrivateMediaContentUrl(
          'https://api.example/v1/media/abc/content?variant_id=1',
        ),
        isTrue,
      );
      expect(
        isPrivateMediaContentUrl(
          'https://api.example/v1/public/sites/s/media/m',
        ),
        isFalse,
      );
    });
  });
}
