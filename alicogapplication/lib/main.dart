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
                                  itemExtent: 80.0,
                                  itemCount: snapshot.data?.docs.length,
                                  itemBuilder: (context, index) => baseCard(
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
                                  itemExtent: 80.0,
                                  itemCount: snapshot.data?.docs.length,
                                  itemBuilder: (context, index) => baseCard(
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

Widget baseCard(BuildContext context, DocumentSnapshot document) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
        child: InkWell(
      splashColor: Colors.blue.withAlpha(30),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(document["Title"])),
            Padding(
              padding: const EdgeInsets.all(8.0),
              // child: FloatingActionButton.small(
              //     heroTag: document.id,
              //     child: const Icon(Icons.delete, color: Colors.white),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) =>
              //                 youSure(context, document, document.id)),
              //       );
              //     }),
            ),
          ],
        ),
      ),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => collectionPage(choiceID: document.id)),
        // );
      },
    )),
  );
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
