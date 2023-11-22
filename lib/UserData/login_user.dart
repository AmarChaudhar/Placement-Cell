import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:placement/UserData/User_home.dart';
import 'package:connectivity/connectivity.dart';
import 'package:placement/UserData/user_registers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<bool> checkInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult != ConnectivityResult.none;
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _showPassword = false;
  String _errorText = '';

  final _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();

  void login() async {
    setState(() {
      _errorText = '';
    });

    if (_username.isNotEmpty && _password.isNotEmpty) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _username,
          password: _password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AfterRegister(),
          ),
        );
      } catch (error) {
        setState(() {
          if (error is FirebaseAuthException &&
              error.code == 'user-not-found') {
            _errorText = 'User does not exist. Please check your credentials.';

            // Show dialog
            Future.delayed(Duration.zero, () {
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
            });
          } else {
            _errorText = 'Login failed: ${error.toString()}';
          }
        });
      }
    } else {
      setState(() {
        _errorText = 'Please enter your username and password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontSize: 25.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenHeight * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/app logo.png',
                  height: screenHeight * 0.3,
                ),
                const SizedBox(height: 45),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username or Email',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: screenHeight * 0.024,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.1),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.black),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                const SizedBox(height: 26.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: screenHeight * 0.024,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.1),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  _errorText,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 22, 53, 163),
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 52,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    bool isConnected = await checkInternetConnection();

                    if (!isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No internet connection. Please check your network.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      login();
                    }
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserRegistrationForm(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
