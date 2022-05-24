import 'package:flutter/material.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/views/sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              AuthMethods().signOut(context).then(
                (_) {
                  Navigator.of(context)
                      .pushReplacementNamed(SignInScreen.routeName);
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
