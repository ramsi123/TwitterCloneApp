import 'package:flutter/material.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/pages/account_settings_page.dart';
import 'package:twitter_clone_app/pages/home_page.dart';
import 'package:twitter_clone_app/pages/post_page.dart';
import 'package:twitter_clone_app/pages/profile_page.dart';
import '../pages/blocked_users_page.dart';

// go to user page
void goUserPage(BuildContext context, String uid) {
  // navigate to the page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

// go to post page
void goPostPage(BuildContext context, Post post) {
  // navigate to the page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post),
    ),
  );
}

// go to blocked users page
void goBlockedUsersPage(BuildContext context) {
  // Navigate to page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlockedUsersPage(),
    ),
  );
}

// go to account settings page
void goAccountSettingsPage(BuildContext context) {
  // Navigate to page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AccountSettingsPage(),
    ),
  );
}

// go home page ( but remove all previous routes, this is good for reload )
void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const HomePage(),
    ),

    // keep the first route (auth gate)
    (route) => route.isFirst,
  );
}
