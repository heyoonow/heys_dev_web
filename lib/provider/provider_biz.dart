import 'package:heys_dev_web/provider/provider_cookie.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/util/cookie_manager.dart';

final providerBiz = Provider((ref) {
  final cookie = ref.watch(providerCookie);
  return BizService(cookieManager: cookie);
});

class BizService {
  bool _isAuth = false;

  // set setAuth(bool flag){
  //   isAuth = flag;
  // }
  bool get getAuth => _isAuth;
  final CookieManager cookieManager;

  BizService({required this.cookieManager});

  bool checkPassword({required String text}) {
    print(text);
    return text == "qweasd123";
  }

  void login() {
    cookieManager.setCookie("auth", "qweasd123");
    _isAuth = true;
    print('login!!!!!!!!!!');
  }
}
