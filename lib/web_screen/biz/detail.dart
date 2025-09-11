import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class Detail extends HookConsumerWidget {
  static const String routeName = "detail";
  final String id;

  const Detail({
    required this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bizState = ref.watch(providerBiz);
    useEffect(() {
      ref.read(providerBiz.notifier).detailLog(id: id);
    }, [id]);
    return Scaffold(
      body: Container(
        child: bizState.detailLog?.length.toString().text.make().centered(),
      ),
    );
  }
}
