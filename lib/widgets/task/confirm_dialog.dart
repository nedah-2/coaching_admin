import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  const ConfirmDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titlePadding: const EdgeInsets.only(top: 32, left: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      title: Text(
        title,
        style: const TextStyle(fontSize: 21),
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 17),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('NO'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('YES'),
        ),
      ],
    );
  }
}
