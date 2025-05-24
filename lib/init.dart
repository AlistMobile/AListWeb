import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:gtads/gtads.dart';
import 'package:gtads_csj/gtads_csj.dart';
import 'package:gtads_ylh/gtads_ylh.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';
import 'package:alist_mobile_service/alist_mobile_service.dart'
as alist_mobile_service;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

List<Map<String, bool>>? initList;

Future<void> init() async {
  Directory appDir = await  getApplicationDocumentsDirectory();
  print("appDir.path:${appDir.path}");
  initBackgroundService();
  await initAD();
  initHttpAssets();
}

void run(dynamic) async {
  alist_mobile_service.run();
}

Future<void> initBackgroundService() async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setBool("foreground", true);
  Isolate.spawn(run, null);
}

Future<void> initHttpAssets() async {
  final server =
      Jaguar(address: "0.0.0.0", port: 8889);
  server.addRoute(serveFlutterAssets());
  server.serve(logRequests: true).then((v) {
    server.log.onRecord.listen((r) => debugPrint("==serve-log：$r"));
  });
}

Future initAD() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(Platform.isAndroid && (!prefs.containsKey(Agreed_Privacy_Policy) || !(prefs.getBool(Agreed_Privacy_Policy)!))){
    return;
  }
  //添加Provider列表
  GTAds.addProviders([
    GTAdsCsjProvider("csj", "5695020", "5695009", appName: "AListWeb"),
    GTAdsYlhProvider("ylh", "1210892167", "1210892181")
  ]);
  initList = await GTAds.init(isDebug: true);
}
