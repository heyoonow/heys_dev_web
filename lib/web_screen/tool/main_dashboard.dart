import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heys_dev_web/provider/tool/tool_service.dart';

// Tool card data model (with route for navigation)
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

// Dashboard main page (fixed size tool cards)
class DashboardMainPage extends StatelessWidget {
  const DashboardMainPage({super.key});

  List<ToolCardData> get _tools => ToolService.getToolCards();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Dashboard Title (Statistics card is commented for example)
          Row(
            children: [
              Text(
                "✨ Tools Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
              const Spacer(),
              // Example stat cards (uncomment to use)
              // _DashboardStatCard(
              //   icon: Icons.show_chart,
              //   label: "Visitors Today",
              //   value: "132",
              //   color: Colors.green,
              // ),
              // const SizedBox(width: 14),
              // _DashboardStatCard(
              //   icon: Icons.feedback_outlined,
              //   label: "Feedback",
              //   value: "9",
              //   color: Colors.orange,
              // ),
            ],
          ),
          const SizedBox(height: 26),
          // Tool card grid
          Expanded(
            child: GridView.builder(
              itemCount: _tools.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 210,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
              ),
              itemBuilder: (context, idx) {
                final tool = _tools[idx];
                return ToolDashboardCard(
                  tool: tool,
                  onTap: () {
                    print('Tool selected: ${tool.route}');
                    if (tool.route != null) {
                      context.go(tool.route!); // Using go_router navigation
                      // Navigator.of(context).pushNamed(tool.route!); // If using Navigator
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

// Tool card widget (fixed size, shadow + border + rounded)
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
      0.12,
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
                // Card content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + category
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
                // Bottom right: category badge
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

// Example stat card (design unchanged, just in English)
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
