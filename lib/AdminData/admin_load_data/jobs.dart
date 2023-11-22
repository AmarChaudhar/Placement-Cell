import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:placement/AdminData/cardData.dart';
import 'package:url_launcher/url_launcher.dart';

class JobVacancyPage extends StatefulWidget {
  @override
  _JobVacancyPageState createState() => _JobVacancyPageState();
}

class _JobVacancyPageState extends State<JobVacancyPage> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController1 = TextEditingController();
  TextEditingController _textController2 = TextEditingController();
  TextEditingController _textController3 = TextEditingController();
  TextEditingController _textController4 = TextEditingController();
  TextEditingController _textController5 = TextEditingController();
  List<CardData> _cards = [];

  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('jobsvacancy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      DataSnapshot snapshot = event.snapshot;
      dynamic values = snapshot.value;

      if (this.mounted) {
        List<CardData> loadedCards = [];

        if (values != null && values is Map<dynamic, dynamic>) {
          loadedCards = values.entries.map<CardData>((entry) {
            return CardData(
              id: entry.key,
              title: entry.value['companyName'],
              field2: entry.value['jobRole'],
              field3: entry.value['lastDate'],
              field4: entry.value['requiredSkills'],
              field5: entry.value['jobLink'],
            );
          }).toList();
        }

        // Simulate a delay for a more smooth transition
        await Future.delayed(Duration(milliseconds: 250));

        if (this.mounted) {
          setState(() {
            _cards = loadedCards;
          });
        }
      }
    } catch (error) {
      print("Error loading data: $error");
    }
  }

  void _toggleFormVisibility() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _createNewCard() {
    if (_formKey.currentState!.validate()) {
      String newCardId = _databaseReference.push().key ?? "";
      CardData newCard = CardData(
        id: newCardId,
        title: _textController1.text,
        field2: _textController2.text,
        field3: _textController3.text,
        field4: _textController4.text,
        field5: _textController5.text,
      );

      // Save data to Firebase
      _databaseReference.child(newCardId).set({
        'companyName': newCard.title,
        'jobRole': newCard.field2,
        'lastDate': newCard.field3,
        'requiredSkills': newCard.field4,
        'jobLink': newCard.field5,
      });

      setState(() {
        _cards.add(newCard);

        // Clear the text fields and hide the form
        _textController1.clear();
        _textController2.clear();
        _textController3.clear();
        _textController4.clear();
        _textController5.clear();
        _showForm = false;
      });
    }
  }

  void WebViewPage(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _editCard(int index) async {
    // Show a dialog or navigate to a new screen to edit the card content
    final editedData = await showDialog<CardData>(
      context: context,
      builder: (context) {
        CardData editedCardData =
            _cards[index]; // Initialize with existing data
        return AlertDialog(
          title: const Text("Edit Card"),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: editedCardData.title,
                  onChanged: (value) {
                    editedCardData.title = value;
                  },
                  decoration: const InputDecoration(labelText: "Company Name"),
                ),
                TextFormField(
                  initialValue: editedCardData.field2,
                  onChanged: (value) {
                    editedCardData.field2 = value;
                  },
                  decoration: const InputDecoration(labelText: "Job Role"),
                ),
                TextFormField(
                  initialValue: editedCardData.field3,
                  onChanged: (value) {
                    editedCardData.field3 = value;
                  },
                  decoration:
                      const InputDecoration(labelText: "Last Date To Apply"),
                ),
                TextFormField(
                  initialValue: editedCardData.field4,
                  onChanged: (value) {
                    editedCardData.field4 = value;
                  },
                  decoration:
                      const InputDecoration(labelText: "Required skills"),
                ),
                TextFormField(
                  initialValue: editedCardData.field5,
                  onChanged: (value) {
                    editedCardData.field5 = value;
                  },
                  decoration: const InputDecoration(labelText: "Apply Link"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(editedCardData);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (editedData != null) {
      // Update the card data with the edited data
      setState(() {
        _cards[index] = editedData;

        // Update data in Firebase
        String cardId = _cards[index].id;
        if (cardId.isNotEmpty) {
          _databaseReference.child(cardId).update({
            'companyName': editedData.title,
            'jobRole': editedData.field2,
            'lastDate': editedData.field3,
            'requiredSkills': editedData.field4,
            'jobLink': editedData.field5,
          });
        }
      });
    }
  }

  void _deleteCard(int index) {
    setState(() {
      // Delete data from Firebase
      _databaseReference.child(_cards[index].id).remove();

      _cards.removeAt(index);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          "Jobs",
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 32,
            icon: _showForm ? const Icon(Icons.cancel) : const Icon(Icons.add),
            onPressed: _toggleFormVisibility,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm)
            Form(
              key: _formKey,
              child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                children: [
                  SimpleDialogOption(
                    child: TextFormField(
                      controller: _textController1,
                      decoration: const InputDecoration(
                        labelText: "Company Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      controller: _textController2,
                      decoration: const InputDecoration(
                        labelText: "Job Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      controller: _textController3,
                      decoration: const InputDecoration(
                        labelText: "Last Date To Apply",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      controller: _textController4,
                      decoration: const InputDecoration(
                        labelText: "Required skills",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      controller: _textController5,
                      decoration: const InputDecoration(
                        labelText: "Apply Link",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _createNewCard,
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        side: BorderSide(
                            // width: 0.1,

                            color: Colors.blue), // Set border width and color
                      ),
                      primary: Colors.blue, // Button color
                      onPrimary: Colors.white, // Text color
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "Create Card",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_cards.isEmpty)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return CardWidget(
                    cardData: _cards[index],
                    onEdit: () => _editCard(index),
                    onDelete: () => _deleteCard(index),
                    key: ValueKey<String>(_cards[index].id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
