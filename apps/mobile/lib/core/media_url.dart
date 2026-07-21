/// Resolve API/media URLs for Flutter display.
///
/// Rules:
/// - absolute http(s) → as-is
/// - absolute non-http scheme → null
/// - path starting with `/` → api host root + path
/// - `assets/...` → as-is (local asset)
/// - empty/invalid → null
String? resolveMediaUrl(String? raw, {required String apiBaseUrl}) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  if (value.startsWith('assets/')) return value;

  final parsed = Uri.tryParse(value);
  if (parsed == null) return null;
  if (parsed.hasScheme) {
    if (parsed.scheme == 'http' || parsed.scheme == 'https') {
      return parsed.toString();
    }
    return null;
  }

  final root = _apiHostRoot(apiBaseUrl);
  if (root.isEmpty) return null;
  final path = value.startsWith('/') ? value : '/$value';
  return Uri.parse('$root$path').toString();
}

bool isPrivateMediaContentUrl(String? url) {
  final value = url?.trim() ?? '';
  if (value.isEmpty) return false;
  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  final path = uri.path;
  return path.contains('/media/') && path.endsWith('/content');
}

String _apiHostRoot(String apiBaseUrl) {
  var root = apiBaseUrl.trim();
  if (root.isEmpty) return '';
  root = root.replaceFirst(RegExp(r'/$'), '');
  if (root.endsWith('/v1')) {
    root = root.substring(0, root.length - 3);
  }
  return root.replaceFirst(RegExp(r'/$'), '');
}
