import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';

/// Một dòng của danh sách task: checkbox, title và nút xoá. Bấm vào dòng thì
/// mở màn chi tiết.
///
/// Dòng chỉ nhận [task] qua constructor, bản thân nó không lắng nghe provider.
/// Khi danh sách đổi, builder của Selector ở TaskListScreen tạo lại TaskTile
/// cho MỌI dòng đang hiện, kể cả dòng có task không đổi.
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.completed,
        // read (không phải watch): trong callback chỉ cần gọi hàm, không cần
        // đăng ký rebuild.
        onChanged: (_) => context.read<TaskProvider>().toggleTask(task),
      ),
      title: Text(task.title),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete',
        onPressed: () => context.read<TaskProvider>().deleteTask(task.id),
      ),
      onTap: () {
        final route = MaterialPageRoute(
          builder: (_) => TaskDetailScreen(task: task),
        );
        Navigator.of(context).push(route);
      },
    );
  }
}
