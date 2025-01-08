import 'package:career_guild/components/my_back_button.dart';
import 'package:career_guild/components/my_list_tile.dart';
import 'package:career_guild/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            //error handling
            if (snapshot.hasError) {
              displayMessageToUser("Something went wrong", context);
            }

            //loading circle while fetching data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data == null) {
              return const Text("No data!");
            }

            //get all users
            final users = snapshot.data!.docs;

            return Column(
              children: [
                //back button
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

                //list of users
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      //get data from each user
                      final user = users[index];
                      String username = user['username'];
                      String email = user['email'];

                      return MyListTile(
                        title: username,
                        subtitle: email,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ));
  }
}
