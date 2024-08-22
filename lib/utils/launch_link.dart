import 'package:coaching_admin/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

Future<void> sendEmail(BuildContext context, String email) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: email,
    query: encodeQueryParameters(<String, String>{
      'subject': '',
    }),
  );

  try {
    await launchUrl(emailLaunchUri);
  } catch (e) {
    if (context.mounted) {
      showSnackBar(context, 'Failed to send email');
    }
  }
}

Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  try {
    await launchUrl(launchUri);
  } catch (e) {
    if (context.mounted) {
      showSnackBar(context, 'Failed to make phone call');
    }
  }
}

Future<void> launchURL(BuildContext context, String websiteUrl) async {
  final url = Uri.parse(websiteUrl);
  try {
    await launchUrl(url);
  } catch (e) {
    // Handle Error
    if (context.mounted) {
      showSnackBar(context, 'Something went wrong! Try again later...');
    }
    return;
  }
}
