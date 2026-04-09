import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../screens/product_list_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/all_transactions_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context); // close drawer
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    color: Colors.white, size: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppConstants.appName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Text('Manage your stock',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          _Item(
            icon: Icons.list_alt,
            label: 'Products',
            isSelected: currentRoute == 'products',
            onTap: () => _go(context, const ProductListScreen()),
          ),
          _Item(
            icon: Icons.bar_chart,
            label: 'Summary',
            isSelected: currentRoute == 'summary',
            onTap: () => _go(context, const SummaryScreen()),
          ),
          _Item(
            icon: Icons.history,
            label: 'All Transactions',
            isSelected: currentRoute == 'transactions',
            onTap: () => _go(context, const AllTransactionsScreen()),
          ),

          const Divider(),
          const Spacer(),

          _Item(
            icon: Icons.logout,
            label: 'Logout',
            isSelected: false,
            onTap: () => _go(context, const LoginScreen()),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primary : null),
      title: Text(label,
          style: TextStyle(
              color: isSelected ? AppTheme.primary : null,
              fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      selectedTileColor: AppTheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
