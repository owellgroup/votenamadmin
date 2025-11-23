import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/votenam_logo.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'candidates_management_screen.dart';
import 'vote_category_management_screen.dart';
import 'voters_card_management_screen.dart';
import 'voters_details_view_screen.dart';
import 'regions_management_screen.dart';
import 'users_management_screen.dart';
import 'login_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();

  List<Widget> get _screens => [
    DashboardScreen(key: _dashboardKey),
    const CandidatesManagementScreen(),
    const VoteCategoryManagementScreen(),
    const VotersCardManagementScreen(),
    const VotersDetailsViewScreen(),
    const RegionsManagementScreen(),
    const UsersManagementScreen(),
  ];

  final List<String> _menuItems = [
    'Dashboard',
    'Candidates',
    'Vote Categories',
    'Voter Cards',
    'Voters Details',
    'Regions',
    'Users',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (isWide) {
      // Desktop layout with sidebar
      return Scaffold(
        body: Row(
          children: [
            // Sidebar - Modern Design
            Container(
              width: 280,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Column(
                children: [
                  // Logo Section - Enhanced
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: const VotenamLogo(
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Votenam Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Namibia Voting System',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, thickness: 1),
                  // Menu Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.transparent,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForIndex(index),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              _menuItems[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              // Refresh dashboard when navigating to it
                              if (index == 0 &&
                                  _dashboardKey.currentState != null) {
                                _dashboardKey.currentState!.refresh();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Logout Button - Modern Design
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: _logout,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Area
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    } else {
      // Mobile/Tablet layout with drawer
      return Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              // Logo Header
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF41479B),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const VotenamLogo(
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Votenam Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Items
              Expanded(
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      selected: _selectedIndex == index,
                      leading: Icon(_getIconForIndex(index)),
                      title: Text(_menuItems[index]),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
                        // Refresh dashboard when navigating to it
                        if (index == 0 && _dashboardKey.currentState != null) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted) {
                              _dashboardKey.currentState!.refresh();
                            }
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const VotenamLogo(
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Text(_menuItems[_selectedIndex]),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF41479B),
          foregroundColor: Colors.white,
        ),
        body: _screens[_selectedIndex],
      );
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.person;
      case 2:
        return Icons.category;
      case 3:
        return Icons.credit_card;
      case 4:
        return Icons.list;
      case 5:
        return Icons.location_on;
      case 6:
        return Icons.people;
      default:
        return Icons.menu;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }
}

