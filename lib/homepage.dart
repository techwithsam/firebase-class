import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut().then(
                (value) {
                  Navigator.pushReplacementNamed(context, '/');
                },
              );
            },
            icon: const Icon(Icons.sign_language),
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            StreamBuilder(
              stream: db.collection("items").snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                        ),
                        child: Column(
                          children: [
                            Text(
                              snapshot.data!.docs[index]['name'],
                            )
                          ],
                        ),
                      );
                    },
                  );
                }

                return const Text('Something went wrong');
              }),
            ),
          ],
        ),
      ),
    );
  }
}
