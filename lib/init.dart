import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:alist_web/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:gtads/gtads.dart';
// import 'package:gtads_csj/gtads_csj.dart';
// import 'package:gtads_ylh/gtads_ylh.dart';
import 'package:jaguar/jaguar.dart' as jaguar;
import 'package:jaguar_flutter_asset/jaguar_flutter_asset.dart' as jaguar_flutter_asset;
import 'package:alist_mobile_service/alist_mobile_service.dart'
as alist_mobile_service;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/config.dart';

List<Map<String, bool>>? initList;
// final APIBaseUrl = "http://localhost:15244";
// final PasswordHasBeenSet = "PasswordHasBeenSet";

Future<void> init() async {
  Directory appDir = await  getApplicationDocumentsDirectory();
  print("appDir.path:${appDir.path}");
  initBackgroundService().then((_) async {
    await Future.delayed(Duration(milliseconds: 150));
    await setConfigData(appDir.path);
    await initAList();
    await startAList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(PasswordHasBeenSet)) {
      setAdminPassword("admin");
    }
  });
  // await initAD();
  initHttpAssets();
}

Future<void> setConfigData(String path) async {
  final dio = Dio(BaseOptions(baseUrl: AListWebAPIBaseUrl));
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
  final dio = Dio(BaseOptions(baseUrl: AListWebAPIBaseUrl));
  String reqUri = "/init";
  final response = await dio.getUri(Uri.parse(reqUri));
  if (response.statusCode == 200) {
    print("initAList,ok");
  } else {
    print("initAList,failed");
  }
}

Future<void> startAList() async {
  final dio = Dio(BaseOptions(baseUrl: AListWebAPIBaseUrl));
  String reqUri = "/start";
  final response = await dio.getUri(Uri.parse(reqUri));
  if (response.statusCode == 200) {
    print("startAList,ok");
  } else {
    print("startAList,failed");
  }
}

Future<void> setAdminPassword(String password) async {
  final dio = Dio(BaseOptions(baseUrl: AListWebAPIBaseUrl));
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
    jaguar.Jaguar(address: "0.0.0.0", port: 8889);
  // server.staticFile('/@manage', 'web/index.html');
  // server.staticFiles('/@*', 'assets/index.html');
  // server.addRoute(serveFlutterAssets(path:"/"));
  server.addRoute(myServeFlutterAssets("@manage"));
  server.addRoute(myServeFlutterAssets("@manage/settings/site"));
  server.addRoute(myServeFlutterAssets("@manage/tasks/offline_download"));
  server.addRoute(myServeFlutterAssets("@manage/storages"));
  server.addRoute(myServeFlutterAssets("@login"));
  server.addRoute(jaguar_flutter_asset.serveFlutterAssets(prefix: "web/"));
  server.serve(logRequests: true).then((v) {
    server.log.onRecord.listen((r) => debugPrint("==serve-log：$r"));
  });
}

jaguar.Route serveFlutterAssets(
    {String path = '*',
      bool stripPrefix = true,
      String prefix = '',
      Map<String, String>? pathRegEx,
      jaguar.ResponseProcessor? responseProcessor}) {
  jaguar.Route route;
  int skipCount = -1;
  route = jaguar.Route.get(path, (ctx) async {
    Iterable<String> segs = ctx.pathSegments;
    if (skipCount > 0) segs = segs.skip(skipCount);

    String lookupPath =
        segs.join('/') + (ctx.path.endsWith('/') ? 'index.html' : '');
    ctx.log.info("check contains");
    if (lookupPath.contains("@")){
      ctx.log.info("contains");
      lookupPath = '/index.html';
    }
    final body = (await rootBundle.load('assets/$prefix$lookupPath'))
        .buffer
        .asUint8List();

    String? mimeType;
    if (!ctx.path.endsWith('/')) {
      if (ctx.pathSegments.isNotEmpty) {
        final String last = ctx.pathSegments.last;
        if (last.contains('.')) {
          mimeType = jaguar.MimeTypes.fromFileExtension[last.split('.').last];
        }
      }
    } else {
      mimeType = 'text/html';
    }

    ctx.response = jaguar.ByteResponse(body: body, mimeType: mimeType);
  }, pathRegEx: pathRegEx, responseProcessor: responseProcessor);

  if (stripPrefix) skipCount = route.pathSegments.length - 1;

  return route;
}

jaguar.Route myServeFlutterAssets(String path) {
  jaguar.Route route;
  route = jaguar.Route.get(path, (ctx) async {
    final body = (await rootBundle.load('assets/web/index.html'))
        .buffer
        .asUint8List();

    String? mimeType = 'text/html';

    ctx.response = jaguar.ByteResponse(body: body, mimeType: mimeType);
  }, pathRegEx: null, responseProcessor: null);
  return route;
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
