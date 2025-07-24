import 'package:flutter/material.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class VisitLogStateWidget extends HookConsumerWidget {
  const VisitLogStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerBiz);

    return Container(
      color: Colors.white60,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: SizedBox.shrink()),

          _getAppIcon(appName: AppName.stopwatch.value),
          ref
              .read(providerBiz.notifier)
              .getVisitCount(appName: AppName.stopwatch)
              .toString()
              .text
              .size(20)
              .make(),
          40.widthBox,
          _getAppIcon(appName: AppName.todo.value),

          ref
              .read(providerBiz.notifier)
              .getVisitCount(appName: AppName.todo)
              .toString()
              .text
              .size(20)
              .make(),
          const Expanded(child: SizedBox.shrink()),
          ElevatedButton(
            onPressed: () {
              ref.read(providerBiz.notifier).fetchVisitLog(1);
            },
            child: "1일".text.make(),
          ),
          10.widthBox,

          ElevatedButton(
            onPressed: () {
              ref.read(providerBiz.notifier).fetchVisitLog(3);
            },
            child: "3일".text.make(),
          ),
          10.widthBox,

          ElevatedButton(
            onPressed: () {
              ref.read(providerBiz.notifier).fetchVisitLog(7);
            },
            child: "7일".text.make(),
          ),
          10.widthBox,
        ],
      ),
    );
  }

  Widget _getAppIcon({required String appName}) {
    late IconData iconData;
    switch (appName) {
      case "Todo Calendar":
        iconData = Icons.calendar_month;
        break;
      case "stopwatch":
        iconData = Icons.watch_later_outlined;
        break;
      default:
        iconData = Icons.place;
        break;
    }
    return Icon(iconData);
  }
}
