import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final String selectedPage;
  final VoidCallback? onDashboard;
  final VoidCallback? onMessungen;
  final VoidCallback? onAnalyse;
  final VoidCallback? onFragAI;

  const AppSidebar({
    super.key,
    required this.selectedPage,
    this.onDashboard,
    this.onMessungen,
    this.onAnalyse,
    this.onFragAI,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF172554),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'QS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Farbanalyse',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 35),

              _sidebarItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                pageName: 'Dashboard',
                onTap: onDashboard,
              ),

              _sidebarItem(
                icon: Icons.search,
                label: 'Messungen',
                pageName: 'Messungen',
                onTap: onMessungen,
              ),

              _sidebarItem(
                icon: Icons.bar_chart,
                label: 'Analyse',
                pageName: 'Analyse',
                onTap: onAnalyse,
              ),

              _sidebarItem(
                icon: Icons.auto_awesome,
                label: 'Frag AI...',
                pageName: 'Frag AI',
                onTap: onFragAI,
              ),

              _sidebarItem(
                icon: Icons.settings_outlined,
                label: 'Einstellungen',
                pageName: 'Einstellungen',
              ),

              const Spacer(),

              _sidebarItem(
                icon: Icons.help_outline,
                label: 'Hilfe',
                pageName: 'Hilfe',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required String pageName,
    VoidCallback? onTap,
  }) {
    final selected = selectedPage == pageName;

    final item = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF315A8A)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return item;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: item,
      ),
    );
  }
}
