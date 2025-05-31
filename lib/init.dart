import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:alist_web/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:gtads/gtads.dart';
// import 'package:gtads_csj/gtads_csj.dart';
// import 'package:gtads_ylh/gtads_ylh.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart';
import 'package:alist_mobile_service/alist_mobile_service.dart'
as alist_mobile_service;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

List<Map<String, bool>>? initList;
final APIBaseUrl = "http://localhost:15244";
final PasswordHasBeenSet = "PasswordHasBeenSet";

Future<void> init() async {
  Directory appDir = await  getApplicationDocumentsDirectory();
  print("appDir.path:${appDir.path}");
  initBackgroundService().then((_) async {
    await Future.delayed(Duration(milliseconds: 5));
    await setConfigData(appDir.path);
    await initAList();
    await startAList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(PasswordHasBeenSet)) {
      setAdminPassword("admin");
    }
  });
  // await initAD();
  // initHttpAssets();
}

Future<void> setConfigData(String path) async {
  final dio = Dio(BaseOptions(baseUrl: APIBaseUrl));
  String reqUri = "/set-config-data";
  final response = await dio.getUri(Uri(path: reqUri, queryParameters: {
    "path": path
  }));
  if (response.statusCode == 200) {
    print("setConfigData:${path},ok");
  } else {
    print("setConfigData:${path},failed");
  }
}

Future<void> initAList() async {
  final dio = Dio(BaseOptions(baseUrl: APIBaseUrl));
  String reqUri = "/init";
  final response = await dio.getUri(Uri.parse(reqUri));
  if (response.statusCode == 200) {
    print("initAList,ok");
  } else {
    print("initAList,failed");
  }
}

Future<void> startAList() async {
  final dio = Dio(BaseOptions(baseUrl: APIBaseUrl));
  String reqUri = "/start";
  final response = await dio.getUri(Uri.parse(reqUri));
  if (response.statusCode == 200) {
    print("startAList,ok");
  } else {
    print("startAList,failed");
  }
}

Future<void> setAdminPassword(String password) async {
  final dio = Dio(BaseOptions(baseUrl: APIBaseUrl));
  String reqUri = "/set-admin-password";
  final response = await dio.getUri(Uri(path: reqUri, queryParameters: {
    "password": password
  }));
  if (response.statusCode == 200) {
    print("setAdminPassword:${password},ok");
    print(response.data);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(PasswordHasBeenSet, true);
  } else {
    print("setAdminPassword:${password},failed");
  }
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
  // server.staticFiles('/*', 'assets/web'); // The magic!
  server.serve(logRequests: true).then((v) {
    server.log.onRecord.listen((r) => debugPrint("==serve-log：$r"));
  });
}

// Future initAD() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   if(Platform.isAndroid && (!prefs.containsKey(Agreed_Privacy_Policy) || !(prefs.getBool(Agreed_Privacy_Policy)!))){
//     return;
//   }
//   //添加Provider列表
//   GTAds.addProviders([
//     GTAdsCsjProvider("csj", "5695020", "5695009", appName: "AListWeb"),
//     GTAdsYlhProvider("ylh", "1210892167", "1210892181")
//   ]);
//   initList = await GTAds.init(isDebug: true);
// }
