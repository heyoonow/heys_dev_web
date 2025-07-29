import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heys_dev_web/web_screen/tool/tools/json_viewer.dart';

// ───────── Tool 정보에 route 포함 (onTap은 위젯단에서 처리)
class ToolCardData {
  final IconData icon;
  final String label;
  final String subtitle;
  final String category;
  final Color categoryColor;
  final String? route;

  const ToolCardData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.category,
    required this.categoryColor,
    this.route,
  });
}

// ───────── 대시보드 메인 (카드 고정크기)
class DashboardMainPage extends StatelessWidget {
  const DashboardMainPage({super.key});

  List<ToolCardData> get _tools => [
    ToolCardData(
      icon: Icons.code,
      label: "JSON 뷰어",
      subtitle: "JSON 포맷/뷰/검증/트리뷰",
      category: "개발툴",
      categoryColor: Colors.indigo,
      route: '/${JsonViewerScreen.routeName}',
    ),
    // ToolCardData(
    //   icon: Icons.http,
    //   label: "HTTP 테스트",
    //   subtitle: "API 응답/헤더 확인",
    //   category: "개발툴",
    //   categoryColor: Colors.indigo,
    //   route: "/http",
    // ),
    // ToolCardData(
    //   icon: Icons.compare_arrows,
    //   label: "Diff 툴",
    //   subtitle: "텍스트/코드 비교",
    //   category: "개발툴",
    //   categoryColor: Colors.indigo,
    //   route: "/diff",
    // ),
    // ToolCardData(
    //   icon: Icons.format_paint,
    //   label: "CSS 뷰어",
    //   subtitle: "스타일 구조 시각화",
    //   category: "개발툴",
    //   categoryColor: Colors.indigo,
    //   route: "/css",
    // ),
    // ToolCardData(
    //   icon: Icons.palette,
    //   label: "컬러피커",
    //   subtitle: "컬러 추출/변환",
    //   category: "디자인툴",
    //   categoryColor: Colors.pink,
    //   route: "/color",
    // ),
    // ToolCardData(
    //   icon: Icons.wallpaper,
    //   label: "이미지 크롭",
    //   subtitle: "이미지 자르기/리사이즈",
    //   category: "디자인툴",
    //   categoryColor: Colors.pink,
    //   route: "/image-crop",
    // ),
    // ToolCardData(
    //   icon: Icons.text_fields,
    //   label: "폰트 뷰어",
    //   subtitle: "폰트 스타일 미리보기",
    //   category: "디자인툴",
    //   categoryColor: Colors.pink,
    //   route: "/font",
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보(오늘 방문자/피드백 등)
          Row(
            children: [
              Text(
                "✨ 툴 대시보드",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
              const Spacer(),
              // 예시용 통계카드 (주석 해제하면 됨)
              // _DashboardStatCard(
              //   icon: Icons.show_chart,
              //   label: "오늘 방문자",
              //   value: "132",
              //   color: Colors.green,
              // ),
              // const SizedBox(width: 14),
              // _DashboardStatCard(
              //   icon: Icons.feedback_outlined,
              //   label: "피드백",
              //   value: "9건",
              //   color: Colors.orange,
              // ),
            ],
          ),
          const SizedBox(height: 26),
          // 툴 카드 그리드
          Expanded(
            child: GridView.builder(
              itemCount: _tools.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320, // 카드 1개 가로 최대폭 320px
                mainAxisExtent: 210, // 카드 세로높이 210px
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
              ),
              itemBuilder: (context, idx) {
                final tool = _tools[idx];
                return ToolDashboardCard(
                  tool: tool,
                  onTap: () {
                    print('툴 선택: ${tool.route}');
                    if (tool.route != null) {
                      context.go(tool.route!); // gor_router 사용 예시
                      // Navigator.of(context).pushNamed(tool.route!); // Navigator 사용 예시
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────── 카드 위젯 (고정크기, 입체+테두리+라운드)
class ToolDashboardCard extends StatelessWidget {
  final ToolCardData tool;
  final VoidCallback? onTap;

  const ToolDashboardCard({required this.tool, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.fromRGBO(
      tool.categoryColor.red,
      tool.categoryColor.green,
      tool.categoryColor.blue,
      0.12, // (withOpacity 디프리케이트 방지)
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE7EAF0),
          width: 1.1,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                // 카드 본문
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 아이콘+카테고리
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: bgColor,
                      child: Icon(
                        tool.icon,
                        color: tool.categoryColor,
                        size: 19,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      tool.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // 오른쪽 아래 카테고리 뱃지
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tool.categoryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tool.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────── 상단 간단한 통계 카드(디자인은 그대로)
class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Color.fromRGBO(color.red, color.green, color.blue, 0.11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
