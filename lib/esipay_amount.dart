import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scantopup/EsiPayScreen.dart';
import 'package:scantopup/db_esipay.dart';

import 'ad_helper.dart';

class EsiPayAmount extends StatefulWidget {
  final String title;
  final int number;
  const EsiPayAmount({Key? key, required this.title, required this. number}) : super(key: key);

  @override
  State<EsiPayAmount> createState() => _EsiPayAmountState();
}

class _EsiPayAmountState extends State<EsiPayAmount> {

  bool important = false;
  final titleController = TextEditingController();
  final amount = TextEditingController();

  BannerAd? _bannerAd;


  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

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



  @override
  Widget build(BuildContext context) {
    return Stack(

      children: [

        if (_bannerAd != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),

      Align(child: IconButton(icon: Icon(Icons.close),onPressed: (){
        Navigator.pop(context);
      },), alignment: Alignment.topRight, ),
      Container(

        height: 320,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 18, right: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Title :", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(widget.title),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Esi Pay # :", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(widget.number.toString()),
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: amount,
                decoration: const InputDecoration(
                  label: Center(child: const Text('Amount')),
                ),
              ),

              MaterialButton(
                color: Colors.purple,
                height: 50,
                minWidth: double.infinity,
                onPressed: () {

                  FlutterPhoneDirectCaller.callNumber("*775*${widget.number}*${amount.value.text}#");

                },
                child: const Text(
                  'Buy Esi Pay',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
  ]
    );
  }
}