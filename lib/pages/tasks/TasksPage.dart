import 'package:flutter/cupertino.dart';

import '../../config/config.dart';
import '../web/web.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    return WebScreen(startUrl: "$AListAPIBaseUrl/@manage/tasks/offline_download");
  }
}
