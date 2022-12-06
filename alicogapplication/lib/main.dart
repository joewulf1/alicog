import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

MeetingDataSource? events;

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
      debugShowCheckedModeBanner: false,
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
  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting(
        'Conference', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }

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
                      child: SfCalendar(
                        view: CalendarView.day,
                        dataSource: MeetingDataSource(_getDataSource()),
                        monthViewSettings: const MonthViewSettings(
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.appointment),
                      )),
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

class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}
// Future<void> getDataFromFireStore() async {
//   var snapShotsValue = await FirebaseFirestore.instance
//       .collection("Users")
//       .doc("9QEH87DWCydbWuV2jpML")
//       .collection("Content")
//       .where("scheduled", isEqualTo: true)
//       .get();

//   List<Meeting> list = snapShotsValue.docs
//       .map((e) => Meeting(
//           eventName: e.data()['Subject'],
//           from: DateFormat('dd/MM/yyyy HH:mm:ss').parse(e.data()['StartTime']),
//           to: DateFormat('dd/MM/yyyy HH:mm:ss').parse(e.data()['EndTime']),
//           background: Colors.green,
//           isAllDay: false))
//       .toList();
//     events = MeetingDataSource(list);
// }

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
                          heroTag: document["Title"],
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
                                heroTag: document.id,
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
                      if ((noteTitle.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Title": title,
                          "Content": noteContent.text,
                          "isNote?": true
                        });
                      } else if ((noteContent.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Title": noteTitle.text,
                          "Content": content,
                          "isNote?": true
                        });
                      }
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
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
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
                      }
                      return null;
                    },
                    controller: taskTitle,
                    decoration: InputDecoration(
                        labelText: 'Title of Task', hintText: title),
                  ),
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
                      }
                      return null;
                    },
                    controller: taskContent,
                    decoration: InputDecoration(
                        labelText: 'Content of Task', hintText: content),
                  ),
                  TextFormField(
                    controller: taskUrgent,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a some text';
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
                      if ((taskUrgent.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Urgent": urgent,
                          "Title": taskTitle.text,
                          "Content": taskContent.text,
                          "isNote?": false
                        });
                      } else if ((taskTitle.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Urgent": taskUrgent.text,
                          "Title": title,
                          "Content": taskContent.text,
                          "isNote?": false
                        });
                      } else if ((taskContent.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Urgent": taskUrgent.text,
                          "Title": taskTitle.text,
                          "Content": content,
                          "isNote?": false
                        });
                      } else if ((taskContent.text).isEmpty &&
                          (taskTitle.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Urgent": taskUrgent.text,
                          "Title": title,
                          "Content": content,
                          "isNote?": false
                        });
                      } else if ((taskContent.text).isEmpty &&
                          (taskUrgent.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Urgent": urgent,
                          "Title": taskTitle.text,
                          "Content": content,
                          "isNote?": false
                        });
                      } else if ((taskUrgent.text).isEmpty &&
                          (taskTitle.text).isEmpty) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
                            .set({
                          "Urgent": taskUrgent.text,
                          "Title": title,
                          "Content": content,
                          "isNote?": false
                        });
                      }
                      if (formKey.currentState!.validate()) {
                        FirebaseFirestore.instance
                            .collection("Users")
                            .doc('9QEH87DWCydbWuV2jpML')
                            .collection("Content")
                            .doc(choiceID)
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
