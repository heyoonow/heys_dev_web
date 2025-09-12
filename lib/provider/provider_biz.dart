import 'package:heys_dev_web/model/biz_model.dart';
import 'package:heys_dev_web/provider/provider_cookie.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

import '../common/util/cookie_manager.dart';

final providerBiz = StateNotifierProvider<BizService, BizModel>((ref) {
  final cookie = ref.watch(providerCookie);
  final isAuth = web.window.localStorage.getItem("auth") == "1";
  final client = Supabase.instance.client;
  return BizService(cookieManager: cookie, client: client, isAuth: isAuth);
});

enum AppName {
  stopwatch("stopwatch"), // 각 enum 값에 String 리터럴을 바로 전달
  todo("Todo Calendar");

  final String value; // String 값을 저장할 필드 선언
  const AppName(this.value); // 생성자 선언
}

class BizService extends StateNotifier<BizModel> {
  final SupabaseClient client;
  final CookieManager cookieManager;
  final visit_log = "visit_log";

  BizService({
    required this.cookieManager,
    required this.client,
    required bool isAuth,
  }) : super(BizModel(isAuth: isAuth)) {
    fetchVisitLog(1);
  }

  String? getCookie() {
    return cookieManager.getCookie("auth");
  }

  void login({required String text}) {
    if (text != "1231234") return;
    web.window.localStorage.setItem("auth", "1");

    cookieManager.setCookie("auth", "1231234");
    state = state.copyWith(isAuth: true);
  }

  int getVisitCount({required AppName appName}) {
    return state.visitLog
            ?.where((x) => x["app_name"] == appName.value)
            .length ??
        0;
  }

  Future<void> fetchVisitLog(int days) async {
    final threeDaysAgo = DateTime.now().subtract(Duration(days: days)).toUtc();

    final response = await client
        .from(visit_log)
        .select()
        .gt("created_at", threeDaysAgo.toIso8601String())
        .order('created_at', ascending: false)
        .limit(20);
    state = state.copyWith(visitLog: response.toList());
  }

  Future<void> detailLog({required String id}) async {
    final response = await client
        .from(visit_log)
        .select()
        .eq("user_id", id)
        .order('created_at', ascending: false);
    final count = response.length;
    final visit =
        state.visitLog?.map((item) {
          if (item["user_id"] == id) {
            item["count"] = count;
          } else {
            item["count"] = 0;
          }
          return item;
        }).toList() ??
        [];
    state = state.copyWith(detailLog: response.toList());
  }
}
