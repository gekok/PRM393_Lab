/// Một công việc trong Taskly.
///
/// `id` và `title` là final; `completed` đổi được tại chỗ qua [toggle].
/// Muốn đổi một task đang nằm trong kho thì làm trên bản sao (một `Task` mới
/// cùng `id`, chép lại mọi field không đổi như `completed`) rồi đưa bản sao cho
/// `TaskRepository.updateTask`, đừng sửa object trong kho.
///
/// Hai chỗ đang tạo bản sao: `TaskProvider.toggleTask` và
/// `TaskProvider.updateTaskTitle`. Thêm field mới cho Task thì sửa cả hai chỗ;
/// quên một chỗ thì field đó âm thầm về giá trị mặc định mà không có lỗi nào.
class Task {
  Task({required this.id, required this.title, this.completed = false});

  final int id;
  final String title;
  bool completed;

  /// Đảo trạng thái hoàn thành: false → true, true → false.
  void toggle() {
    completed = !completed;
  }
}
