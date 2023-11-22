import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AddStudent extends StatefulWidget {
  const AddStudent({Key? key}) : super(key: key);

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final TextEditingController _studentRollNoController =
      TextEditingController();
  late Stream<QuerySnapshot> _studentRollNosStream;

  @override
  void initState() {
    super.initState();
    _studentRollNosStream = _firestore.collection('studentRollNos').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          "Add Student",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _studentRollNoController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Enter Student Roll Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_studentRollNoController.text.isNotEmpty) {
                _addStudentRollNo(_studentRollNoController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a Roll number'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 62, 20, 213),
            ),
            child: const Text(
              "Add Student Roll Number",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.blue,
            thickness: 5,
          ),
          Expanded(
            child: _buildStudentRollNosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRollNosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _studentRollNosStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator for initial data load
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var studentRollNos = snapshot.data!.docs
            .map(
              (document) => {
                'id': document.id,
                'studentRollNo': document['studentRollNo'].toString(),
              },
            )
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: studentRollNos.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(studentRollNos[index]['studentRollNo']!),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(studentRollNos[index]['id']!);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 220, 193, 178),
                  ),
                  child: const Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addStudentRollNo(String studentRollNo) async {
    try {
      // Check if the roll number already exists
      var querySnapshot = await _firestore
          .collection('studentRollNos')
          .where('studentRollNo', isEqualTo: studentRollNo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Roll number already exists, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This Roll Number is already Exist !.'),
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding Student Roll Number...'),
            ],
          ),
        ),
      );

      // Add the roll number to Firestore
      await _firestore.collection('studentRollNos').add({
        'studentRollNo': studentRollNo,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      print('Student Roll Number added successfully to Firestore.');
      _studentRollNoController.clear();
    } catch (e) {
      // Hide loading indicator on error
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      print('Error adding student roll number: $e');
    }
  }

  void _showConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Are you sure you want to remove this student roll number?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label:
                        const Text('No', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () {
                      _removeStudentRollNo(id);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    label: const Text('Yes',
                        style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeStudentRollNo(String documentId) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Removing Student Roll Number...'),
            ],
          ),
        ),
      );

      await _firestore.collection('studentRollNos').doc(documentId).delete();

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      print('Student Roll Number removed successfully from Firestore.');
    } catch (e) {
      // Hide loading indicator on error
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      print('Error removing student roll number: $e');
    }
  }
}
