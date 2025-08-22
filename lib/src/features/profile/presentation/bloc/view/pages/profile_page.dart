import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/router/route_const.dart';
import '../../../../../../services/service_locator.dart';
import '../../../../../../shared/constants/color_constants.dart';
import '../../../../../../shared/services/snackbar_service.dart';
import '../../../../../../shared_pref_services/shared_pref_base_service.dart';
import '../../../../../../shared_pref_services/shared_pref_keys.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<String> _name = ValueNotifier('');
  final ValueNotifier<String> _email = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final sharedPref = serviceLocator<SharedPreferenceBaseService>();
    final savedName = await sharedPref.getAttribute(SharedPrefKeys.name, '');
    final email = await sharedPref.getAttribute(SharedPrefKeys.email, '');
    _name.value = savedName;
    _email.value = email;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.logout,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                      _performLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _performLogout(BuildContext context) {
    context.read<AuthBloc>().add(OnLogout());
    context.goNamed(RouteConst.splashScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: ColorConst.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // User Profile Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: _name,
                        builder: (context, value, _) => Text(
                          value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: _email,
                        builder: (context, value, _) => Text(
                          value,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final result = await context.pushNamed<bool>(RouteConst.setupProfile, extra: false);
                          if (result == true) {
                            _loadUserData();
                          }
                        },
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Account Settings
          _buildSectionHeader("Account Settings"),
          _buildTile("Profile Management", Icons.manage_accounts,
          onTap: () {
            serviceLocator<SnackBarService>().showInfo(
              message: 'Coming Soon!!',
            );
          }),
          _buildTile("Notifications", Icons.notifications,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),
          _buildTile("Privacy Settings", Icons.lock,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }
          ),
          _buildTile("Connected Calendars", Icons.calendar_today,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),

          const SizedBox(height: 12),

          // App Actions
          _buildSectionHeader("App Actions"),
          _buildTile("Share ClearVisit for iPhone", Icons.ios_share,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),
          _buildTile("Get ClearVisit for Desktop", Icons.computer,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),
          _buildTile(
            "Subscriptions",
            Icons.subscriptions,
            trailing:
            const Text("SOON", style: TextStyle(color: Colors.grey)),
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }
          ),

          const SizedBox(height: 12),

          // Support Options
          _buildSectionHeader("Support"),
          _buildTile("Send Feedback", Icons.feedback,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),
          _buildTile("Report a Bug", Icons.bug_report,
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),
          _buildTile("Help Center", Icons.help_outline,
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                serviceLocator<SnackBarService>().showInfo(
                  message: 'Coming Soon!!',
                );
              }),

          const SizedBox(height: 12),
          // My Doctors
          _buildSectionHeader("My Doctors"),
          _buildTile("My Doctors", Icons.local_hospital, onTap: () {
            context.pushNamed(RouteConst.doctorsListingPage);
          }),
          
          const SizedBox(height: 12),
          
          // Logout Section
          _buildSectionHeader("Account"),
          Container(
            color: Colors.red,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                _showLogoutConfirmation(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon,
      {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: Colors.black),
        onTap: onTap,
      ),
    );
  }
}
