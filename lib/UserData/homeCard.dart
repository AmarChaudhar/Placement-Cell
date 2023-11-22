import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  //final String title;
  final String imagePath; // Image path parameter
  final Function onTap;

  HomeCard({
    //required this.title,
    required this.imagePath,
    required this.onTap,
    required String title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height * 0.245,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover, // Adjust the BoxFit as needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}
