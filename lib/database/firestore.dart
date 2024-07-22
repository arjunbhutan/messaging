import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('TimeStamp', descending: true)
        .snapshots();
  }

  Future<void> addPost(String message) async {
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Anonymous';
    await _firestore.collection('posts').add({
      'PostMessage': message,
      'UserEmail': userEmail,
      'TimeStamp': FieldValue.serverTimestamp(),
      'HiddenBy': [], // Add this line to include the HiddenBy field
    });
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> hidePost(String postId) async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    await _firestore.collection('posts').doc(postId).update({
      'HiddenBy': FieldValue.arrayUnion([currentUserEmail])
    });
  }
}