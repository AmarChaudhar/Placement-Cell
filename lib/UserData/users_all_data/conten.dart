// // import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;

// class ContentPage extends StatefulWidget {
//   const ContentPage({Key? key}) : super(key: key);

//   @override
//   _ContentDataState createState() => _ContentDataState();
// }

// class _ContentDataState extends State<ContentPage> {
//   final List<Map<String, dynamic>> filesData = [];
//   late BuildContext _scaffoldContext;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     try {
//       DataSnapshot dataSnapshot =
//           (await FirebaseDatabase.instance.reference().child('files').once())
//               .snapshot;
//       Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;
//       if (values != null) {
//         values.forEach((key, value) {
//           setState(() {
//             filesData.add({
//               'key': key,
//               'fileName': value['fileName'],
//               'downloadURL': value['downloadURL'],
//               'timestamp': value['timestamp'],
//             });
//           });
//         });
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   Future<void> downloadFile(String downloadURL, String fileName) async {
//     print('Downloading file: $fileName from $downloadURL');
//     try {
//       http.Response response = await http.get(Uri.parse(downloadURL));

//       if (response.statusCode == 200) {
//         Uint8List bytes = response.bodyBytes;

//         // Use getTemporaryDirectory() for temporary files
//         final String dir = (await getTemporaryDirectory()).path;
//         final String filePath = path.join(dir, fileName);
//         final File file = File(filePath);

//         await file.writeAsBytes(bytes);

//         ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
//           SnackBar(
//             content: Text('File downloaded to $filePath'),
//           ),
//         );
//       } else {
//         print('Failed to download file. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error downloading file: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Files Gallery"),
//       ),
//       body: Builder(
//         builder: (BuildContext scaffoldContext) {
//           _scaffoldContext = scaffoldContext;
//           return ListView.builder(
//             itemCount: filesData.length,
//             itemBuilder: (context, index) {
//               return _buildCard(filesData[index], index);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFilePreview(Map<String, dynamic> fileData) {
//     return Container(
//       height: 150.0,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 10,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//         image: DecorationImage(
//           image: NetworkImage(fileData['downloadURL']),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget _buildDownloadButton(Map<String, dynamic> fileData) {
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: ElevatedButton(
//         onPressed: () {
//           downloadFile(fileData['downloadURL'], fileData['fileName']);
//         },
//         child: Text('Download'),
//       ),
//     );
//   }

//   Widget _buildCard(Map<String, dynamic> fileData, int index) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//       child: Card(
//         elevation: 3.0,
//         color: Colors.amber, // Choose your desired background color
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildFilePreview(fileData),
//             ListTile(
//               // title: Text(
//               //   "File ${index + 1}",
//               //   style: TextStyle(color: Colors.white), // Text color
//               // ),
//               subtitle: _buildFileSubtitle(filesData[index]),
//             ),
//             _buildDownloadButton(fileData),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFileSubtitle(Map<String, dynamic> fileData) {
//     String fileName = fileData['fileName'];
//     String displayText = fileName.split('/').last;

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         displayText,
//         style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   getApplicationDocumentsDirectory() {}
// }
