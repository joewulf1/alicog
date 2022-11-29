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
                    height: heightScreen * .90,
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
                    height: heightScreen * .90,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.blue),
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
                    height: heightScreen * .90,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.red),
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
          child: SizedBox(
            child: Center(child: Text(document["Content"])),
          ),
        ),
      ])),
    ),
  ]);
}

Widget itemTask(BuildContext context, DocumentSnapshot document) {
  String urgentMessage = "";
  String isUrgent() {
    if (document["Urgent"] == true) {
      urgentMessage = "This is urgent!";
      return urgentMessage;
    } else {
      urgentMessage = "This is not urgent.";
      return urgentMessage;
    }
  }

  //String test = document["Date Occuring"];
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
                child: Row(
                  children: [
                    Text(isUrgent()),
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
