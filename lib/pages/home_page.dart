import 'package:career_guild/components/my_drawer.dart';
import 'package:career_guild/components/my_list_tile.dart';
import 'package:career_guild/components/my_post_button.dart';
import 'package:career_guild/components/my_textfield.dart';
import 'package:career_guild/database/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //firestore instance
  final FirestoreDatabase database = FirestoreDatabase();

  //text controller for post
  final TextEditingController newPostController = TextEditingController();

  //post message
  void postMessage() {
    //posted only when text field has something
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    //clear text field/ text controller
    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F E E D'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          //text field for user
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                //text field
                Expanded(
                  child: MyTextField(
                    hintText: "Reach out..",
                    obscureText: false,
                    controller: newPostController,
                  ),
                ),

                //post button
                MyPostButton(
                  onTap: postMessage,
                ),
              ],
            ),
          ),

          //posts

          StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context, snapshot) {
                //loading circle
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                //get all posts
                final posts = snapshot.data!.docs;

                //no data check
                if (snapshot.data == null || posts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No posts. You can be the first!"),
                    ),
                  );
                }

                //return as list
                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      //get each individual post
                      final post = posts[index];

                      //get data from each post
                      String message = post['PostMessage'];
                      String userEmail = post['UserEmail'];
                      Timestamp timestamp = post['TimeStamp'];

                      //return as list tile
                      return MyListTile(title: message, subtitle: userEmail);
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
