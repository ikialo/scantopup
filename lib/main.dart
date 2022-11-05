import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay/model.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  OverlayFormat format = OverlayFormat.simID000;
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: (value) {
          setState(() {
            tab = value;
          });
          switch (value) {
            case (0):
              setState(() {
                format = OverlayFormat.simID000;
              });
              break;
            case (1):
              setState(() {
                format = OverlayFormat.simID000;
              });
              break;
            case (2):
              setState(() {
                format = OverlayFormat.simID000;
              });
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail), label: 'US ID'),
          BottomNavigationBarItem(icon: Icon(Icons.sim_card), label: 'Sim'),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No camera founded',
                    style: TextStyle(color: Colors.black),
                  ));
            }
            return CameraOverlay(
                snapshot.data!.first,
                CardOverlay.byFormat(format),
                (XFile file) => showDialog(
                      context: context,
                      barrierColor: Colors.black,
                      builder: (context) {
                        CardOverlay overlay = CardOverlay.byFormat(format);
                        return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            backgroundColor: Colors.black,
                            title: const Text('Capture',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center),
                            actions: [
                              OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Icon(Icons.close))
                            ],
                            content: SizedBox(
                                width: double.infinity,
                                child: AspectRatio(
                                  aspectRatio: overlay.ratio!,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      alignment: FractionalOffset.center,
                                      image: FileImage(
                                        File(file.path),
                                      ),
                                    )),
                                  ),
                                )));
                      },
                    ),
                info:
                    'Position your  Prepid card within the rectangle and ensure the image is perfectly readable.',
                label: 'Scanning Prepaid Card');
          } else {
            return const Align(
                alignment: Alignment.center,
                child: Text(
                  'Fetching cameras',
                  style: TextStyle(color: Colors.black),
                ));
          }
        },
      ),
    ));
  }
}
