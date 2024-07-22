import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaing/components/my_button.dart';
import 'package:messaing/components/my_textfield.dart';
import '../helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for email and password text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Method to handle login
  void login() async {
    // Get email and password from text fields and trim any whitespace
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check if email and password fields are empty
    if (email.isEmpty || password.isEmpty) {
      // Display message to user to enter email and password
      displayMessageToUser("Please enter email and password", context);
      return;
    }

    // Show loading dialog while attempting to log in
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Attempt to sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If login is successful, pop the loading dialog
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Pop the loading dialog if an error occurs
      Navigator.pop(context);

      // Log the error code for debugging purposes
      print('FirebaseAuthException code: ${e.code}');

      // Check the error code and display appropriate message
      if (e.code == 'user-not-found') {
        // Display specific message if user is not found
        displayMessageToUser("You need to register first.", context);
      } else if (e.code == 'wrong-password') {
        // Display specific message if the password is wrong
        displayMessageToUser("Invalid credentials.", context);
      } else if (e.code == 'invalid-email') {
        // Handle invalid email format
        displayMessageToUser("The email address is not valid.", context);
      } else if (e.code == 'user-disabled') {
        // Handle disabled user account
        displayMessageToUser("This user account has been disabled.", context);
      } else {
        // Display a general error message for other errors
        displayMessageToUser("An error occurred: ${e.message}", context);
      }
    } catch (e) {
      // Handle any other errors that might occur
      Navigator.pop(context);
      displayMessageToUser("An unexpected error occurred: ${e.toString()}", context);
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
                // Icon for the login page
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                // App name
                const Text(
                  "Hi! Text your team",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                // Email text field
                MyTextfield(
                  hintText: "email",
                  controller: emailController,
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // Password text field
                MyTextfield(
                  hintText: "password",
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // Forgot password text
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
                // Login button
                MyButton(text: "Login", onTap: login),
                const SizedBox(height: 25),
                // Option to navigate to registration page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Register Here",
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
