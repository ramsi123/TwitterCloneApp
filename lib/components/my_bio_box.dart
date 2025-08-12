import 'package:flutter/material.dart';

/*

USER BIO BOX

This is a simple box with text inside. We will use this for the user bio on
their profile pages.

--------------------------------------------------------------------------------

To use this widget, you just need:

- Text

*/

class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding outside
      margin: const EdgeInsets.symmetric(horizontal: 25),

      // Padding inside
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        // Color
        color: Theme.of(context).colorScheme.secondary,

        // Curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      // Text
      child: Text(
        text.isNotEmpty ? text : 'Empty bio..',
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
