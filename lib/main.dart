import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay/model.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:scantopup/EsiPayScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'ad_helper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        primarySwatch: Colors.purple,
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
  late InterstitialAd _interstitialAd;

  bool isadloaded = false;
  OverlayFormat format = OverlayFormat.simID000;
  int tab = 0;
  bool flash = false;
  bool clearRead = false;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final alphanumeric = RegExp(r'(\d{2,}\s){1,}');

  late final TextRecognizer _textDetector;

  final Uri _url = Uri.parse('https://ikialoec.web.app');
  final Uri _urlpp =
      Uri.parse('https://sites.google.com/view/telitopupprivacypolicy/home');

  BannerAd? _bannerAd;

  @override
  void initState() {
    // TODO: implement initState
    _textDetector = TextRecognizer();

    _initGoogleMobileAds();

    InterstitialAd.load(
        adUnitId: AdHelper.intetsititalAd,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}));

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          // print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();

    super.initState();
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;

    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {

        _interstitialAd.dispose();
        isadloaded = true;


      },
      onAdFailedToShowFullScreenContent: (ad, error) =>
          _interstitialAd.dispose(),
    );
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }

    return double.parse(
          s,
        ) !=
        null;
  }

  void _recognizTexts(imagePath) async {
    // Creating an InputImage object using the image path
    await analytics.logEvent(name: 'Image Taken');

    final croppedImg = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 5.0, ratioY: 1.0));

    final inputImage = InputImage.fromFilePath(
        croppedImg!.path); // Retrieving the RecognisedText from the InputImage
    final text =
        await _textDetector.processImage(inputImage); // Finding text String(s)
    for (TextBlock block in text.blocks) {
      for (TextLine line in block.lines) {
        if (alphanumeric.hasMatch(line.text)) {
          // print('text: ${line.text}');
          String newline = line.text.replaceAll(RegExp(r'\s+'), "");
          // print('text: ${newline}');

          if (isNumeric(newline)) {
            await analytics.logEvent(name: 'CardScanned');

            await Clipboard.setData(ClipboardData(text: newline));
            FlutterPhoneDirectCaller.callNumber("*121*${newline}#");
            clearRead = true;

            // run intersitial
            if (!isadloaded){
              _interstitialAd.show();

            }

            break;
          }
        }
      }
    }
    if (!clearRead) {
      Flushbar(
        title: "Scanned Image Not Clear",
        message: "Please Check If Prepaid Card has all digits showing",
        duration: Duration(seconds: 5),
      )..show(context);
    }

    clearRead = false;
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
            child: Scaffold(
                drawer: Drawer(
                  child: ListView(
                    // Important: Remove any padding from the ListView.
                    padding: EdgeInsets.zero,
                    children: [
                      const DrawerHeader(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: ExactAssetImage(
                                  "assets/icons/ScanTopUp.png")),
                          color: Color.fromARGB(255, 185, 120, 238),
                        ),
                        child: Text('Menu'),
                      ),
                      ListTile(
                        title: const Text('Privacy Policy'),
                        onTap: () {
                          // Update the state of the app.
                          // ...
                          _launchUrl(_urlpp);
                        },
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Theme(
                  data: Theme.of(context).copyWith(
                    // sets the background color of the `BottomNavigationBar`
                      canvasColor: Colors.white,
                      // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                      primaryColor: Colors.red,
                      textTheme: Theme
                          .of(context)
                          .textTheme
                          .copyWith(caption: new TextStyle(color: Colors.yellow))),
                  child: BottomNavigationBar(
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
                          _launchUrl(_url);

                          break;
                      }
                    },
                    items: const [
                      BottomNavigationBarItem(
                        backgroundColor: Colors.purple,
                        icon: Icon(Icons.credit_card),
                        label: 'Scan',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.explore), label: 'Explore'),
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
                body: Stack(children: [
                  FutureBuilder<List<CameraDescription>?>(
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
                          (XFile file) {
                            // print(File(file.path));
                            _recognizTexts(file.path);
                          },
                          info:
                              'Position your Prepaid card within the rectangle and ensure the image is perfectly readable.',
                          label: 'Scanning Prepaid Card',
                          flash: flash,
                        );
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
                  if (_bannerAd != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Container(
                        child: IconButton(
                          icon: Icon(!flash
                              ? Icons.flash_on_outlined
                              : Icons.flash_off),
                          onPressed: () {
                            setState(() {
                              flash = !flash;
                            });
                          },
                          color: flash ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 115,
                    left: 4,
                    child: Card(
                      borderOnForeground: true,
                      color: Colors.purple,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (){
                                // run intersitial
                                if (!isadloaded){
                                  _interstitialAd.show();

                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const EsiPayScreen(),
                                  ),
                                );
                              },
                              child: Container(

                                height: 120,
                                width: 120,
                                child: Card(
                                    color: Colors.grey.withOpacity(0.5),

                                    elevation: 15,
                                    shadowColor: Colors.black,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Text("EsiPay",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                        ),
                                        // Card(
                                        //   elevation: 8,
                                        //   shadowColor: Colors.black,
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(4.0),
                                        //     child: Image.asset(
                                        //       'assets/icons/power.png',
                                        //       height: 70,
                                        //       width: 70,
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: (){
                                // run intersitial
                                if (!isadloaded){
                                  _interstitialAd.show();

                                }
                                FlutterPhoneDirectCaller.callNumber("*675#");

                              },
                              child: Container(
                                // decoration: BoxDecoration(
                                //   gradient: LinearGradient(
                                //     begin: Alignment.topRight,
                                //     end: Alignment.bottomLeft,
                                //     colors: [
                                //       Color.fromRGBO(33, 150, 243, 1),
                                //       Color.fromRGBO(244, 67, 54, 1),
                                //     ],
                                //   ),
                                // ),
                                height: 120,
                                width: 120,
                                child: Card(
                                    color: Colors.grey.withOpacity(0.5),

                                    elevation: 15,
                                    shadowColor: Colors.black,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Text("*675#",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                        ),
                                        // Card(
                                        //
                                        //   elevation: 8,
                                        //   shadowColor: Colors.black,
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(4.0),
                                        //     child: Image.asset(
                                        //       'assets/icons/power.png',
                                        //       height: 70,
                                        //       width: 70,
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    )),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                // run intersitial


                                if (!isadloaded){
                                  _interstitialAd.show();

                                }
                                FlutterPhoneDirectCaller.callNumber("*777#");


                              },
                              child: Container(

                                height: 120,
                                width: 120,
                                child: Card(
                                    color: Colors.grey.withOpacity(0.5),
                                    elevation: 15,
                                    shadowColor: Colors.black,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Text("*777#",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                        ),
                                        // Card(
                                        //   elevation: 8,
                                        //   shadowColor: Colors.black,
                                        //   child: Padding(
                                        //     padding: const EdgeInsets.all(4.0),
                                        //     child: Image.asset(
                                        //       'assets/icons/power.png',
                                        //       height: 70,
                                        //       width: 70,
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    )),
                              ),
                            )
                          ],
                        )),
                      ),
                    ),
                  )
                ]))));
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    flash = false;
    super.dispose();
  }
}



/*
*  delete id missing from class for deleting
*
* */
