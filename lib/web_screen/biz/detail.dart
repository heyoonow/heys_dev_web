import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:heys_dev_web/web_screen/biz/widget/component/visit_log_row_widget.dart';
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
        child: Column(
          children: [
            (bizState.detailLog?.length.toString() ?? "").text.make(),
            Expanded(
              child: Container(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    if (bizState.detailLog == null) return Container();
                    final item = bizState.detailLog![index];

                    return VisitLogRowWidget(
                      id: item["id"],
                      appName: item["app_name"],
                      userName: item["user_id"],
                      osType: item["os_type"],
                      version: item["version"],
                      eventType: item["event_type"],
                      contry: item["contry"],
                      createAt: DateTime.parse(item["created_at"]),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 1, color: Colors.black);
                  },
                  itemCount: bizState.detailLog?.length ?? 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
