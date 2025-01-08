import 'package:career_guild/components/my_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  // Current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Fetch user info
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Error
          else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          // Data received
          else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back button
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 50,
                      left: 25,
                    ),
                    child: Row(
                      children: [
                        MyBackButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Profile picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?['profilePicUrl'] != null &&
                            user!['profilePicUrl'].isNotEmpty
                        ? NetworkImage(user['profilePicUrl'])
                        : null,
                    child: user?['profilePicUrl'] == null ||
                            user!['profilePicUrl'].isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 64,
                          )
                        : null,
                  ),
                  const SizedBox(height: 25),
                  // Username
                  Text(
                    user?['username'] ?? "Unknown User",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Email
                  Text(
                    user?['email'] ?? "No Email",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          // No data
          else {
            return const Text("No data!");
          }
        },
      ),
    );
  }
}
