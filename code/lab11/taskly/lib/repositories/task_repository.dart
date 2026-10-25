import '../models/task.dart';

/// Kho task lưu trong bộ nhớ (in-memory): tắt app là mất dữ liệu.
///
/// Đây là nơi duy nhất giữ danh sách task và cấp id. Thêm, xoá và thay task
/// đều đi qua các hàm bên dưới; list trả ra qua [tasks] không thêm/xoá được.
class TaskRepository {
  final List<Task> _tasks = [];

  // Bộ đếm id riêng, KHÔNG suy ra từ `_tasks.length`: xoá một task không nằm
  // cuối danh sách rồi thêm mới thì `length + 1` trùng id của task còn lại.
  int _nextId = 1;

  /// Bản chụp (snapshot) không sửa được của danh sách hiện tại.
  ///
  /// `List.unmodifiable` tạo list MỚI mỗi lần gọi:
  /// - gọi `add`/`remove` trên nó sẽ ném `UnsupportedError`;
  /// - nó không tự cập nhật khi kho thay đổi, muốn thấy dữ liệu mới thì đọc
  ///   lại [tasks].
  ///
  /// Phần tử bên trong là chính các object [Task] của kho, KHÔNG phải bản sao.
  /// Code so sánh theo object (vd `Selector` của provider) dựa vào đó để biết
  /// danh sách có task nào vừa đổi không. Vì vậy mọi thay đổi phải tạo object
  /// mới rồi lưu qua [updateTask]; gọi `toggle()` thẳng trên phần tử thì dữ
  /// liệu đổi mà phép so sánh không thấy gì.
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Thêm task mới, id tăng dần từ 1.
  ///
  /// Title rỗng hoặc chỉ có khoảng trắng → trả `false` và không thêm gì.
  /// Thêm được → trả `true`.
  bool addTask(String title) {
    if (title.trim().isEmpty) return false;

    _tasks.add(Task(id: _nextId, title: title));
    _nextId++;
    return true;
  }

  /// Xoá task mang [id]. Không có task nào mang id đó thì không làm gì.
  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
  }

  /// Thay task cùng `id` bằng [task].
  ///
  /// Trả `false` và giữ nguyên dữ liệu khi:
  /// 1. không có task nào mang `task.id`;
  /// 2. title mới rỗng hoặc chỉ có khoảng trắng (cùng luật với [addTask]).
  bool updateTask(Task task) {
    if (task.title.trim().isEmpty) return false;

    final index = _tasks.indexWhere((stored) => stored.id == task.id);
    if (index == -1) return false;

    _tasks[index] = task;
    return true;
  }
}
