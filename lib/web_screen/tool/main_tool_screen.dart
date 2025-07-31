import 'package:flutter/material.dart';
import 'package:heys_dev_web/web_screen/tool/share/master_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'main_dashboard.dart';

class MainToolScreen extends HookConsumerWidget {
  static String routeName = "";

  const MainToolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    // HeysTool.setMetaTags(
    //   title: 'heys.dev – All-in-one Online Developer Tools',
    //   description:
    //       'heys.dev provides a powerful collection of web-based developer tools including JSON Viewer, HTTP Tester, Diff Checker, CSS Viewer, Color Picker, and more – all for free, no login required.',
    //   imageUrl: 'https://heys.dev/assets/assets/images/meta_logo.png',
    //   // 대표 이미지 URL (https 경로)
    //   url: 'https://heys.dev',
    //   // 서비스 메인 주소
    //   keywords:
    //       'developer tools, online, json viewer, http tester, diff checker, color picker, css viewer, heys.dev, programming, productivity',
    //   siteName: 'heys.dev',
    //   ogType: 'website',
    //   twitterCard: 'summary_large_image',
    // );
    return MasterScreen(
      child: DashboardMainPage(),
    );
  }
}
