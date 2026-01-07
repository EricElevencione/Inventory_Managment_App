// Main Entry Point - Inventory Management App
// Initializes services and sets up navigation structure

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/add_edit_product_screen.dart';
import 'screens/settings_screen.dart';

/// Main entry point for the application
void main() async {
  // Ensure Flutter is initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage service (Hive database)
  await StorageService().init();

  // Run the app
  runApp(const InventoryApp());
}

/// Root widget for the Inventory Management App
///
/// Sets up theming, navigation, and the main scaffold structure
/// with a bottom navigation bar.
class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title (shown in task switcher)
      title: 'Inventory Manager',

      // Hide debug banner
      debugShowCheckedModeBanner: false,

      // Apply custom theme
      theme: AppTheme.lightTheme,

      // Main home widget
      home: const MainScreen(),
    );
  }
}

/// Main screen with bottom navigation
///
/// Contains the primary navigation structure with tabs for:
/// - Dashboard (home/overview)
/// - Products (list view)
/// - Settings
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Current selected tab index
  int _currentIndex = 0;

  // Page controller for smooth transitions
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle tab selection
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe navigation
        children: [
          // Dashboard/Home Screen
          DashboardScreen(
            onNavigateToTab: _onTabSelected,
          ),

          // Products List Screen
          const ProductListScreen(),

          // Settings Screen
          const SettingsScreen(),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(),

      // Floating Action Button (visible only on Dashboard)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddProduct(),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Build the bottom navigation bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        backgroundColor: Colors.white,
        elevation: 0,
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  /// Navigate to add product screen
  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    );

    // Refresh if product was added
    if (result == true) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}
