import 'package:go_router/go_router.dart';
import 'package:heys_dev_web/web_screen/biz/main_biz.dart';
import 'package:heys_dev_web/web_screen/tool/main_tool_screen.dart';
import 'package:heys_dev_web/web_screen/tool/tools/json_viewer.dart';

final router = GoRouter(
  initialLocation: '/${MainToolScreen.routeName}',
  routes: [
    GoRoute(path: "/biz", builder: (context, state) => MainBiz()),
    GoRoute(
      path: '/${MainToolScreen.routeName}',
      builder: (context, state) => MainToolScreen(),
      routes: [
        GoRoute(
          path: JsonViewerScreen.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            child: JsonViewerScreen(),
          ),
        ),
      ],
    ),
  ],
);
