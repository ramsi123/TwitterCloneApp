/*

USER LIST TILE

This is to display user as a nice tile. We will use this when we need to display
a list of users, for e.g. in the user search results or viewing the followers
of a user.

--------------------------------------------------------------------------------

To use this widget, you need:

- a user

*/

import 'package:flutter/material.dart';
import 'package:twitter_clone_app/models/user.dart';
import 'package:twitter_clone_app/pages/profile_page.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;
  const MyUserTile({
    super.key,
    required this.user,
  });

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // Container
    return Container(
      // Padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),

      // Padding inside
      padding: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        // Color of tile
        color: Theme.of(context).colorScheme.secondary,

        // Curve corners
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        // Name
        title: Text(user.name),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),

        // Username
        subtitle: Text('@${user.username}'),
        subtitleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),

        // Profile pic
        leading: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
        ),

        // on tap -> go to user's profile
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: user.uid),
          ),
        ),

        // arrow forward icon
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
