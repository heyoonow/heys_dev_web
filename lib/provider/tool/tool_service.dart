import 'package:flutter/material.dart';
import 'package:heys_dev_web/web_screen/tool/tools/json_viewer.dart';

import '../../web_screen/tool/main_dashboard.dart';
import '../../web_screen/tool/share/master_screen.dart';
import '../../web_screen/tool/tools/jwt_viewer.dart';

class ToolService {
  ToolService();

  static List<ServiceMoel> get services => [
    ServiceMoel(
      title: "JSON Viewer",
      description: "Format / View / Validate / Tree for JSON",
      category: "Dev Tools",
      categoryColor: Colors.indigo,
      route: '/${JsonViewerScreen.routeName}',
      iconData: Icons.code,
    ),
    ServiceMoel(
      title: "JWT Decoder",
      description:
          "Decode, View, and Validate JWT Tokens easily. Check header, payload, and verify signature instantly.",
      category: "Dev Tools",
      categoryColor: Colors.indigo,
      route: '/${JwtViewerScreen.routeName}',
      iconData: Icons.verified_user, // 또는 적당한 JWT 아이콘 사용
    ),

    // ServiceMoel(
    //   title: "HTTP Tester",
    //   description: "Check API Response / Headers",
    //   category: "Dev Tools",
    //   categoryColor: Colors.indigo,
    //   route: "/http",
    //   iconData: Icons.http,
    // ),
    // ServiceMoel(
    //   title: "Diff Tool",
    //   description: "Compare Text / Code",
    //   category: "Dev Tools",
    //   categoryColor: Colors.indigo,
    //   route: "/diff",
    //   iconData: Icons.compare_arrows,
    // ),
    // ServiceMoel(
    //   title: "CSS Viewer",
    //   description: "Visualize CSS Structure",
    //   category: "Dev Tools",
    //   categoryColor: Colors.indigo,
    //   route: "/css",
    //   iconData: Icons.format_paint,
    // ),
  ];

  static List<SideMenuItem> getSideItems() {
    return services
        .map(
          (e) => SideMenuItem(
            label: e.title,
            icon: e.iconData,
            routeName: e.route,
          ),
        )
        .toList();
  }

  static List<ToolCardData> getToolCards() {
    return services
        .map(
          (e) => ToolCardData(
            icon: e.iconData,
            label: e.title,
            subtitle: e.description,
            category: e.category,
            categoryColor: e.categoryColor,
            route: e.route,
          ),
        )
        .toList();
  }
}

class ServiceMoel {
  String title;
  String description;
  String category;
  Color categoryColor;
  String route;
  IconData iconData;

  ServiceMoel({
    required this.title,
    required this.description,
    required this.category,
    required this.categoryColor,
    required this.route,
    required this.iconData,
  });
}
