import 'package:flutter/cupertino.dart';

class ToolBaseModel {
  final List<ToolModel> listTool;

  ToolBaseModel({
    required this.listTool,
  });

  static List<ToolModel> getDefaultTools() {
    return [
      ToolModel(
        name: "test",
        description: "A simple stopwatch tool.",
        icon: CupertinoIcons.timer,
      ),
    ];
  }
}

class ToolModel {
  final String name;
  final String description;
  final IconData icon;
  final bool isSelected;

  ToolModel({
    required this.name,
    required this.description,
    required this.icon,
    this.isSelected = false,
  });

  @override
  String toString() {
    return 'ToolModel(name: $name, description: $description, icon: $icon, isSelected: $isSelected)';
  }
}
