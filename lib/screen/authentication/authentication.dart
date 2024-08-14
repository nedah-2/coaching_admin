import 'package:coaching_admin/home.dart';
import 'package:coaching_admin/provider/auth_provider.dart';
import 'package:coaching_admin/screen/authentication/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthManager>(
      builder: (context, authProvider, _) {
        if (authProvider.user == null) {
          return const SignInScreen();
        } else {
          return HomePage();
        }
      },
    );
  }
}
