import 'dart:async';

import 'package:alist_web/pages/homePage.dart';
import 'package:alist_web/pages/web/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashImagePage extends StatefulWidget {
  const SplashImagePage({super.key});

  @override
  State<StatefulWidget> createState() => SplashImageState();
}

class SplashImageState extends State<SplashImagePage> {
  // final String launchImage = "assets/images/splash/1.jpg";
  final String launchImage = "assets/native/images/splash/2.png";
  int _countdown = 2;
  late Timer _countdownTimer;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    super.initState();
    _startRecordTime();
    print('初始化启动页面');
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    print('启动页面结束');
    if (_countdownTimer.isActive) {
      _countdownTimer.cancel();
    }
  }

  void _startRecordTime() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown <= 1) {
//          Navigator.of(context).pushNamed("/demo1");
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return HomePage(
              key: UniqueKey(),
            );
          }));
          _countdownTimer.cancel();
        } else {
          _countdown -= 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO 等待加载完成就切换到列表页或者等到超时；加载网络图片或者广告
    return Scaffold(
      extendBody: true, //底部NavigationBar透明
      extendBodyBehindAppBar: true, //顶部Bar透明
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(child: Image.asset(launchImage, fit: BoxFit.fill)),
          Positioned(
            top: 30,
            right: 30,
            child: GestureDetector(
              onTap: () {
                _countdown = 1;
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black12,
                ),
                child: RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: '$_countdown',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                        )),
                    TextSpan(
                      text: "skip splash",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
