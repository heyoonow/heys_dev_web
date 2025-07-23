import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BizLogin extends HookConsumerWidget {
  const BizLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    textController.addListener(() {
      final text = textController.text;
      final result = ref.read(providerBiz).checkPassword(text: text);
      if (result) {
        ref.read(providerBiz).login();
      }
    });
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
