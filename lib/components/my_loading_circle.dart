import 'package:flutter/material.dart';

// show loading circle
void showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

// hide loading circle
void hideLoadingCircle(BuildContext context) {
  Navigator.pop(context);
}
