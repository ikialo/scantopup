import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scantopup/Add_Esipay.dart';
import 'package:scantopup/Esipayitem.dart';
import 'package:scantopup/main.dart';

import 'ad_helper.dart';
import 'db_esipay.dart';
import 'esipay_amount.dart';
import 'esipay_widget.dart';

class EsiPayScreen extends StatefulWidget {
  const EsiPayScreen({Key? key}) : super(key: key);

  @override
  State<EsiPayScreen> createState() => _EsiPayScreenState();
}

class _EsiPayScreenState extends State<EsiPayScreen> {
  List<EsiPayModel> myEsipay = [];

  BannerAd? _bannerAd;



  @override
  void initState() {
    initDb();
    getTodos();

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

  void initDb() async {
    await DatabaseRepository.instance.database;
  }

  void getTodos() async {
    await DatabaseRepository.instance.getAllTodos().then((value) {
      setState(() {
        myEsipay = value;
      });
    }).catchError((e) => debugPrint(e.toString()));
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // You can do some work here.
        // Returning true allows the pop to happen, returning false prevents it.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: "title"),
          ),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text("EsiPay")),

        ),
        body: Stack ( children :
            [
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
              myEsipay.isEmpty
            ? const Center(child: const Text('You don\'t have any Esi Pay Meter # yet'))
            : Padding(
              padding: const EdgeInsets.only(top: 70),
              child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
              height: 20,
          ),
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
              final todo = myEsipay[index];
              return GestureDetector(
                  onTap: (){

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(child: EsiPayAmount(title: todo.title, number: todo.Esipaynum,),)
                        ;
                      },
                    );

                  },
                  child: TodoWidget(todo: todo));
          },
          itemCount: myEsipay.length,
              ),
            )]),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(child: AddTodoScreen(),)
                ;
              },
            );
          },
        ),
      ),
    );
  }
}
