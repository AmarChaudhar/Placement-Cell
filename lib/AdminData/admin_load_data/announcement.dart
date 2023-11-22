import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Announcement {
  final int id;
  String message;

  Announcement({required this.id, required this.message});
}

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final TextEditingController _announcementController = TextEditingController();
  int _nextId = 1; // Initialize _nextId to 1
  List<Announcement> announcements = [];
  bool isEditing = false;
  @override
  void initState() {
    super.initState();
    _loadAnnouncementsFromDatabase();
  }

  Future<void> _loadAnnouncementsFromDatabase() async {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('announcements');

    DatabaseEvent event = await reference.once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

    setState(() {
      if (values != null) {
        announcements = values.entries
            .map((entry) => Announcement(
                  id: entry
                      .value['id'], // Assuming 'id' is a field in your database
                  message: entry.value['message'],
                ))
            .toList();

        _nextId = _generateNextId();
      }
    });
  }

  int _generateNextId() {
    int latestId = announcements.isNotEmpty ? announcements.first.id : 0;
    return latestId + 1;
  }

  Future<void> _saveAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    final announcementList = announcements
        .map((announcement) => '${announcement.id}|${announcement.message}')
        .toList();

    await prefs.setStringList('announcements', announcementList);
  }

  void _addAnnouncement() {
    final message = _announcementController.text;
    if (message.isNotEmpty) {
      setState(() {
        Announcement newAnnouncement =
            Announcement(id: _nextId, message: message);
        announcements.insert(0, newAnnouncement);
        _nextId++;
        _announcementController.clear();
        _saveAnnouncements();

        DatabaseReference reference =
            FirebaseDatabase.instance.reference().child('announcements');
        reference.push().set({
          'id': newAnnouncement.id,
          'message': newAnnouncement.message,
        });
      });
    }
  }

  void _editAnnouncement(Announcement announcement, String newMessage) {
    setState(() {
      announcement.message = newMessage;
      _saveAnnouncements();

      DatabaseReference reference =
          FirebaseDatabase.instance.reference().child('announcements');
      reference.child(announcement.id.toString()).update({
        'message': newMessage,
      });
    });
  }

  void _deleteAnnouncement(Announcement announcement) {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('announcements');

    reference.child(announcement.id.toString()).remove().then((_) {
      print('Deletion successful');
      setState(() {
        announcements.remove(announcement);
        _saveAnnouncements();
      });
    }).catchError((error) {
      print('Deletion failed: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: const Text(
          'Announcement',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.blue, // Change the color to your preference
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _announcementController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Announcement Message',
                      filled: true,
                      fillColor: Colors
                          .grey[200], // Set your preferred background color
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Set border radius
                        borderSide: BorderSide.none, // Hide the border
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _addAnnouncement,
                  child: ClipOval(
                    child: Material(
                      color: const Color.fromARGB(255, 59, 75, 59),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _addAnnouncement,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Notice Card',
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 108, 100, 70),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Change the color to your preference
              ),
              child: ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _buildAnnouncementCard(announcements[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    TextEditingController _editController =
        TextEditingController(text: announcement.message);

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isEditing)
              Text(
                announcement.message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            if (isEditing)
              TextFormField(
                controller: _editController,
                decoration: const InputDecoration(
                  labelText: 'Edit Announcement',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.edit_square,
                      color: Color.fromARGB(255, 70, 10, 198)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context, announcement, _editController);
                    } else if (value == 'delete') {
                      _deleteAnnouncement(announcement);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isEditing)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Announcement'),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Delete Announcement',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteAnnouncement(announcement);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Announcement announcement,
      TextEditingController editController) async {
    editController.text = announcement.message;
    setState(() {
      isEditing = false; // Set isEditing to true when the dialog is shown
    });

    editController.text = announcement.message;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Announcement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Message:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              announcement.message,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'New Message:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            TextField(
              controller: editController,
              decoration: const InputDecoration(
                labelText: 'Enter new message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _editAnnouncement(announcement, editController.text);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
