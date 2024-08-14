import 'package:flutter/material.dart';

void showConfirmationDialog(
  BuildContext context,
  String title,
  String content,
  String action,
  Future<void> Function() onConfirm,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.all(20),
        titlePadding: const EdgeInsets.only(top: 32, left: 20),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(action),
            onPressed: () async {
              Navigator.of(context).pop();
              showLoadingDialog(context, action, onConfirm);
            },
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(
  BuildContext context,
  String action,
  Future<void> Function() onConfirm,
) async {
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
  await onConfirm();
}


// void showDeleteConfirmationDialog(
//     BuildContext context, Future<void> Function() onDelete) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Confirm Deletion',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         content: const Text('Are you sure you want to delete this playlist?'),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: const Text('Delete'),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await onDelete();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
