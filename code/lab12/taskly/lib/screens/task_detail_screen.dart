import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

/// Màn sửa title của một task, mở khi bấm vào một dòng ở TaskListScreen.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  /// Đường dẫn logo hiện ở đầu màn này. TaskListScreen dùng chung hằng này để
  /// nạp sẵn ảnh (precacheImage): hai nơi phải cùng một đường dẫn thì ảnh nạp
  /// sẵn mới được dùng lại.
  static const logoPath = 'assets/images/taskly_logo.png';

  final Task task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Điền sẵn title hiện tại của task ở initState(); giải phóng ở dispose().
  // Không điền ngay ở dòng khai báo được, vì lúc đó chưa đọc được `widget`.
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    // Title rỗng/chỉ có khoảng trắng thì repository từ chối nên title cũ giữ
    // nguyên; màn vẫn quay về danh sách như khi lưu thành công.
    context.read<TaskProvider>().updateTaskTitle(
      widget.task,
      _titleController.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo hiện ở ô 64×64. File ảnh 128×128 px là vừa đủ cho màn mật
            // độ 2x (64 × 2 = 128). width/height chỉ quyết định kích thước
            // hiển thị; ảnh vẫn được giải mã theo số pixel của file, nên cách
            // đơn giản nhất để tốn ít bộ nhớ là dùng file nhỏ.
            Center(
              child: Image.asset(
                TaskDetailScreen.logoPath,
                width: 64,
                height: 64,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('detailTitleField'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('detailSaveButton'),
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
