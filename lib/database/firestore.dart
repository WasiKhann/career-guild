import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  // Current logged-in user
  User? user = FirebaseAuth.instance.currentUser;

  // Firestore collection for posts
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');

  // Add post to Firestore with optional image URL
  Future<void> addPost(String message, {String? imageUrl}) {
    return posts.add({
      'UserEmail': user?.email ?? 'Unknown User',
      'PostMessage': message,
      'ImagePath': imageUrl,
      'TimeStamp': Timestamp.now(),
    });
  }

  // Read posts from Firestore
  Stream<QuerySnapshot> getPostsStream() {
    return posts.orderBy('TimeStamp', descending: true).snapshots();
  }
}
