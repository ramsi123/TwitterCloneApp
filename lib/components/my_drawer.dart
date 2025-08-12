import 'package:flutter/material.dart';
import 'package:twitter_clone_app/components/my_drawer_tile.dart';
import 'package:twitter_clone_app/pages/profile_page.dart';
import 'package:twitter_clone_app/pages/search_page.dart';
import 'package:twitter_clone_app/pages/settings_page.dart';
import '../services/auth/auth_service.dart';

/*

DRAWER

This is a menu drawer which is usually access on the left side of the app bar

--------------------------------------------------------------------------------

Contains 5 menu options:

- Home
- Profile
- Search
- Settings
- Logout

*/

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  // access auth service
  final _auth = AuthService();

  // logout
  void logout() async {
    await _auth.logout();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // Drawer
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              // app logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // divider line
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),

              const SizedBox(height: 10),

              // home list tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () {
                  // pop menu drawer since we already at home
                  Navigator.pop(context);
                },
              ),

              // profile list tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  // pop menu drawer
                  Navigator.pop(context);

                  // go to profile page
                  Navigator.push(
                    context,
                    ProfilePage.route(_auth.getCurrentUid()),
                  );
                },
              ),

              // search list tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {
                  // pop menu drawer
                  Navigator.pop(context);

                  // go to search page
                  Navigator.push(
                    context,
                    SearchPage.route(),
                  );
                },
              ),

              // settings list tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  // pop menu drawer
                  Navigator.pop(context);

                  // go to settings page
                  Navigator.push(
                    context,
                    SettingsPage.route(),
                  );
                },
              ),

              const Spacer(),

              // logout list tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: logout,
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
