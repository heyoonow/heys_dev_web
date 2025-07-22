import 'package:web/web.dart' as web;
class CookieManager{

// 쿠키 저장 (Set)
  void setCookie(String name, String value, {int days = 7}) {
    final expires = DateTime.now().add(Duration(days: days));
    final cookie =
        '$name=$value; expires=${expires.toUtc().toRfc1123String()}; path=/';
    web.window.document.cookie = cookie;
  }

// 쿠키 가져오기 (Get)
  String? getCookie(String name) {
    final cookies = web.window.document.cookie?.split('; ') ?? [];
    for (final cookie in cookies) {
      final kv = cookie.split('=');
      if (kv[0] == name) {
        return kv.length > 1 ? kv[1] : '';
      }
    }
    return null;
  }

}

extension Rfc1123Date on DateTime {
  String toRfc1123String() {
    // Wed, 21 Oct 2015 07:28:00 GMT
    return toUtc().toIso8601String().replaceAll('T', ' ').split('.').first + ' GMT';
  }
}