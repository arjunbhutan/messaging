import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaing/helper/helper_functions.dart';
import '../components/my_back_button.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Any errors
          if (snapshot.hasError) {
            displayMessageToUser("Something went wrong", context);
          }

          // Show loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle no data
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No data"),
            );
          }

          // Get all users
          final users = snapshot.data!.docs;

          return Column(
            children: [
              // Back button
              const Padding(
                padding: EdgeInsets.only(
                  top: 50.0,
                  left: 25,
                ),
                child: Row(
                  children: [
                    MyBackButton(),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // List of users in the app
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    // Get data from each user
                    String username = user["username"];
                    String email = user['email'];

                    return ListTile(
                      title: Text(username),
                      subtitle: Text(email),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
