import 'package:flutter/material.dart';

import 'admin_home.dart';

class AdminLogin extends StatefulWidget {
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;

  String adminEmail = "adminptu1@gmail.com";
  String adminPassword = "adminptu1@";

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      print("Please fill all the fields!");
    } else if (email == adminEmail && password == adminPassword) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AfterVerify(),
        ),
      );
    } else {
      // User does not exist
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User does not exist'),
          content: const Text('Please check your email and password.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Login",
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Image.asset(
                  'assets/app logo.png',
                  height: screenHeight * 0.3,
                ),
              ),
              const SizedBox(height: 45),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Username or Email",
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.024,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.1),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.black),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: screenHeight * 0.024,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.1),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 22, 53, 163),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 52,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.07),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
