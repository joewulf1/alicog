import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alicog',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Alicog TEST VERSION '), // loginPage();
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    var widthScreen = screen.width;
    var heightScreen = screen.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("Calendar"),
                  SizedBox(
                    width: widthScreen * .33,
                    height: heightScreen * .80,
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.green)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("Tasks"),
                  SizedBox(
                    width: widthScreen * .33,
                    height: heightScreen * .80,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .where("isNote?", isEqualTo: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: Loading());
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) => itemTask(
                                    context, snapshot.data!.docs[index]));
                          }
                        }),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FloatingActionButton.small(
                          heroTag: "taskAdd",
                          child: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => addTask()));
                          }),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("Notes"),
                  SizedBox(
                    width: widthScreen * .28,
                    height: heightScreen * .80,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .where("isNote?", isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: Loading());
                          } else {
                            return ListView.builder(
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) => itemNote(
                                    context, snapshot.data!.docs[index]));
                          }
                        }),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FloatingActionButton.small(
                          heroTag: "itemAdd",
                          child: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => addNote()));
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

Widget itemNote(BuildContext context, DocumentSnapshot document) {
  return Stack(children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: ExpansionTile(title: Text(document["Title"]), children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                child: Center(child: Text(document["Content"])),
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FloatingActionButton.small(
                          heroTag: "noteUpdate",
                          child: const Icon(Icons.update, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => updateNote(
                                          choiceID: document.id,
                                          title: document["Title"],
                                          content: document["Content"],
                                        )));
                          }),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FloatingActionButton.small(
                          heroTag: "noteDeletion",
                          child: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            delItem(document.id);
                          }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ])),
    ),
  ]);
}

Widget itemTask(BuildContext context, DocumentSnapshot document) {
  String urgentMessage = "";
  String isUrgent() {
    if (document["Urgent"] == "true") {
      urgentMessage = "This is urgent!";
      return urgentMessage;
    } else {
      urgentMessage = "This is not urgent.";
      return urgentMessage;
    }
  }

  return Stack(children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: ExpansionTile(title: Text(document["Title"]), children: [
        SizedBox(
          child: Center(
              child: Column(
            children: [
              //Text(document[test]),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(document["Content"]),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(isUrgent()),
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FloatingActionButton.small(
                                heroTag: "taskUpdate",
                                child: const Icon(Icons.update,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => updateTask(
                                                choiceID: document.id,
                                                title: document["Title"],
                                                content: document["Content"],
                                                urgent: document["Urgent"],
                                              )));
                                }),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FloatingActionButton.small(
                                heroTag: "taskDeletion",
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: () {
                                  delItem(document.id);
                                }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
        ),
      ])),
    ),
  ]);
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: SpinKitChasingDots(
          color: Color(0xff56805C),
          size: 50.0,
        ),
      ),
    );
  }
}

Future delItem(String docID) {
  return FirebaseFirestore.instance
      .collection("Users")
      .doc('9QEH87DWCydbWuV2jpML')
      .collection("Content")
      .doc(docID)
      .delete();
}

class addNote extends StatefulWidget {
  @override
  State<addNote> createState() => _addNoteState();
}

class _addNoteState extends State<addNote> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController noteTitle = TextEditingController();
  TextEditingController noteContent = TextEditingController();
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return AlertDialog(
      insetPadding: EdgeInsets.all(100),
      title: const Text('Add Note'),
      content: SizedBox(
        width: screen.width * .5,
        child: Stack(children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(noteTitle.text)
                            .set({"Title": noteTitle.text});
                      }
                    },
                    controller: noteTitle,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Title of Note',
                    ),
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(noteTitle.text)
                            .set({"Content": noteContent.text});
                      }
                    },
                    controller: noteContent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Content of Note',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(noteTitle.text)
                            .set({
                          "Title": noteTitle.text,
                          "Content": noteContent.text,
                          "isNote?": true
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              )),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class addTask extends StatefulWidget {
  @override
  State<addTask> createState() => _addTaskState();
}

class _addTaskState extends State<addTask> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskContent = TextEditingController();
  TextEditingController taskUrgent = TextEditingController();

  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Add Note'),
      content: SizedBox(
        width: screen.width * .5,
        child: Stack(children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({"Title": taskTitle.text});
                      }
                    },
                    controller: taskTitle,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Title of Task',
                    ),
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({"Content": taskContent.text});
                      }
                    },
                    controller: taskContent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Content of Task',
                    ),
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({"Urgent": taskUrgent.text});
                      }
                    },
                    controller: taskUrgent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter true or false';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText:
                          'Is the task urgent? (Please enter true or false)',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({
                          "Urgent": taskUrgent.text,
                          "Title": taskTitle.text,
                          "Content": taskContent.text,
                          "isNote?": false
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              )),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class updateNote extends StatefulWidget {
  updateNote(
      {Key? key,
      required this.choiceID,
      required this.title,
      required this.content});
  final String choiceID, title, content;
  @override
  State<updateNote> createState() =>
      _updateNoteState(choiceID: choiceID, title: title, content: content);
}

class _updateNoteState extends State<updateNote> {
  _updateNoteState(
      {Key? key,
      required this.choiceID,
      required this.title,
      required this.content});
  final String choiceID, title, content;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController noteTitle = TextEditingController();
  TextEditingController noteContent = TextEditingController();

  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Change Note'),
      content: SizedBox(
        width: screen.width * .5,
        child: Stack(children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(noteTitle.text)
                            .set({"Title": noteTitle.text});
                      }
                    },
                    controller: noteTitle,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Title of Note', hintText: title),
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(noteTitle.text)
                            .set({"Content": noteContent.text});
                      }
                    },
                    controller: noteContent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Content of Note', hintText: content),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(noteTitle.text)
                            .set({
                          "Title": noteTitle.text,
                          "Content": noteContent.text,
                          "isNote?": true
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              )),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class updateTask extends StatefulWidget {
  updateTask(
      {Key? key,
      required this.choiceID,
      required this.title,
      required this.content,
      required this.urgent});
  final String choiceID, title, content, urgent;
  @override
  State<updateTask> createState() => _updateTaskState(
      choiceID: choiceID, title: title, content: content, urgent: urgent);
}

class _updateTaskState extends State<updateTask> {
  _updateTaskState(
      {Key? key,
      required this.choiceID,
      required this.title,
      required this.content,
      required this.urgent});
  final String choiceID, title, content, urgent;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskContent = TextEditingController();
  TextEditingController taskUrgent = TextEditingController();
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Text('Add Note'),
      content: SizedBox(
        width: screen.width * .5,
        child: Stack(children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({"Title": taskTitle.text});
                      }
                    },
                    controller: taskTitle,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Title of Task', hintText: title),
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({"Content": taskContent.text});
                      }
                    },
                    controller: taskContent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Content of Task', hintText: content),
                  ),
                  TextFormField(
                    onFieldSubmitted: (value) {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({"Urgent": taskUrgent.text});
                      }
                    },
                    controller: taskUrgent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter true or false';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText:
                            'Is the task urgent? (Please enter true or false)',
                        hintText: urgent),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(taskTitle.text)
                            .set({
                          "Urgent": taskUrgent.text,
                          "Title": taskTitle.text,
                          "Content": taskContent.text,
                          "isNote?": false
                        });
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              )),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
