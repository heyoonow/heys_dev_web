import 'package:flutter/material.dart';
import 'package:heys_dev_web/provider/provider_biz.dart';
import 'package:heys_dev_web/web_screen/biz/widget/component/visit_log_search.dart';
import 'package:heys_dev_web/web_screen/biz/widget/component/visit_log_state_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import 'component/visit_log_row_widget.dart';

class BizMain extends HookConsumerWidget {
  const BizMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(providerBiz);
    return Scaffold(
      body: Container(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            children: [
              VisitLogSearch(),
              10.heightBox,
              VisitLogStateWidget(),
              10.heightBox,
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      if (state.visitLog == null) return Container();
                      final item = state.visitLog![index];

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
                      return const Divider(
                        height: 1,
                        color: Colors.black,
                      );
                    },
                    itemCount: state.visitLog?.length ?? 0,
                  ),
                ),
              ),
            ],
          ),
        ).centered(),
      ),
    );
  }
}
