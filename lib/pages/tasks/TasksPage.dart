import 'dart:developer';

import 'package:alist_web/pages/common/appInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../config/config.dart';
import '../../config/global.dart';
import '../../init.dart';
import '../../l10n/generated/alistweb_localizations.dart';

GlobalKey<TasksPageState> webGlobalKey = GlobalKey();

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return TasksPageState();
  }
}

class TasksPageState extends State<TasksPage> {
  InAppWebViewController? _webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    allowsInlineMediaPlayback: true,
    allowBackgroundAudioPlaying: true,
    iframeAllowFullscreen: true,
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    useShouldOverrideUrlLoading: true,
  );

  double _progress = 0;
  String? _url;
  // String _url = "http://localhost:8889";
  // String _url = "http://localhost:15244";
  // String _url = "https://baidu.com";
  bool _canGoBack = false;
  String startUrl = "@manage/tasks/offline_download";
  String uri = "";

  onClickNavigationBar() {
    log("onClickNavigationBar");
    _webViewController?.reload();
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 1),(){_webViewController?.reload();});
  }

  @override
  void dispose() {
    _webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_canGoBack,
        onPopInvoked: (didPop) async {
          log("onPopInvoked $didPop");
          if (didPop) return;
          _webViewController?.goBack();
        },
        child: Scaffold(
          appBar: AppBar(
            // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("AListWeb"),
            actions: [
              // IconButton(onPressed: (){_changeDataPath();}, icon: Icon(Icons.file_copy_outlined)),
              IconButton(onPressed: (){_changePassword();}, icon: Icon(Icons.password)),
              IconButton(onPressed: (){_webViewController?.reload();}, icon: Icon(Icons.refresh)),
              IconButton(onPressed: (){_showAppInfo();}, icon: Icon(Icons.info))
            ],
          ),
          body: Column(children: <Widget>[
            _textTypeTabBar4tabs(context),
            // SizedBox(height: MediaQuery.of(context).padding.top),
            // LinearProgressIndicator(
            //   value: _progress,
            //   backgroundColor: Colors.grey[200],
            //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            // ),
            Expanded(
              child: InAppWebView(
                initialSettings: settings,
                initialUrlRequest: URLRequest(url: WebUri("$AListAPIBaseUrl/$startUrl")),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onLoadStart: (InAppWebViewController controller, Uri? url) {
                  log("onLoadStart $url");
                  setState(() {
                    _progress = 0;
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  log("shouldOverrideUrlLoading ${navigationAction.request.url}");

                  var uri = navigationAction.request.url!;
                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    log("shouldOverrideUrlLoading ${uri.toString()}");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }

                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onReceivedError: (controller, request, error) async {
                // TODO
                //   print(request.url);
                //   print(request.url.path);
                //   if (request.url.toString() == APIBaseUrl) {
                //     _webViewController?.reload();
                //     setState(() {
                //
                //     });
                //   }
                },
                onDownloadStartRequest: (controller, url) async {
                  Get.showSnackbar(GetSnackBar(
                    title: AListWebLocalizations.of(context).downloadThisFile,
                    message: url.suggestedFilename ??
                        url.contentDisposition ??
                        url.toString(),
                    duration: const Duration(seconds: 3),
                    mainButton: Column(children: [
                      TextButton(
                        onPressed: () {
                          launchUrlString(url.url.toString());
                        },
                        child: Text(AListWebLocalizations.of(context).download),
                      ),
                    ]),
                    onTap: (_) {
                      Clipboard.setData(
                          ClipboardData(text: url.url.toString()));
                      Get.closeCurrentSnackbar();
                      Get.showSnackbar(GetSnackBar(
                        message: AListWebLocalizations.of(context).copiedToClipboard,
                        duration: const Duration(seconds: 1),
                      ));
                    },
                  ));
                },
                onLoadStop:
                    (InAppWebViewController controller, Uri? url) async {
                  setState(() {
                    _progress = 0;
                  });
                  if (!tokenSetted) {
                    tokenSetted = true;
                    controller.webStorage.localStorage
                        .setItem(key: 'token', value: token);
                    controller.reload();
                  }
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress / 100;
                    if (_progress == 1) _progress = 0;
                  });
                  controller.canGoBack().then((value) => setState(() {
                        _canGoBack = value;
                      }));
                },
                onUpdateVisitedHistory: (InAppWebViewController controller,
                    WebUri? url, bool? isReload) {
                  _url = url.toString();
                },
              ),
            ),
          ]),
        ));
  }

  _changeDataPath(){

  }

  _changePassword(){
    TextEditingController passwordController =
    TextEditingController.fromValue(TextEditingValue(text: ""));
    showDialog(context: context, builder: (_){
      return AlertDialog(
          title: Text(AListWebLocalizations.of(context).modify_password),
          content: SizedBox(
              width: 250,
              height: 200,
              child: ListView(
                children: <Widget>[
                  Text("username: admin", style: TextStyle(fontSize: 16),),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      labelText: AListWebLocalizations.of(context).password,
                      helperText:
                      AListWebLocalizations.of(context).password,
                    ),
                  ),
                ],
              )),
          actions: <Widget>[
            TextButton(
              child: Text(AListWebLocalizations.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AListWebLocalizations.of(context).modify),
              onPressed: () async {
                // TODO
                setAdminPassword(passwordController.text);
                Navigator.of(context).pop();
              },
            )
          ]);
    });
  }

  Widget _textTypeTabBar4tabs(BuildContext context) {
    return TDBottomTabBar(TDBottomTabBarBasicType.text,
        useVerticalDivider: false,
        navigationTabs: [
          TDBottomTabBarTabConfig(
            tabText: 'download',
            onTap: () {
              setState(() {
                uri = "@manage/tasks/offline_download";
                _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(getUrlByUri(uri))));
              });
            },
          ),
          TDBottomTabBarTabConfig(
            tabText: 'upload',
            onTap: () {
              setState(() {
                uri = "@manage/tasks/upload";
                _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(getUrlByUri(uri))));
              });
            },
          ),
          TDBottomTabBarTabConfig(
            tabText: 'copy',
            onTap: () {
              setState(() {
                uri = "@manage/tasks/copy";
                _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(getUrlByUri(uri))));
              });
            },
          ),
          TDBottomTabBarTabConfig(
            tabText: 'decompress',
            onTap: () {
              setState(() {
                uri = "@manage/tasks/decompress";
                _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(getUrlByUri(uri))));
              });
            },
          ),
        ]);
  }
  getUrlByUri(String uri){
    return "$AListAPIBaseUrl/$uri";
  }

  _showAppInfo(){
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return AppInfoPage(key: UniqueKey());
    }));
  }
}
