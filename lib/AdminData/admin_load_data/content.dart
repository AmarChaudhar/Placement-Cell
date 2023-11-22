import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';

class ContentData extends StatefulWidget {
  const ContentData({Key? key}) : super(key: key);

  @override
  _ContentDataState createState() => _ContentDataState();
}

class _ContentDataState extends State<ContentData> {
  final List<Map<String, dynamic>> _files = [];
  bool _uploading = false;
  bool _loadingData = true;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('files');

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      setState(() {
        _loadingData = true; // Show loading indicator
      });

      DataSnapshot dataSnapshot = (await _databaseReference.once()).snapshot;
      Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;
      if (values != null) {
        setState(() {
          _files.clear();
          values.forEach((key, value) {
            _files.add({
              'key': key,
              'fileName': value['fileName'],
              'downloadURL': value['downloadURL'],
              'timestamp': value['timestamp'],
            });
          });
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
    } finally {
      // Wait for 2 seconds before hiding the loading indicator
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _loadingData = false; // Hide loading indicator
      });
    }
  }

  Future<void> pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'mp4'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);

        setState(() {
          _uploading = true;
        });

        await uploadFile(file);

        setState(() {
          _uploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      print(e.toString());
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      final storageReference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now()}');
      final uploadTask = storageReference.putFile(file);

      await uploadTask;

      final downloadURL = await storageReference.getDownloadURL();
      String? key = _databaseReference.push().key;
      await _databaseReference.child(key!).set({
        'fileName': file.path,
        'downloadURL': downloadURL,
        'timestamp': DateTime.now().microsecondsSinceEpoch,
      });

      setState(() {
        _files.add({
          'key': key,
          'fileName': file.path,
          'downloadURL': downloadURL,
          'timestamp': DateTime.now().microsecondsSinceEpoch,
        });
      });

      print('File uploaded successfully! Files count: ${_files.length}');

      _showSnackbar('File uploaded successfully');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> removeFile(int index) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(_files[index]['downloadURL'])
          .delete();

      await _databaseReference.child(_files[index]['key']).remove();

      setState(() {
        _files.removeAt(index);
      });

      print('File removed successfully! Files count: ${_files.length}');

      _showSnackbar('File removed successfully');
    } catch (e) {
      print(e.toString());
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(microseconds: 80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Resource",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.all(10.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            "File ${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFileSubtitle(_files[index]),
                              _buildFilePreview(_files[index]),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeFile(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _uploading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FloatingActionButton(
              onPressed: () => pickAndUploadFile(),
              backgroundColor: const Color.fromARGB(255, 181, 170, 199),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Icon(Icons.upload),
            ),
    );
  }

  Widget _buildFileSubtitle(Map<String, dynamic> file) {
    return Text(file['fileName'].split('/').last);
  }

  Widget _buildFilePreview(Map<String, dynamic> file) {
    if (file['fileName'].toLowerCase().endsWith('.jpg') ||
        file['fileName'].toLowerCase().endsWith('.png')) {
      return Image.network(
        file['downloadURL'],
        width: 200.0,
        height: 100.0,
        fit: BoxFit.cover,
      );
    } else if (file['fileName'].toLowerCase().endsWith('.mp4')) {
      return _buildVideoPreview(file);
    } else if (file['fileName'].toLowerCase().endsWith('.pdf')) {
      return _buildPdfPreview(file);
    } else {
      return const Text('Unsupported file type');
    }
  }

  Widget _buildVideoPreview(Map<String, dynamic> file) {
    return const Text('Video Preview');
  }

  Widget _buildPdfPreview(Map<String, dynamic> file) {
    return const Text('PDF Preview');
  }
}
