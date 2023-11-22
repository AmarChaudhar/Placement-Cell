import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:placement/UserData/User_home.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_otp/email_otp.dart';
import 'package:placement/app_home.dart';

class UserRegistrationForm extends StatefulWidget {
  const UserRegistrationForm({Key? key}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<UserRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController rollNumberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController otpController =
      TextEditingController(); // Added OTP controller
  String selectedGender = "";
  Icon _rollNumberIcon = const Icon(Icons.error, color: Colors.green);
  bool isEmailCorrect = false;
  bool otpVerified = false;
  bool _showPassword1 = false;
  bool _showPassword2 = false;
  EmailOTP myauth = EmailOTP(); // Added EmailOTP instance

  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void sendOtp() async {
    myauth.setConfig(
      appEmail: "placementApp123@gmail.com",
      appName: "Placement App",
      userEmail: emailController.text,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );

    if (await myauth.sendOTP()) {
      print('OTP sent to ${emailController.text}');
      openOtpDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oops, OTP send failed"),
        ),
      );
    }
  }

  void openOtpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Enter OTP',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextFormField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'OTP',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                bool isOtpVerified =
                    await myauth.verifyOTP(otp: otpController.text);
                if (isOtpVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("OTP is verified"),
                    ),
                  );
                  setState(() {
                    otpVerified = true;
                  });
                  Navigator.pop(context); // Close OTP dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invalid OTP"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // Replace with your custom color
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkRollNumberExists(String studentRollNo) async {
    try {
      print('Checking student roll number: $studentRollNo');

      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('studentRollNos')
          .where('studentRollNo', isEqualTo: studentRollNo)
          .get();

      print('Query result: ${result.docs.length} documents found');

      return result.docs.isNotEmpty;
    } catch (error, stackTrace) {
      print('Error checking student roll number: $error');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  void validateAndSubmit() async {
    String rollNumberString = rollNumberController.text.trim();

    if (rollNumberString.isEmpty) {
      print('Please enter your roll number');
      return;
    }

    try {
      bool rollNumberExists = await checkRollNumberExists(rollNumberString);

      setState(() {
        _rollNumberIcon = rollNumberExists
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.error, color: Colors.red);
      });

      if (rollNumberExists) {
        print('Roll number exists!');

        // Check email verification status
        final User? user = _auth.currentUser;
        if (user != null && user.emailVerified) {
          // Email is verified, proceed with registration
          // Add your registration logic here
          // ...
        } else {
          print('Email not verified');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(''),
            ),
          );
        }
      } else {
        print('Roll number does not exist');
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 176, 15),
        centerTitle: true,
        title: const Text(
          'User Registration Form',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppHome(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextFormField(
                  controller: nameController,
                  labelText: 'Name',
                ),
                const SizedBox(height: 12),
                buildTextFormField(
                  controller: rollNumberController,
                  labelText: 'Roll Number',
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      validateAndSubmit();
                    } else {
                      setState(() {
                        _rollNumberIcon =
                            const Icon(Icons.error, color: Colors.red);
                      });
                    }
                  },
                  suffixIcon: _rollNumberIcon,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your roll number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                buildTextFormField(
                  controller: ageController,
                  labelText: 'Age',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                buildTextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: selectedGender),
                  labelText: 'Gender',
                  onTap: () async {
                    selectedGender = await showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: const Text(
                            'Select Gender',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 11, 114, 177),
                              fontSize: 22,
                            ),
                          ),
                          children: [
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 'Male');
                              },
                              child: const Text(
                                'Male',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 210, 7, 255),
                                  fontSize: 21,
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 'Female');
                              },
                              child: const Text(
                                'Female',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 210, 7, 255),
                                  fontSize: 21,
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 'Other');
                              },
                              child: const Text(
                                'Other',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 210, 7, 255),
                                  fontSize: 21,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {});
                  },
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                buildTextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  labelText: 'Mobile Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a mobile number';
                    }
                    final cleanedValue =
                        value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleanedValue.length != 10) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                buildTextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      isEmailCorrect = validateEmail(value);
                    });
                  },
                  labelText: 'Email ID',
                  suffixIcon: isEmailCorrect
                      ? (otpVerified
                          ? const Icon(
                              Icons.verified,
                              color: Color.fromARGB(219, 9, 236, 66),
                            )
                          : IconButton(
                              onPressed: () {
                                sendOtp();
                              },
                              icon: const Icon(
                                Icons.verified,
                                color: Color.fromARGB(255, 185, 9, 9),
                              ),
                            ))
                      : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!isEmailCorrect) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: !_showPassword1,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword1
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _showPassword1 = !_showPassword1;
                        });
                      },
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: false,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    // Password strength validation using a regular expression
                    final RegExp passwordRegex = RegExp(
                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}',
                    );

                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 6 characters, ';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !_showPassword2,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword2
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _showPassword2 = !_showPassword2;
                        });
                      },
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: false,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      bool rollNumberExists = await checkRollNumberExists(
                          rollNumberController.text);

                      if (rollNumberExists) {
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
                          try {
                            await _auth.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            Map<String, dynamic> userData = {
                              "name": nameController.text,
                              "rollNumber": rollNumberController.text,
                              "age": ageController.text,
                              "gender": selectedGender,
                              "mobile": mobileController.text,
                            };

                            final User? user = _auth.currentUser;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .set(userData);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration successful!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AfterRegister(),
                              ),
                            );
                          } catch (error) {
                            print('Registration error: $error');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Registration failed: $error'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Roll number does not match. Please check your roll number.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 22, 53, 163),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 52,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    GestureTapCallback? onTap,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: false,
        fillColor: Colors.grey[200],
        suffixIcon: suffixIcon,
      ),
    );
  }
}
