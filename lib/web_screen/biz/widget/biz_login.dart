import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class BizLogin extends HookConsumerWidget {
  const BizLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    useEffect(() {
      final cookie = ref.read(providerBiz.notifier).getCookie();
      textController.text = cookie ?? "";
      return null;
    }, []);
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
          ElevatedButton(
            onPressed: () {
              ref.read(providerBiz.notifier).login(text: textController.text);
            },
            child: "로그인".text.make(),
          ),
        ],
      ),
    );
  }
}
