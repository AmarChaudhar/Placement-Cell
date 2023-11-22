import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void WebViewPage(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class CardData {
  String id; // make sure 'id' is defined in your class
  String title; // company name
  String field2; // job role
  String field3; // last date
  String field4; // required skills
  String field5; // apply link

  CardData({
    required this.id,
    required this.title,
    required this.field2,
    required this.field3,
    required this.field4,
    required this.field5,
  });
}

class CardWidget extends StatelessWidget {
  final Key key;
  final CardData cardData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  CardWidget({
    required this.key,
    required this.cardData,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: Card(
        key: ValueKey<String>(cardData.id),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Company: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${cardData.title}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "Job Role: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${cardData.field2}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "Last Date: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${cardData.field3}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "Required skills: ",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${cardData.field4}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       WebViewPage(cardData.field5);
                  //     },
                  //     child: const Text('Job Created'),
                  //   ),
                  // )
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text("Edit"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("Delete"),
                  ),
                ],
                onSelected: (value) {
                  if (value == 1) {
                    onEdit();
                  } else if (value == 2) {
                    onDelete();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
