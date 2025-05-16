library;

import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

part 'utils.dart';

/// Class dedicated on managing web cookies.
class CookieManager {
  /// Optional encrypt key, used to encrypt cookie values
  Key? cryptoKey;
  CookieManager._();

  static final CookieManager _instance = CookieManager._();
  factory CookieManager() => _instance;

  /// Set a crypto string in order to generate a cryptographic Key
  void configureEncrypt (String keyStr) {
    cryptoKey = Key.fromUtf8(keyStr);
  }

  /// Diggests [value] with the [cryptoKey]
  /// 
  /// If [cryptoKey] wasn't configured before, will return the [value] as it is
  /// 
  /// Returns a Map, containing the encrypted value and an iv/16
  String _encryptValue (String value) {
    if (cryptoKey == null) {
      return value;
    }
    
    final iv = IV.fromLength(16);
    final enc = Encrypter(AES(cryptoKey!));
    final encrypted = enc.encrypt(value, iv: iv);
    final combined = {
      "value": encrypted.base64,
      "iv": iv.base64
    };

    return json.encode(combined);
  }

  /// Diggests [value] decrypting with [cryptoKey]
  /// 
  /// If [cryptoKey] wasn't configured before or [value] ins't in the right format, 
  /// then [value] is returned as it is.
  String _decryptValue (String value) {
    if (cryptoKey == null) return value;
    try {
      final Map<String, String> decoded = Map<String, String>.from (
        json.decode (value)
      );
      final decodedIV = decoded["iv"];
      if (decodedIV == null) {
        // Nothing to do!
        return value;
      }

      final iv = IV.fromBase64 (decodedIV);
      final enc = Encrypter(AES(cryptoKey!));
      final decrypted = enc.decrypt64(decoded['value']!, iv: iv);
      return decrypted;
    } catch (_) {
      return value;
    }
  }

  /// Sets a [name]=[value] cookie.
  /// 
///   - [remove]: `bool`, default `false`. If this flag is true, 
///   [maxAge] will be ignored.
  /// - [maxAge]: Optional `Duration`, will set a duration. If its null, 
  /// no `MaxAge` is set and will be a `Session` Cookie.
  /// - [requiresDomain]: `bool`, default `true`. Sets the main domain of the current
  /// site. For example, if the site is `app.site.com`, the cookie will be set at 
  /// `site.com` level setting this cooke for all subdomains of `site.com`. 
  /// This setting is useful for example when designing a login dashboard,
  /// and the cookie must be persistent in all subdomains.
  /// - [encrypt]: `bool`, default `false`. If this flag is `true`, the [value] will
  /// be tried to be diggested before setting. `configureEncrypt()` must have happened
  /// before setting `encrypted` cookies, otherwise the value won't be `encrypted`
  /// - [manageIframeSettings]: `bool`, default `true`. 
  /// **`NOTE`: Only applies when this is called inside a project running inside an iframe.**
  /// This method checks for current window top, If isn't the site (is iframed)
  /// will set two more fields to the cookie: `SameSite=None;` and `Secure;`.
  /// This two fields allow cookies to be set regardless the domain and allow parent
  /// to manage this cookies.
  void setCookie (
    String name, String value, {
    Duration? maxAge, bool remove = false,
    bool requiresDomain = true, bool encrypt=false,
    bool manageIframeSettings = true
  }){
    final StringBuffer cookieStr = StringBuffer();
    String realValue = value;

    if (encrypt) {
      realValue = _encryptValue(value);
    }

    cookieStr.write ("$name=$realValue; ");

    if (remove) {
      String expiredTimeStr = DateFormat(
        'EEE, dd MMM yyyy HH:mm:ss', 'en-US'
      ).format(DateTime(0));
      cookieStr.write('expires=$expiredTimeStr GMT; ');
    } else  if (maxAge != null) {
      cookieStr.write('MaxAge=${maxAge.inSeconds}; ');
    }

    if (isInIframe && manageIframeSettings) {
      cookieStr.write("SameSite=None; Secure; ");
    } else if (requiresDomain) {
      cookieStr.write ("domain=${getMainDomain(Uri.base)}; ");
    }
    
    cookieStr.write("path=/ ");

    web.document.cookie = cookieStr.toString();
  }

  /// Removes cookie by calling [setCookie] with `remove` as `true
  /// - [requiresDomain]: `bool` default `true`. Remove the cookie from the main domain
  /// of the site.
  void removeCookie (String name, {bool requiresDomain=true}) {
    setCookie(name, "", remove: true, requiresDomain: requiresDomain);
  }

  /// Obtains a list of decoded cookies (changing URI component characters to ASCII characters)
  /// as `name=value` strings.
  List<String> getCookies () {
    String decodedCookie = Uri.decodeComponent(web.document.cookie);
    return decodedCookie.split(';');
  }

  /// Returns a cookie of type [name].
  /// - [encrypted] `bool` default `false`. If set true, and cookie exists, will
  /// try to decrypt the `value`. `configureEncrypt` must have happened before calling
  /// this method.
  /// - [allowEmptyResult] `bool` default `false`. If set true, and the cookie exists
  /// but it's value is '' then this value will be returned, otherwise will return `null`
  String? getCookie (String name, {bool encrypted=false, bool allowEmptyResult = false}) {
    final cookies = getCookies();
    final search = "$name=";
    String? result;
    for (var cookie in cookies){
      cookie = cookie.trimLeft();
      if (cookie.startsWith(search)) {
        result = Uri.decodeComponent(cookie.substring(search.length));
        break;
      }
    }

    if(encrypted && result != null) {
      result = _decryptValue(result);
    }

    if (!allowEmptyResult && (result != null && result.isEmpty)) {
      result = null;
    }

    return result;
  }

  /// Clear all cookies of the current `site` or `domain`.
  /// - [requiresDomain] `bool` default `true`, will clear all cookies of the main
  /// domain.
  void clearCookies ({bool requiresDomain=true}) {
    final cookies = getCookies();
    for (var cookie in cookies) {
      final parts = cookie.trimLeft().split("=");
      if (parts.isNotEmpty) {
        removeCookie(parts[0], requiresDomain: requiresDomain);
      }
    }
  }
}