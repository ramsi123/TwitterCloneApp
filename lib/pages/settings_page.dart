import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/components/my_settings_tile.dart';
import 'package:twitter_clone_app/themes/theme_provider.dart';

import '../helper/navigate_pages.dart';

/*

SETTINGS PAGE

- Dark mode
- Blocked users
- Account settings

*/

class SettingsPage extends StatelessWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const SettingsPage());

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // App Bar
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      // Body
      body: Column(
        children: [
          MySettingsTile(
            title: "Dark Mode",
            action: CupertinoSwitch(
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ),

          // Block users tile
          MySettingsTile(
            title: 'Blocked Users',
            action: IconButton(
              onPressed: () => goBlockedUsersPage(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Account settings tile
          MySettingsTile(
            title: 'Account Settings',
            action: IconButton(
              onPressed: () => goAccountSettingsPage(context),
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
