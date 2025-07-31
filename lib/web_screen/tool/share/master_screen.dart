import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../provider/tool/tool_service.dart';

// ======== Menu Item Data Structure ========
class SideMenuItem {
  final String label;
  final IconData icon;
  final String? routeName;
  final List<SideMenuItem>? children;
  final bool initiallyExpanded;
  final bool selected;

  SideMenuItem({
    required this.label,
    required this.icon,
    this.routeName,
    this.children,
    this.initiallyExpanded = false,
    this.selected = false,
  });
}

// ======== Side Menu Data ========
final List<SideMenuItem> sideMenuData = [
  SideMenuItem(
    label: 'Dashboard',
    icon: Icons.home_rounded,
    routeName: '/',
    selected: true,
  ),
  SideMenuItem(
    label: 'Tools',
    icon: Icons.code,
    initiallyExpanded: true,
    children: ToolService.getSideItems(),
  ),
  // SideMenuItem(
  //   label: 'Design Tools',
  //   icon: Icons.design_services,
  //   children: [
  //     SideMenuItem(label: 'Color Picker', icon: Icons.palette, routeName: '/color-picker'),
  //     SideMenuItem(label: 'Image Crop', icon: Icons.wallpaper, routeName: '/image-crop'),
  //     SideMenuItem(label: 'Font Viewer', icon: Icons.text_fields, routeName: '/font-viewer'),
  //   ],
  // ),
];

// ======== MasterScreen Root Widget ========
class MasterScreen extends HookConsumerWidget {
  final Widget child;

  const MasterScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: null, // No AppBar at the top
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

// ======== TopBar with Bookmark Button ========
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
          if (!context.isMobile) 36.widthBox, 10.widthBox,
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search…",
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
          if (!context.isMobile)
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
                    "Welcome, have a great day!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          if (!context.isMobile) 36.widthBox,
          // ⭐️ Bookmark Guide Button
          if (!context.isMobile)
            TextButton.icon(
              icon: Icon(Icons.star_border, color: Colors.amber[700]),
              label: const Text(
                "Add to bookmarks",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber[50],
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                final isMac =
                    Theme.of(context).platform == TargetPlatform.macOS;
                final shortcut = isMac ? 'Cmd + D' : 'Ctrl + D';

                // Copy current url to clipboard
                js.context.callMethod('eval', [
                  "navigator.clipboard && navigator.clipboard.writeText(window.location.href)",
                ]);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text(
                      'How to Bookmark',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      "To bookmark this site, press\n\n"
                      "$shortcut\n\n"
                      "or the address has been copied. Paste it wherever you want.",
                      style: const TextStyle(fontSize: 15),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!context.isMobile) const Spacer(),
        ],
      ),
    );
  }
}

// ======== Data-driven Side Drawer ========
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
      width: context.isMobile ? 0 : 200,
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
            // === Dashboard only: flat & highlighted
            if ((item.children == null || item.children!.isEmpty) &&
                item.label == 'Dashboard') {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: _DrawerMenuItem(
                  icon: item.icon,
                  label: item.label,
                  routeName: item.routeName,
                  selected: item.selected,
                ),
              );
            }

            // Other items
            if (item.children == null || item.children!.isEmpty) {
              return _DrawerMenuItem(
                icon: item.icon,
                label: item.label,
                routeName: item.routeName,
                selected: item.selected,
              );
            }

            final isDesign = item.label.contains("Design");
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
                      routeName: sub.routeName,
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

// ======== Side Menu Single Item (context.go) ========
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? routeName;
  final bool selected;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.selected,
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
      onTap: routeName != null
          ? () =>
                context.go(routeName!) // ⭐️ Use go_router for navigation
          : null,
      minLeadingWidth: 28,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
    );
  }
}

// ======== Side Menu Sub Item (context.go) ========
class _DrawerMenuSubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? routeName;

  const _DrawerMenuSubItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 21),
      title: Text(
        label,
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
      ),
      onTap: routeName != null ? () => context.go(routeName!) : null,
      minLeadingWidth: 20,
      contentPadding: const EdgeInsets.only(left: 34, right: 10),
      hoverColor: Colors.indigo.withOpacity(0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    );
  }
}
