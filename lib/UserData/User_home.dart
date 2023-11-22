import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:placement/UserData/announcement.dart';
import 'package:placement/UserData/feedback.dart';
import 'package:placement/UserData/homeCard.dart';
import 'package:placement/UserData/resoureceUser.dart';
import 'package:placement/UserData/resumeUser.dart';
import 'package:placement/UserData/users_all_data/profileData.dart';
// import 'package:placement/UserData/users_all_data/conten.dart';
import 'package:placement/UserData/vacencyuser.dart';
import 'package:placement/app_home.dart';
import 'package:google_fonts/google_fonts.dart';

class AfterRegister extends StatefulWidget {
  const AfterRegister({Key? key}) : super(key: key);

  @override
  _AfterRegisterState createState() => _AfterRegisterState();
}

class _AfterRegisterState extends State<AfterRegister> {
  File? pickedFile;

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

  Future<void> captureImages() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double iconSize = 38;
        double fontSize = 16;

        if (MediaQuery.of(context).size.width > 600) {
          // Adjust sizes for larger screens
          iconSize = 50;
          fontSize = 18;
        }

        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 221, 228, 113),
          title: const Text(
            'Choose an Option',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                final image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    pickedFile = File(image.path);
                  });

                  Navigator.of(context).pop();
                  await uploadImage();
                }
              },
              child: Column(
                children: [
                  Icon(
                    Icons.folder,
                    size: iconSize,
                    color: Color.fromARGB(221, 61, 38, 38),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  pickedFile = null;
                });
                Navigator.of(context).pop();
              },
              child: Column(
                children: [
                  Icon(
                    Icons.delete,
                    size: iconSize + 12,
                    color: Color.fromARGB(255, 193, 80, 72),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () async {
                final image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    pickedFile = File(image.path);
                  });

                  Navigator.of(context).pop();
                  await uploadImage();
                }
              },
              child: Column(
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: iconSize + 7,
                    color: Color.fromARGB(221, 61, 38, 38),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> uploadImage() async {
    try {
      if (pickedFile != null) {
        final storage = FirebaseStorage.instance;
        final Reference storageRef = storage.ref().child('user_images/');
        await storageRef.putFile(pickedFile!);

        // Get the download URL of the uploaded image
        String imageUrl = await storageRef.getDownloadURL();
        print('Image URL: $imageUrl');

        // Perform any additional tasks with the image URL, like saving it to Firestore
      } else {
        print('Error: pickedFile is null or _user is null');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => ContentPage()));
        // }),
        appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: Text(
            'Welcome To Placement Cell',
            style: GoogleFonts.aguafinaScript(
              fontSize: 30,
              color: Color.fromARGB(255, 79, 49, 49),
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HomeCard(
                title: '',
                imagePath: 'assets/annuncement.jpg', // Set your image path
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AnnouncementPageUser(),
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
                      builder: (context) => userVacancy(),
                    ),
                  );
                },
              ),
              HomeCard(
                title: '',
                imagePath: 'assets/resource.jpg', // Set your image path
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResourcesPageUser(),
                    ),
                  );
                },
              ),
              HomeCard(
                title: '',
                imagePath: 'assets/resume.jpg', // Set your image path
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResumeBuilder(
                        title: '',
                      ),
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
                      builder: (context) => FeedbackPageUser(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 81, 86, 136),
                          Color.fromARGB(255, 23, 146, 163),
                          Color.fromARGB(255, 229, 181, 39),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: pickedFile != null
                          ? ClipOval(
                              child: Image.file(
                                pickedFile!,
                                height: 150,
                                width: 140,
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                      ),
                    ),
                    onTap: () {
                      logOut();
                    },
                  ),
                ],
              ),
              Positioned(
                top: 168,
                right: 68,
                child: IconButton(
                  icon: const Icon(
                    Icons.photo_camera,
                    color: Color.fromARGB(255, 227, 222, 222),
                    size: 40,
                  ),
                  onPressed: () {
                    captureImages();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
