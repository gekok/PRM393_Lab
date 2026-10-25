import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

/// State dùng chung cho UI: bọc [TaskRepository] và báo UI vẽ lại.
///
/// Luồng dữ liệu: UI → TaskProvider → TaskRepository. Thêm, tick và sửa title
/// chỉ gọi `notifyListeners()` khi repository chấp nhận thao tác. Thao tác bị
/// từ chối (title rỗng, id không tồn tại) vì thế không làm UI rebuild. Xoá thì
/// luôn gọi `notifyListeners()`.
class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repository);

  final TaskRepository _repository;

  List<Task> get tasks => _repository.tasks;

  /// Trả `true` nếu đã thêm, `false` nếu title rỗng/chỉ có khoảng trắng.
  bool addTask(String title) {
    final added = _repository.addTask(title);
    if (added) notifyListeners();
    return added;
  }

  /// Luôn gọi `notifyListeners()`: `TaskRepository.deleteTask` trả `void` nên
  /// provider không biết đã xoá được hay chưa.
  void deleteTask(int id) {
    _repository.deleteTask(id);
    notifyListeners();
  }

  /// Nhận cả [task] (không chỉ id) vì cần title và completed hiện tại của nó
  /// để tạo bản sao.
  void toggleTask(Task task) {
    // toggle() trên BẢN SAO, không trên object đang nằm trong kho: kho nhận
    // object mới, nên code so sánh từng phần tử theo object (vd `Selector`)
    // thấy danh sách đã khác và build lại. Sửa tại chỗ thì list cũ và mới
    // chứa cùng object, Selector coi như không có gì đổi và checkbox đứng yên.
    //
    // Bản sao = một `Task` mới có cùng id, title, completed với task cũ.
    final newTask = Task(
      id: task.id,
      title: task.title,
      completed: task.completed,
    );
    newTask.toggle();
    if (_repository.updateTask(newTask)) notifyListeners();
  }

  /// Đổi title của [task]. Title rỗng/chỉ có khoảng trắng thì repository
  /// từ chối: title cũ giữ nguyên và không notify.
  ///
  /// id và completed được chép từ chính [task] truyền vào, không đọc lại kho.
  void updateTaskTitle(Task task, String title) {
    // Tạo `Task` mới: giữ id và completed của task cũ, chỉ thay title. Kho
    // nhận object mới nên code so sánh từng phần tử theo object (vd `Selector`)
    // thấy danh sách đã khác và build lại.
    final newTask = Task(id: task.id, title: title, completed: task.completed);
    if (_repository.updateTask(newTask)) notifyListeners();
  }
}
