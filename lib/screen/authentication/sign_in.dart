import 'package:coaching_admin/provider/auth_provider.dart';
import 'package:coaching_admin/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context, listen: true);

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          //  padding: const EdgeInsets.fromLTRB(24, 128, 24, 24),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image.asset('assets/orders.png'),
              Container(
                color: Colors.grey.shade300,
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 40),
              _buildSignInForm(context, authManager),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context, AuthManager authManager) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              controller: userController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                prefixIcon: Icon(Icons.account_circle),
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              controller: passwordController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                labelText: 'Password',
                border: const OutlineInputBorder(),
              ),
              obscureText: isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                // Call the function to handle form submission here
                _submitForm(authManager);
              },
            ),
            // const SizedBox(height: 16),
            // _buildForgotPasswordLink(context),
            const SizedBox(height: 24),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size.fromHeight(40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onPressed: authManager.isLoading
                    ? null
                    : () async {
                        _submitForm(authManager);
                      },
                child: authManager.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ))
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm(AuthManager authManager) async {
    if (formKey.currentState!.validate()) {
      try {
        // Perform sign-in
        await authManager.signInWithEmailAndPassword(
          userController.text.trim(),
          passwordController.text.trim(),
        );
      } catch (e) {
        if (mounted) showSnackBar(context, 'Sign in failed. Please try again.');
        userController.clear();
        passwordController.clear();
      }
    }
  }
}
