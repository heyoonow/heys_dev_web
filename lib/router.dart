import 'package:go_router/go_router.dart';
import 'package:heys_dev_web/biz/main_biz.dart';
import 'package:heys_dev_web/main_dev/main_page.dart';

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