class BizModel {
  final bool isAuth;
  final List<Map<String, dynamic>>? visitLog;

  BizModel({required this.isAuth, this.visitLog});

  factory BizModel.init() {
    return BizModel(isAuth: false);
  }

  BizModel copyWith({bool? isAuth, List<Map<String, dynamic>>? visitLog}) {
    return BizModel(
      isAuth: isAuth ?? this.isAuth,
      visitLog: visitLog ?? this.visitLog,
    );
  }
}
