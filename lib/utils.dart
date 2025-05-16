part of 'cookie_manager.dart';

/// Obtains the main domain of the current site.
/// 
/// For example, if the site is app.site.com then the main domain is site.com
String getMainDomain(Uri uri) {
  List<String> parts = uri.host.split('.');

  if (parts.length >= 3) {
    return '${parts[parts.length - 2]}.${parts.last}';
  }
  
  return uri.host;
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