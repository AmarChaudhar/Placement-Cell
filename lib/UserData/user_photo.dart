// import 'dart:io';

// import 'package:flutter/material.dart';

// class UserDrawerHeader extends StatelessWidget {
//   final File pickedFile;
//   final VoidCallback onRemovePhoto;
//   final VoidCallback onGallerySelected;
//   final VoidCallback onDeleteSelected;
//   final VoidCallback onProfileSelected;

//   const UserDrawerHeader({
//     Key? key,
//     required this.pickedFile,
//     required this.onRemovePhoto,
//     required this.onGallerySelected,
//     required this.onDeleteSelected,
//     required this.onProfileSelected,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: ClipOval(
//               child: Image.file(
//                 pickedFile,
//                 fit: BoxFit.cover,
//                 height: 150,
//                 width: 140,
//               ),
//             ),
//           ),
//           SizedBox(
//               height: 458), // Add some spacing between the image and buttons
//           ListView(
//             shrinkWrap: true,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.photo),
//                 title: Text('Gallery'),
//                 onTap: () {
//                   onGallerySelected();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.delete),
//                 title: Text('Delete'),
//                 onTap: () {
//                   onDeleteSelected();
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.camera),
//                 title: Text('Profile'),
//                 onTap: () {
//                   onProfileSelected();
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
