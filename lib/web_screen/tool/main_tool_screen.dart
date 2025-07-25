import 'package:flutter/material.dart';
import 'package:heys_dev_web/web_screen/tool/share/master_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class MainToolScreen extends HookConsumerWidget {
  static String routeName = "tool";

  const MainToolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MasterScreen(child: "asdf".text.make());
  }
}
