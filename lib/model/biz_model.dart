class BizModel {
  final bool isAuth;
  final List<Map<String, dynamic>>? visitLog;
  final List<Map<String, dynamic>>? detailLog;

  BizModel({
    required this.isAuth,
    this.visitLog,
    this.detailLog,
  });

  factory BizModel.init() {
    return BizModel(isAuth: false);
  }

  BizModel copyWith({
    bool? isAuth,
    List<Map<String, dynamic>>? visitLog,
    List<Map<String, dynamic>>? detailLog,
  }) {
    return BizModel(
      isAuth: isAuth ?? this.isAuth,
      visitLog: visitLog ?? this.visitLog,
      detailLog: detailLog ?? this.detailLog,
    );
  }
}
