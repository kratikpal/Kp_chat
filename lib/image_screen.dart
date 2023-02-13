import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class MyImageScreen extends StatefulWidget {
  const MyImageScreen({super.key});

  @override
  State<MyImageScreen> createState() => _MyImageScreenState();
}

class _MyImageScreenState extends State<MyImageScreen> {
  final TextEditingController _inputTextController = TextEditingController();
  late bool isLoading;
  late bool isSaving;
  bool isConnected = false;
  final Connectivity _connectivity = Connectivity();
  String imageUrl = "";

  // Banner Ad
  final BannerAd myBanner = BannerAd(
    adUnitId: "Banner_ad_unit_id",
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  final BannerAdListener myBannerAdListener = BannerAdListener(
    onAdFailedToLoad: (ad, error) => ad.dispose(),
  );

  // Interstitial ad
  InterstitialAd? myInterstitialAd;
  _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "Interstitial_ad_unit_id",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          myInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) => myInterstitialAd = null,
      ),
    );
  }

  _showInterstitialAd() {
    if (myInterstitialAd != null) {
      myInterstitialAd!.show();
    }
    myInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );
  }

  // Rewarded Ad
  RewardedAd? myRewardedAd;
  _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "Rewarded_ad_unit_id",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          myRewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) => myRewardedAd = null,
      ),
    );
  }

  Future<void> _showRewardedAd() async {
    if (myRewardedAd != null) {
      myRewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      });
    }
    myRewardedAd!.show(
      onUserEarnedReward: (ad, reward) => setState(() async {
        if (await Permission.storage.request().isGranted) {
          setState(() => isSaving = true);
          _save();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: 'Open Settings',
            desc: "Storage permission is not granted",
            btnOkOnPress: () => openAppSettings(),
            btnCancelOnPress: () {},
          ).show();
        }
      }),
    );
    myRewardedAd = null;
  }

  Future<void> _checkConnectivity() async {
    var connectionResult = await _connectivity.checkConnectivity();
    if (connectionResult == ConnectivityResult.none) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'No Internet Connection',
        desc: 'Please connect to internet and try again...',
        btnOkOnPress: () => _checkConnectivity(),
      ).show();
      setState(() => isConnected = false);
    } else {
      setState(() => isConnected = true);
    }
  }

  _save() async {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
    );
    String msg = "Not Success";
    if (result["isSuccess"] == true) {
      msg = "Saved in Gallery";
      setState(() => isSaving = false);
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  Future<String> _getImage(String question) async {
    String apiKey = "ApiKey";
    String url = "https://api.openai.com/v1/images/generations";

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };

    final response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(
        {
          "prompt": question,
          "n": 1,
          "size": "1024x1024",
        },
      ),
    );

    var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      return data['data'][0]['url'];
    } else {
      var error = data['error'];
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Error',
        desc: error!["message"],
        btnOkOnPress: () {},
      ).show();
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    isLoading = false;
    isSaving = false;
    myBanner.load();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    myBanner.dispose();
    myInterstitialAd?.dispose();
    myRewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(fit: StackFit.expand, children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 20),
          child: Image.asset(
            "assets/images/4954390_2599646.jpg",
            fit: BoxFit.fill,
          ),
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _inputTextController,
                        decoration: InputDecoration(
                          labelText: 'What you want to draw',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await _checkConnectivity();
                        if (isConnected) {
                          if (_inputTextController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Enter some text",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 16.0);
                          } else {
                            setState(() => isLoading = true);
                            _getImage(_inputTextController.text).then((value) {
                              setState(() {
                                isLoading = false;
                                imageUrl = value;
                              });
                            });
                            _showInterstitialAd();
                          }
                          _inputTextController.clear();
                        }
                      },
                      elevation: 0,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 5,
                              color: imageUrl.isNotEmpty
                                  ? const Color.fromARGB(255, 19, 20, 121)
                                  : Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InteractiveViewer(
                            clipBehavior: Clip.none,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Visibility(
                          visible: imageUrl.isNotEmpty,
                          child: FloatingActionButton.extended(
                            onPressed: () async {
                              if (isSaving) {
                              } else {
                                await _showRewardedAd();
                              }
                            },
                            label: isSaving
                                ? const Text("Saving to Gallery")
                                : const Text(
                                    "Save to Gallery",
                                  ),
                            icon: isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Icon(Icons.save_rounded),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: myBanner.size.width.toDouble(),
                height: myBanner.size.height.toDouble(),
                child: AdWidget(ad: myBanner),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
