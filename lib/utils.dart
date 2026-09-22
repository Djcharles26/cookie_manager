part of 'cookie_manager.dart';

final RegExp _ipv4Pattern = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');

/// Obtains the main domain of the current site.
///
/// For example, if the site is app.site.com then the main domain is site.com
///
/// Returns an empty string for `localhost`, an IPv4 address or an IPv6
/// address: browsers reject a `Domain` attribute that does not match the
/// host, so none of those hosts should get one.
String getMainDomain(Uri uri) {
  final String host = uri.host;

  if (host == 'localhost' ||
      _ipv4Pattern.hasMatch(host) ||
      host.contains(':')) {
    return '';
  }

  List<String> parts = host.split('.');

  if (parts.length >= 3) {
    return '${parts[parts.length - 2]}.${parts.last}';
  }

  return host;
}

/// Obtains information about current implementation
/// 
/// Returns true if current isn't the top window (is an iframe)
bool get isInIframe {
  try {
    return web.window.self != web.window.top;
  } catch (_) {
    return true;
  }
}