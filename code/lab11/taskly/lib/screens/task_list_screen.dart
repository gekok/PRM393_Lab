import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
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
    // CỐ Ý CHƯA TỐI ƯU: watch ở đầu build nên MỖI lần notifyListeners()
    // (thêm, xoá, tick một checkbox) đều build lại cả màn: AppBar, hàng nhập
    // liệu và mọi ListTile đang hiển thị, dù chỉ một dòng thay đổi. Giữ dạng
    // này làm mốc (baseline) để đo trước/sau khi tối ưu.
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

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
            child: tasks.isEmpty
                ? const Center(child: Text('No tasks yet. Add one!'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // ListTile viết thẳng trong itemBuilder, chưa tách thành
                      // widget riêng.
                      return ListTile(
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (_) => provider.toggleTask(task),
                        ),
                        title: Text(task.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: () => provider.deleteTask(task.id),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(task: task),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
