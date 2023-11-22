import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ResourcesPageUser extends StatefulWidget {
  const ResourcesPageUser({Key? key}) : super(key: key);

  @override
  _ContentDataState createState() => _ContentDataState();
}

class _ContentDataState extends State<ResourcesPageUser> {
  final List<Map<String, dynamic>> filesData = [];
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Simulate a delay to show the loading indicator
      await Future.delayed(const Duration(milliseconds: 200));

      DataSnapshot dataSnapshot =
          (await FirebaseDatabase.instance.reference().child('files').once())
              .snapshot;
      Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;
      if (values != null) {
        setState(() {
          filesData.clear(); // Clear existing data
          values.forEach((key, value) {
            filesData.add({
              'key': key,
              'fileName': value['fileName'],
              'downloadURL': value['downloadURL'],
              'timestamp': value['timestamp'],
            });
          });
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> downloadFile(
    String downloadURL,
    String fileName,
    BuildContext context,
  ) async {
    try {
      // Replace invalid characters in the file name with underscores
      fileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9\._]'), '_');
      final String dir = (await getTemporaryDirectory()).path;
      final String filePath = path.join(dir, fileName);
      print(filePath);
      http.Response response = await http.get(Uri.parse(downloadURL));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;

        final String dir = (await getTemporaryDirectory()).path;
        final String filePath = path.join(dir, fileName);

        final File file = File(filePath);

        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded to $filePath'),
          ),
        );

        return filePath;
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }

    // If there's an error, return an empty string
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "Resources",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: filesData.length,
                itemBuilder: (context, index) {
                  return _buildCard(filesData[index], index);
                },
              ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> fileData, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Card(
        elevation: 3.0,
        color: Colors.amber, // Choose your desired background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilePreview(fileData),
            ListTile(
              subtitle: _buildFileSubtitle(filesData[index]),
            ),
            _buildDownloadButton(fileData, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Map<String, dynamic> fileData) {
    return Container(
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 10,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(fileData['downloadURL']),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDownloadButton(
    Map<String, dynamic> fileData,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        onPressed: () async {
          // Download the file
          final String filePath = await downloadFile(
              fileData['downloadURL'], fileData['fileName'], context);

          // Open the file in a file viewer app
          await openFile(filePath);
        },
        child: const Text('Download'),
      ),
    );
  }

  Future<void> openFile(String filePath) async {
    OpenFile.open(filePath);
  }

  Widget _buildFileSubtitle(Map<String, dynamic> fileData) {
    String fileName = fileData['fileName'];
    String displayText = fileName.split('/').last;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Unused method, consider removing
  getApplicationDocumentsDirectory() {}
}
