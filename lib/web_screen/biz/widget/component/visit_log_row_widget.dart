import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class VisitLogRowWidget extends HookConsumerWidget {
  final int id;
  final String appName;
  final String userName;
  final String osType;
  final String version;
  final String eventType;
  final String contry;
  final DateTime createAt;
  final int count;

  const VisitLogRowWidget({
    required this.id,
    required this.appName,
    required this.userName,
    required this.osType,
    required this.version,
    required this.eventType,
    required this.contry,
    required this.createAt,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: id.toString().text.make().centered(),
          ),
          10.widthBox,
          _getPlatformIcon(osType: osType),
          10.widthBox,
          _getAppIcon(appName: appName.toString()),
          10.widthBox,
          SizedBox(width: 100, child: contry.toString().text.make()),
          20.widthBox,
          Expanded(
            child: TextButton(
              onPressed: () {
                context.go('/biz/detail/$userName');
              },
              child: userName.toString().text.ellipsis.make(),
            ),
          ),
          50.widthBox,
          count.toString().text.make(),
          30.widthBox,
          SizedBox(width: 80, child: _getDateToString(dateTime: createAt)),
          10.widthBox,
          SizedBox(
            width: 120,
            child: _getDateToStringFormat(now: createAt).text.make().centered(),
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
      case "hdeys.dev":
        iconData = CupertinoIcons.tag;
        break;
      default:
        iconData = CupertinoIcons.nosign;
        break;
    }
    return Icon(iconData);
  }

  Widget _getDateToString({required DateTime dateTime}) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    print(
      'now: $now, datetime : $dateTime diff: $diff, diff hours: ${diff.inHours}, diff days: ${diff.inDays}',
    );
    String text = "";
    if (diff.inSeconds < 60) {
      text = '방금 전';
    } else if (diff.inMinutes < 60) {
      text = '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24)
      text = '${diff.inHours}시간 전';
    else if (diff.inDays < 7)
      text = '${diff.inDays}일 전';
    else if (diff.inDays < 30)
      text = '${(diff.inDays / 7).floor()}주 전';
    else if (diff.inDays < 365)
      text = '${(diff.inDays / 30).floor()}달 전';
    else
      text = '${(diff.inDays / 365).floor()}년 전';

    return text.toString().text.make();
  }

  Widget _getPlatformIcon({required String osType}) {
    switch (osType.toLowerCase()) {
      case "android":
        return const Icon(Icons.android, color: Colors.green);
      case "ios":
        return const Icon(Icons.apple, color: Colors.black);
      case "web":
        return const Icon(Icons.web);
      default:
        return const Icon(Icons.device_unknown);
    }
  }

  String _getDateToStringFormat({required DateTime now}) {
    now = now.toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String formatted = '${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}';

    return formatted;
  }
}
