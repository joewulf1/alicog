import 'package:flutter/material.dart';

void main() {
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
              child: SizedBox(
                width: widthScreen * .28,
                height: heightScreen,
                child:
                    DecoratedBox(decoration: BoxDecoration(color: Colors.red)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: widthScreen * .33,
                height: heightScreen,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.green)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: widthScreen * .33,
                height: heightScreen,
                child:
                    DecoratedBox(decoration: BoxDecoration(color: Colors.blue)),
              ),
            ),
          ],
        ));
  }
}
