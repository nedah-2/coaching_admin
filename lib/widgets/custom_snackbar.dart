// Function to show sign-in error snack bar
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    content: Text(text),
    duration: const Duration(seconds: 2),
  );

  // Show the snack bar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
