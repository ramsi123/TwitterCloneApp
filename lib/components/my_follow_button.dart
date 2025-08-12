/*

FOLLOW BUTTON

This is a follow / unfollow button, depending on whose profile page we are
currently viewing.

--------------------------------------------------------------------------------

To use this widget, you need:

- a function ( e.g. toggleFollow() when the button is pressed )
- isFollowing ( e.g. false -> then we will show follow button instead of
  unfollow button )

*/

import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const MyFollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // Padding outside
    return Padding(
      padding: const EdgeInsets.all(25),

      // Curve corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        // Material button
        child: MaterialButton(
          // Padding inside
          padding: const EdgeInsets.all(25),
          onPressed: onPressed,

          // Color
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,

          // Text
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
