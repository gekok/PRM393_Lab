import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'repositories/task_repository.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const TasklyApp());
}

/// Gốc của app Taskly.
///
/// Mỗi lần app khởi động tạo một kho rỗng mới (`TaskRepository()`). Test cần
/// kho có sẵn dữ liệu thì tự dựng `ChangeNotifierProvider` với kho đã seed.
class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider đặt TRÊN MaterialApp: mọi route mà Navigator của MaterialApp
    // push (vd TaskDetailScreen) đều nằm dưới Provider nên đọc được
    // TaskProvider. Nếu Provider chỉ bọc `home`, màn được push nằm ngoài
    // Provider và context.read<TaskProvider>() ở đó sẽ ném
    // ProviderNotFoundException.
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(TaskRepository()),
      child: MaterialApp(
        title: 'Taskly',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}
