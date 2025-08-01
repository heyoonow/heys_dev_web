import 'package:flutter/material.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:heys_dev_web/web_screen/biz/widget/biz_login.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'widget/biz_main.dart';

class MainBiz extends HookConsumerWidget {
  const MainBiz({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bizState = ref.watch(providerBiz);
    return Scaffold(
      body: bizState.isAuth ? BizMain() : BizLogin(),
    );
  }
}
