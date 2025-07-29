import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

// ======== 메뉴 데이터 구조 ========
class SideMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final List<SideMenuItem>? children;
  final bool initiallyExpanded;
  final bool selected;

  SideMenuItem({
    required this.label,
    required this.icon,
    this.onTap,
    this.children,
    this.initiallyExpanded = false,
    this.selected = false,
  });
}

// ======== 사이드 메뉴 데이터 선언 ========
final List<SideMenuItem> sideMenuData = [
  SideMenuItem(
    label: '대시보드',
    icon: Icons.home_rounded,
    onTap: () {}, // 대시보드 이동 (여기에 라우터 붙이면 됨)
    selected: true,
  ),
  SideMenuItem(
    label: '개발툴 모음',
    icon: Icons.code,
    initiallyExpanded: true,
    children: [
      SideMenuItem(label: 'JSON 뷰어', icon: Icons.bug_report, onTap: () {}),
      // SideMenuItem(label: 'HTTP 테스트', icon: Icons.http, onTap: () {}),
      // SideMenuItem(label: 'Diff 툴', icon: Icons.compare_arrows, onTap: () {}),
      // SideMenuItem(label: 'CSS 뷰어', icon: Icons.format_paint, onTap: () {}),
    ],
  ),
  // SideMenuItem(
  //   label: '디자인툴 모음',
  //   icon: Icons.design_services,
  //   children: [
  //     SideMenuItem(label: '컬러 피커', icon: Icons.palette, onTap: () {}),
  //     SideMenuItem(label: '이미지 크롭', icon: Icons.wallpaper, onTap: () {}),
  //     SideMenuItem(label: '폰트 뷰어', icon: Icons.text_fields, onTap: () {}),
  //   ],
  // ),
];

// ======== MasterScreen 최상단 위젯 ========
class MasterScreen extends HookConsumerWidget {
  final Widget child;

  const MasterScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: Row(
              children: [
                const _SideDrawer(),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Center(child: child),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======== 상단 탑바 (브라우저 북마크 버튼 포함) ========
class _TopBar extends StatelessWidget {
  const _TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 36,
            height: 36,
            color: Colors.black,
          ),
          12.widthBox,
          Text(
            "heys.dev",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
              letterSpacing: -1,
            ),
          ),
          36.widthBox,
          SizedBox(
            width: 260,
            child: TextField(
              decoration: InputDecoration(
                hintText: "검색…",
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color: Colors.grey[700],
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          36.widthBox,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.campaign_outlined, color: Colors.indigo, size: 20),
                6.widthBox,
                const Text(
                  "Welcome, 오늘도 화이팅!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
          36.widthBox,
          // ⭐️ 브라우저 북마크 안내 버튼
          TextButton.icon(
            icon: Icon(Icons.star_border, color: Colors.amber[700]),
            label: const Text(
              "북마크에 추가",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber[50],
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              final isMac = Theme.of(context).platform == TargetPlatform.macOS;
              final shortcut = isMac ? 'Cmd + D' : 'Ctrl + D';

              // 주소 자동 복사
              js.context.callMethod('eval', [
                "navigator.clipboard && navigator.clipboard.writeText(window.location.href)",
              ]);

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(
                    '브라우저 즐겨찾기 안내',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    "이 사이트를 브라우저 즐겨찾기에 추가하려면\n\n"
                    "$shortcut 단축키를 눌러주세요!\n\n"
                    "또는 주소가 자동 복사되었습니다. 원하는 곳에 붙여넣기 하세요.",
                    style: const TextStyle(fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ======== 데이터 기반 사이드 드로어 ========
class _SideDrawer extends StatefulWidget {
  const _SideDrawer({super.key});

  @override
  State<_SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<_SideDrawer> {
  late Map<String, bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {
      for (final m in sideMenuData)
        if ((m.children?.isNotEmpty ?? false)) m.label: m.initiallyExpanded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.1,
          ),
        ),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 18),
          ...sideMenuData.map((item) {
            // === 대시보드만 플랫/강조 ===
            if ((item.children == null || item.children!.isEmpty) &&
                item.label == '대시보드') {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: item.onTap,
                  hoverColor: Colors.indigo.withOpacity(0.08),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.selected
                          ? Colors.indigo[700]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 26,
                          color: item.selected
                              ? Colors.white
                              : Colors.indigo[700],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.selected
                                ? Colors.white
                                : Colors.indigo[700],
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // 그 외 일반 메뉴
            if (item.children == null || item.children!.isEmpty) {
              return _DrawerMenuItem(
                icon: item.icon,
                label: item.label,
                selected: item.selected,
                onTap: item.onTap,
              );
            }

            final isDesign = item.label.contains("디자인");
            return ExpansionTile(
              leading: Icon(
                item.icon,
                color: isDesign ? Colors.pink[400] : Colors.indigo,
              ),
              title: Text(
                item.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDesign ? Colors.pink[400] : Colors.indigo,
                ),
              ),
              initiallyExpanded: item.initiallyExpanded,
              onExpansionChanged: (v) =>
                  setState(() => _expanded[item.label] = v),
              children: item.children!
                  .map(
                    (sub) => _DrawerMenuSubItem(
                      icon: sub.icon,
                      label: sub.label,
                      onTap: sub.onTap,
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ======== 사이드 메뉴 단일 아이템 ========
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.indigo : Colors.grey[800];
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
      selected: selected,
      selectedTileColor: Colors.indigo.withOpacity(0.09),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      minLeadingWidth: 28,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
    );
  }
}

// ======== 사이드 메뉴 서브 아이템 ========
class _DrawerMenuSubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DrawerMenuSubItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 21),
      title: Text(
        label,
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
      ),
      onTap: onTap,
      minLeadingWidth: 20,
      contentPadding: const EdgeInsets.only(left: 34, right: 10),
      hoverColor: Colors.indigo.withOpacity(0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    );
  }
}
