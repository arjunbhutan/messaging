import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  //logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Column(

            children: [
              DrawerHeader(
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              // Home title
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left:25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: Text("H O M E"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              //Profile title
              Padding(
                padding: const EdgeInsets.only(left:25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("P R O F I L E"),
                  onTap: () {
                    Navigator.pop(context);
                    //navigate to profile page
                    Navigator.pushNamed(context, '/profile_page');


                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.group,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("Team Members"),
                  onTap: () {
                    Navigator.pop(context);
                    //navigate to profile page
                    Navigator.pushNamed(context, '/users_page');

                  },
                ),
              ),

            ],
          ),
          // Drawer header


          Padding(
            padding: const EdgeInsets.only(left:25.0,bottom: 25),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text("Log Out"),
              onTap: () {
                Navigator.pop(context);
                //logout
                logout();

              },
            ),
          ),


          //users tile

        ],
      ),
    );
  }
}
