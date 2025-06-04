//这个模型是用来局域网或者远程操作casaOS的
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../config/global.dart';
import '../l10n/generated/alistweb_localizations.dart';
import '../utils/toast.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'homePage.dart';

// 登录
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AListWebLocalizations? localizations;
  List<Widget> _list = <Widget>[];

  final TextEditingController _username = TextEditingController(text: "admin");
  final TextEditingController _user_password = TextEditingController(text: "admin");

  @override
  void initState() {
    super.initState();
    _initList();
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (inited) {
        timer.cancel();
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("AListWeb Login"),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: inited?_list:[TDLoading(
                size: TDLoadingSize.small,
                icon: TDLoadingIcon.activity,
              )],
            ),
          ),
        ));
  }

  Future<void> _initList() async {
    setState(() {
      _list = <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20.0), // 设置顶部距离
          child: Image.asset(
            'assets/native/icon/alist.png',
            // package: "openiothub_plugin",
            // 确保路径正确且已在pubspec.yaml中声明
            width: 130,
            height: 130,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0), // 设置顶部距离
          child: TDInput(
            controller: _username,
            backgroundColor: Colors.white,
            leftLabel: "Username",
            // hintText: OpenIoTHubPluginLocalizations.of(context)
            //     .please_input_user_name,
            onChanged: (String v) {},
          ),
        ),
        TDInput(
          controller: _user_password,
          backgroundColor: Colors.white,
          leftLabel: "Password",
          // hintText:
          //     OpenIoTHubPluginLocalizations.of(context).please_input_password,
          obscureText: true,
          onChanged: (String v) {},
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0), // 设置顶部距离
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TDButton(
                  icon: TDIcons.login,
                  text: "Login",
                  size: TDButtonSize.medium,
                  type: TDButtonType.outline,
                  shape: TDButtonShape.rectangle,
                  theme: TDButtonTheme.primary,
                  onTap: () async {
                    if (_username.text.isEmpty || _user_password.text.isEmpty) {
                      show_failed("username_and_password_cant_be_empty", context);
                      return;
                    }
                    // 登录并跳转
                    login_and_goto_dashboard(
                        _username.text, _user_password.text);
                  })
            ],
          ),
        )
      ];
    });
  }

  Future<void> login_and_goto_dashboard(String username, password) async {
    final dio = Dio(BaseOptions(
        baseUrl: AListAPIBaseUrl));
    String reqUri = "/api/auth/login";
    // String reqUri = "/api/auth/login/hash";
    try {
      final response = await dio.postUri(Uri.parse(reqUri),
          data: {'username': username, 'password': password});
      if (response.statusCode == 200 && response.data["code"] == 200) {
        //  登录成功
        Map<String, dynamic> data = response.data;
        print(data["data"]["token"]);
        token = data["data"]["token"];
        // 保存token
        Navigator.of(context).pop();
        // 跳转到主页
        Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          return HomePage();
        }));
        return;
      } else {
        //  登录失败
        show_failed("Login failed", context);
      }
    } catch (e) {
      //  登录失败
      show_failed("Login failed:${e.toString()}", context);
      print(e.toString());
      return;
    }
  }
}
