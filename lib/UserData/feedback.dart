import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackForm {
  String name;
  String message;

  FeedbackForm({required this.name, required this.message});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
    };
  }
}

class FeedbackPageUser extends StatefulWidget {
  const FeedbackPageUser({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPageUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;

  void sendFeedback(FeedbackForm feedback) async {
    DatabaseReference feedbackRef =
        FirebaseDatabase.instance.reference().child("feedback");

    await feedbackRef.push().set(feedback.toJson());
  }

  void _sendFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      final feedback = FeedbackForm(
        name: _nameController.text,
        message: _messageController.text,
      );

      sendFeedback(feedback);

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback sent')),
      );

      _nameController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset(
                'assets/app logo.png',
                height: 250,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name with Roll No. ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your feedback message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isSending ? null : _sendFeedback,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 25, 99, 209),
                  onPrimary: const Color.fromARGB(255, 188, 54, 54),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
