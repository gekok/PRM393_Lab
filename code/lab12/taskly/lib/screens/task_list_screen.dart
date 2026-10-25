import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

/// Màn chính: hàng nhập liệu ở trên, danh sách task ở dưới.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Controller sống cùng State để giữ chữ đang gõ qua các lần rebuild;
  // giải phóng ở dispose().
  final TextEditingController _titleController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nạp sẵn logo của màn chi tiết vào bộ nhớ đệm ảnh (image cache) ngay khi
    // màn danh sách mở: bấm vào task là logo hiện luôn, không trống một nhịp.
    // Không gọi trong build() vì build chạy lại nhiều lần. Không gọi trong
    // initState() vì precacheImage đọc MediaQuery qua context, mà trong
    // initState() Flutter chưa cho đọc như vậy.
    precacheImage(const AssetImage(TaskDetailScreen.logoPath), context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addTask() {
    // read (không phải watch): trong callback chỉ cần gọi hàm, không cần
    // đăng ký rebuild.
    final added = context.read<TaskProvider>().addTask(_titleController.text);
    // Thêm thành công mới xoá ô nhập; title rỗng thì giữ nguyên ô nhập.
    if (added) _titleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // ĐÃ TỐI ƯU: KHÔNG watch provider ở đầu build. Watch ở đây thì MỖI lần
    // notifyListeners() (thêm, xoá, tick một checkbox) đều build lại cả màn:
    // AppBar, hàng nhập liệu và mọi dòng đang hiển thị, dù chỉ một dòng thay
    // đổi. Chỉ phần danh sách bên dưới nằm trong Selector, nên khi task đổi
    // thì AppBar và hàng nhập liệu không build lại. Các dòng đang hiển thị vẫn
    // build lại, vì ListView.builder gọi lại itemBuilder cho từng dòng.
    return Scaffold(
      appBar: AppBar(title: const Text('Taskly')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Expanded là bắt buộc: Row không giới hạn chiều ngang cho con,
                // mà TextField lại cần một chiều ngang hữu hạn để layout.
                Expanded(
                  child: TextField(
                    key: const Key('taskTextField'),
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'New task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  key: const Key('addTaskButton'),
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            // Khi TaskProvider báo tin, Selector chỉ chạy lại builder nếu
            // `selector` trả về danh sách KHÁC lần trước. Phép so sánh xét
            // từng phần tử theo object, nên provider phải tạo Task mới khi tick
            // hoặc sửa title (xem TaskProvider.toggleTask).
            child: Selector<TaskProvider, List<Task>>(
              selector: (_, provider) => provider.tasks,
              builder: (context, tasks, _) {
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add one!'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    // Mỗi dòng là một widget riêng (TaskTile). ValueKey(task.id)
                    // gắn dòng với đúng task: xoá một task ở giữa làm các dòng
                    // bên dưới dời lên, key ở mỗi vị trí đổi nên Flutter tạo dòng
                    // mới, không đem trạng thái của dòng cũ (vd hiệu ứng
                    // checkbox) sang cho task khác.
                    return TaskTile(key: ValueKey(task.id), task: task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
