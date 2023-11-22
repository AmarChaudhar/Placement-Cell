import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Announcement {
  final int id;
  String message;

  Announcement({required this.id, required this.message});
}

class AnnouncementPageUser extends StatefulWidget {
  @override
  _AnnouncementPageUserState createState() => _AnnouncementPageUserState();
}

class _AnnouncementPageUserState extends State<AnnouncementPageUser> {
  bool isLoading = true;
  List<Announcement> announcements = [];
  @override
  void initState() {
    super.initState();
    _loadAnnouncementsFromDatabase();
  }

  Future<void> _loadAnnouncementsFromDatabase() async {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('announcements');

    try {
      DatabaseEvent event = await reference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        List<Announcement> loadedAnnouncements = [];

        values!.forEach((key, value) {
          loadedAnnouncements.add(Announcement(
            id: value['id'],
            message: value['message'],
          ));
        });

        setState(() {
          announcements = loadedAnnouncements;
        });
      }
    } catch (error) {
      print("Error loading data: $error");
      // Handle the error appropriately
    } finally {
      // No need to delay, as the refresh indicator will automatically dismiss
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    // Set isLoading to true to show the CircularProgressIndicator
    setState(() {
      isLoading = true;
    });

    // Load announcements from the database
    await _loadAnnouncementsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "Announcement",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // Add any action you want when tapping on the announcement
                    },
                    child: Card(
                      margin: EdgeInsets.all(8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(
                          announcements[index].message,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
