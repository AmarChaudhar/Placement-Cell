// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumeBuilder extends StatefulWidget {
  const ResumeBuilder({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ResumeBuilderState createState() => _ResumeBuilderState();
}

class _ResumeBuilderState extends State<ResumeBuilder> {
  Map<String, String> resumeData = {
    'Name': 'First Last',
    'Address': '123 Street Name, Town, State 12345',
    'Phone': '123-456-7890',
    'Email': 'email@gmail.com',
    'LinkedIn': 'linkedin.com/in/username',
    'GitHub': 'github.com/username',
    'Education':
        'Bachelor of Science in Computer Science\nState University\nSep. 2017 - May 2021',
    'Relevant Coursework':
        'Data Structures\nSoftware Methodology\nAlgorithms Analysis',
    'Experience':
        'Software Engineer Intern\nElectronics Company\nMay 2020 - August 2020',
    'Projects': 'Gym Reservation Bot\nTicket Price Calculator App',
    'Technical Skills':
        'Languages: Python, Java\nDeveloper Tools: VS Code, Android Studio',
    'Leadership/Extracurricular':
        'President, Fraternity\nUniversity Name\nSpring 2020 - Present',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Resume',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (String sectionName in resumeData.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectionName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: resumeData[sectionName],
                        onChanged: (value) {
                          setState(() {
                            resumeData[sectionName] = value;
                          });
                        },
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.all(12.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () {
                    generateAndDisplayResume(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Generate Resume'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateAndDisplayResume(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (String sectionName in resumeData.keys)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(sectionName,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text(resumeData[sectionName]!),
                    pw.SizedBox(height: 16),
                  ],
                ),
            ],
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    // Display or print the generated PDF using the pdf package
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }
}
