import 'package:flutter/material.dart';
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

  const VisitLogRowWidget({
    required this.id,
    required this.appName,
    required this.userName,
    required this.osType,
    required this.version,
    required this.eventType,
    required this.contry,
    required this.createAt,
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
          _getAppIcon(appName: appName.toString()),
          const Expanded(child: SizedBox.shrink()),
          userName.toString().text.make(),
          const Expanded(child: SizedBox.shrink()),
          _getDateToString(dateTime: createAt),
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
}
