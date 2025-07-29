import 'package:flutter/material.dart';
import 'package:heys_dev_web/web_screen/tool/share/master_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'main_dashboard.dart';

class MainToolScreen extends HookConsumerWidget {
  static String routeName = "";

  const MainToolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MasterScreen(
      child: DashboardMainPage(),
    );
  }
}
