import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class userVacancy extends StatefulWidget {
  const userVacancy({Key? key}) : super(key: key);

  @override
  State<userVacancy> createState() => _userVacancyState();
}

class _userVacancyState extends State<userVacancy> {
  late DatabaseReference _databaseReference;
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _databaseReference =
        FirebaseDatabase.instance.reference().child('jobsvacancy');
    _refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Future<void> _loadAnnouncementsFromDatabase() async {
    // Your existing code to fetch data from the database
  }

  Future<void> _refresh() async {
    // Call your existing load function when refreshing
    await _loadAnnouncementsFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Job Vacancies',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _databaseReference.once(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              Map<dynamic, dynamic>? jobData =
                  (snapshot.data?.snapshot.value as Map?) ?? {};

              List<Widget> jobCards = jobData.keys.map((jobId) {
                Map<dynamic, dynamic> jobDetails = jobData[jobId];

                return JobCard(
                  companyId: jobId,
                  companyName: jobDetails['companyName'],
                  jobRole: jobDetails['jobRole'],
                  lastDate: jobDetails['lastDate'],
                  requiredSkills: jobDetails['requiredSkills'],
                  jobLink: jobDetails['jobLink'],
                  applyFunction: () {
                    _applyForJob(
                      jobDetails['companyName'],
                      jobDetails['jobLink'],
                    );
                  },
                );
              }).toList();

              return ListView.builder(
                key: UniqueKey(),
                itemCount: jobCards.length,
                itemBuilder: (context, index) {
                  return jobCards[index];
                },
              );
            }
          },
        ),
      ),
    );
  }
}

void _applyForJob(String companyName, String jobLink) {
  print('Applying for job at $companyName via $jobLink');
  // Add your logic for handling the application process here
}

class JobCard extends StatelessWidget {
  final String companyName;
  final String jobRole;
  final String lastDate;
  final String requiredSkills;
  final String jobLink;
  final VoidCallback applyFunction;

  JobCard({
    required this.companyName,
    required this.jobRole,
    required this.lastDate,
    required this.requiredSkills,
    required this.jobLink,
    required this.applyFunction,
    required companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company: $companyName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue, // Adjust the color as needed
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Job Role: $jobRole',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Last Date: $lastDate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Required Skills: $requiredSkills',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                applyFunction(); // Call your existing apply function
                // Launch the website
                if (jobLink.isNotEmpty) {
                  launch(jobLink);
                } else {
                  // Handle the case where the job link is not available
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job link not available.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 33, 79, 186),
              ),
              child: const Center(
                child: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
