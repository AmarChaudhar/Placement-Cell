import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackForm {
  String key;
  String name;
  String message;

  FeedbackForm({
    required this.key,
    required this.name,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'message': message,
    };
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  DatabaseReference feedbackRef =
      FirebaseDatabase.instance.reference().child("feedback");

  late List<Map<dynamic, dynamic>> feedbackList;

  @override
  void initState() {
    super.initState();
    feedbackList = [];
  }

  Future<List<Map<dynamic, dynamic>>> fetchData() async {
    try {
      DatabaseEvent snapshotEvent = await feedbackRef.once();
      DataSnapshot snapshot = snapshotEvent.snapshot;

      if (snapshot.value != null) {
        if (snapshot.value is Map) {
          Map<dynamic, dynamic> feedbackMap =
              snapshot.value as Map<dynamic, dynamic>;

          return feedbackMap.entries
              .where((entry) =>
                  entry.value is Map &&
                  entry.value.containsKey('name') &&
                  entry.value.containsKey('message'))
              .map((entry) => {
                    'key': entry.key,
                    'name': entry.value['name'],
                    'message': entry.value['message'],
                  })
              .toList();
        }
      }
    } catch (error) {
      print('Error fetching data: $error');
    }

    return [];
  }

  void removeFeedback(Map<dynamic, dynamic> feedbackData) async {
    try {
      int indexToRemove = feedbackList.indexOf(feedbackData);

      feedbackList.removeAt(indexToRemove);
      setState(() {});

      String feedbackKey = feedbackData['key'];
      await feedbackRef.child(feedbackKey).remove();
    } catch (error) {
      print('Error removing feedback: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Feedback list',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<dynamic, dynamic>>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while data is being fetched
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue, // Change loading indicator color
                ),
              );
            } else if (snapshot.hasError) {
              // Show an error message if there's an error
              return Center(
                child: Text(
                  'Error loading data',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Show 'No Feedback Available' if there is no data
              return const Center(
                child: Text(
                  'No Feedback Available',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              // Display the feedback data
              feedbackList = snapshot.data!;
              return ListView.builder(
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> feedbackData = feedbackList[index];

                  return Dismissible(
                    key: Key(feedbackData['key']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      removeFeedback(feedbackData);
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 5.0,
                      child: ListTile(
                        title: Text(
                          feedbackData['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue, // Change text color
                          ),
                        ),
                        subtitle: Text(
                          feedbackData['message'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(
                                255, 40, 48, 40), // Change text color
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
