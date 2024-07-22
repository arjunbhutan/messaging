import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaing/components/my_button.dart';
import 'package:messaing/components/my_textfield.dart';
import '../helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  void registerUser() async {
    // Check if any of the fields are empty
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPwController.text.isEmpty) {
      displayMessageToUser("Please enter all the details to register", context);
      return;
    }

    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordController.text != confirmPwController.text) {
      // Pop loading circle
      Navigator.pop(context);
      // Show error message to user
      displayMessageToUser("Passwords don't match", context);
      return; // Early return since passwords don't match
    }

    // Try creating the user
    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Create a user document and add to Firestore
      createUserDocument(userCredential);

      // Pop loading circle
      if (context.mounted) Navigator.pop(context);

      // Optionally, navigate to another page or show success message
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      // Display error message to user
      displayMessageToUser(e.message ?? "An error occurred", context);
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                // App name
                const Text(
                  "Just Text",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                // Username
                MyTextfield(
                  hintText: "Username",
                  controller: usernameController,
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // Email
                MyTextfield(
                  hintText: "Email",
                  controller: emailController,
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // Password
                MyTextfield(
                  hintText: "Password",
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  hintText: "Confirm Password",
                  controller: confirmPwController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Register button
                MyButton(
                  text: "Register",
                  onTap: registerUser,
                ),
                const SizedBox(height: 25),
                // Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Login Here",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
