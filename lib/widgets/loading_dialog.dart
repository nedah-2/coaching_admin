import 'package:flutter/material.dart';

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        content: const Row(
          children: [
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
            SizedBox(width: 24),
            Text("Please Wait..."),
          ],
        ),
      );
    },
  );
}
