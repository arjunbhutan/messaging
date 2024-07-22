import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaing/components/my_drawer.dart';
import 'package:messaing/components/my_list_tile.dart';
import 'package:messaing/components/my_post_button.dart';
import 'package:messaing/components/my_textfield.dart';
import 'package:messaing/database/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }
    newPostController.clear();
  }

  void deleteOrHidePost(String postId, bool isAuthor) {
    if (isAuthor) {
      database.deletePost(postId);
    } else {
      database.hidePost(postId);
    }
    setState(() {});
  }

  void showDeleteOrHideDialog(BuildContext context, String postId, bool isAuthor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isAuthor ? "Delete Post" : "Delete Post"),
          content: Text(isAuthor
              ? "Are you sure you want to delete this post?"
              : "Are you sure you want to delete this post?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(isAuthor ? "Delete" : "Delete"),
              onPressed: () {
                deleteOrHidePost(postId, isAuthor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speak, Listen, and Act."),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextfield(
                    hintText: "Text your team mates!",
                    controller: newPostController,
                    obscureText: false,
                  ),
                ),
                PostButton(
                  onTap: postMessage,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No Posts.. Post something"),
                    ),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final postData = post.data() as Map<String, dynamic>;

                    final message = postData['PostMessage'] as String? ?? 'No message';
                    final userEmail = postData['UserEmail'] as String? ?? 'Unknown';
                    final timestamp = postData['TimeStamp'] as Timestamp? ?? Timestamp.now();
                    final postId = post.id;

                    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
                    final isAuthor = currentUserEmail == userEmail;

                    // Check if the post is hidden for the current user
                    final hiddenBy = postData['HiddenBy'] as List<dynamic>? ?? [];
                    if (hiddenBy.contains(currentUserEmail)) {
                      return SizedBox.shrink(); // Don't show hidden posts
                    }

                    return GestureDetector(
                      onLongPress: () => showDeleteOrHideDialog(context, postId, isAuthor),
                      child: MyListTile(title: message, subTitle: userEmail),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}