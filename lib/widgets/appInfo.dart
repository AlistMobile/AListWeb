import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../l10n/generated/alistweb_localizations.dart';
import 'feedback.dart';
import 'goToUrl.dart';

class AppInfoPage extends StatefulWidget {
  AppInfoPage({required Key key}) : super(key: key);

  @override
  _AppInfoPageState createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  //APP名称
  String appName = "";

  //包名
  String packageName = "";

  //版本名
  String version = "";

  //版本号
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List _result = [];
    _result.add("${AListWebLocalizations.of(context).app_name}$appName");
    _result.add("${AListWebLocalizations.of(context).package_name}$packageName");
    _result.add("${AListWebLocalizations.of(context).version}$version");
    _result.add("${AListWebLocalizations.of(context).version_sn}$buildNumber");
    _result.add("${AListWebLocalizations.of(context).icp_number}皖ICP备2022013511号-2A");

    final tiles = _result.map(
      (pair) {
        return ListTile(
          title: Text(
            pair,
          ),
        );
      },
    );
    List<ListTile> tilesList = tiles.toList();
//     tilesList.add(ListTile(
//       title: Text(
//         AListWebLocalizations.of(context).feedback_channels,
//         style: TextStyle(color: Colors.green),
//       ),
//       onTap: () {
//         Navigator.of(context).push(MaterialPageRoute(builder: (context) {
// //              return Text("${pair.iP}:${pair.port}");
//           return FeedbackPage(
//             key: UniqueKey(),
//           );
//         }));
//       },
//     ));
    tilesList.add(ListTile(
      title: Text(
          AListWebLocalizations.of(context).online_feedback,
        style: TextStyle(color: Colors.green),
      ),
      onTap: () {
        launchURL("https://github.com/AlistMobile/AListWeb");
      },
    ));
    tilesList.add(ListTile(
      title: Text(
        AListWebLocalizations.of(context).privacy_policy,
        style: TextStyle(color: Colors.green),
      ),
      onTap: () {
        goToURL(context, "https://github.com/AlistMobile/AListWeb",
            AListWebLocalizations.of(context).privacy_policy);
      },
    ));
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tilesList,
    ).toList();

    return Scaffold(
      appBar: AppBar(title: Text(AListWebLocalizations.of(context).app_info), actions: <Widget>[
      ]),
      body: ListView(children: divided),
    );
  }

  _getAppInfo() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        packageName = packageInfo.packageName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });
  }
}
