import 'package:cookie_manager/cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final CookieManager cookieManager = CookieManager();
  test('add a cookie', () {
    cookieManager.setCookie("foo", "test");

    expect(cookieManager.getCookie("foo"), "test");
  });

  test('remove a cookie', () {
    cookieManager.setCookie("foo", "test");
    cookieManager.removeCookie("foo");

    expect (cookieManager.getCookie("foo"), null);
  });

  test('expire a cookie', () async {
    cookieManager.setCookie("foo", "test", maxAge: Duration (seconds: 10));

    Future.delayed(const Duration (seconds: 11), () {
      expect (cookieManager.getCookie("foo"), null);
    });
  });

  test('clear cookies', () async {
    cookieManager.setCookie("foo1", "test1");
    cookieManager.setCookie("foo2", "test2");

    cookieManager.clearCookies();

    expect (cookieManager.getCookies().length, 0);
  });
}
