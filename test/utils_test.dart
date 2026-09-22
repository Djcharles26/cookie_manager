import 'package:cookie_manager/cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('subdomain returns the main domain', () {
    expect(getMainDomain(Uri.parse('http://app.site.com')), 'site.com');
  });

  test('main domain returns itself', () {
    expect(getMainDomain(Uri.parse('http://site.com')), 'site.com');
  });

  test('localhost returns empty', () {
    expect(getMainDomain(Uri.parse('http://localhost:8087')), '');
  });

  test('IPv4 host returns empty', () {
    expect(getMainDomain(Uri.parse('http://127.0.0.1:8087')), '');
  });

  test('IPv6 host returns empty', () {
    expect(getMainDomain(Uri.parse('http://[::1]:8087')), '');
  });
}
