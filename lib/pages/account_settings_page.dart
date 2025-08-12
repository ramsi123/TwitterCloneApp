/*

ACCOUNT SETTINGS PAGE

This page contains various settings related to user account.

- delete own account (This feature is a requirement if you want to publish this
  to the app store!)

*/

import 'package:flutter/material.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // ask for confirmation from the user before deleting their account
  void confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text('Are you sure you want to delete this account?'),
          actions: [
            // cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            // delete button
            TextButton(
              onPressed: () async {
                // delete account user
                await AuthService().deleteAccount();

                // then navigate to initial route (Auth gate => login / register
                // page)
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // App Bar
      appBar: AppBar(
        title: const Text('Account Settings'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),

      // Body
      body: Column(
        children: [
          // Delete tile
          GestureDetector(
            onTap: () => confirmDeletion(context),
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
