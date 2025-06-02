import 'package:alist_web/config/config.dart';
import 'package:alist_web/pages/web/web.dart';
import 'package:flutter/cupertino.dart';

class StoragesPage extends StatefulWidget {
  const StoragesPage({super.key});

  @override
  State<StoragesPage> createState() => _StoragesPageState();
}

class _StoragesPageState extends State<StoragesPage> {
  @override
  Widget build(BuildContext context) {
    return WebScreen(startUrl: "$AListAPIBaseUrl/@manage/storages");
  }
}
