import 'package:go_router/go_router.dart';
import 'package:heys_dev_web/web_screen/biz/main_biz.dart';
import 'package:heys_dev_web/web_screen/dev/main_page.dart';
final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
        path: "/",
        builder: (context, state) => MainPage()
    ),
    GoRoute(
        path: "/biz",
        builder: (context, state) => MainBiz()
    ),
  ],
);