import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:placement/AdminData/add_student.dart';
import 'package:placement/AdminData/admin_load_data/announcement.dart';
import 'package:placement/AdminData/admin_load_data/content.dart';
import 'package:placement/AdminData/admin_load_data/feedback.dart';
import 'package:placement/AdminData/admin_load_data/jobs.dart';

import '../UserData/homeCard.dart';
import '../app_home.dart';

class AfterVerify extends StatefulWidget {
  const AfterVerify({Key? key}) : super(key: key);

  @override
  _AfterVerifyState createState() => _AfterVerifyState();
}

class _AfterVerifyState extends State<AfterVerify> {
  void logOut() async {
    //LogOut from device
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AppHome(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          "Admin Home",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HomeCard(
              title: '',
              imagePath: 'assets/addStudent.jpeg', // Set your image path
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddStudent(),
                  ),
                );
              },
            ),
            HomeCard(
              title: '',
              imagePath: 'assets/annuncement.jpg', // Set your image path
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnnouncementPage(),
                ));
              },
            ),
            HomeCard(
              title: '',
              imagePath: 'assets/vacancy.jpg', // Set your image path
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobVacancyPage(),
                  ),
                );
              },
            ),
            HomeCard(
              title: 'Add Resources',
              imagePath: 'assets/resource.jpg', // Set your image path
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContentData(),
                  ),
                );
              },
            ),
            HomeCard(
              title: '',
              imagePath: 'assets/feedback.jpg', // Set your image path
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FeedbackPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
