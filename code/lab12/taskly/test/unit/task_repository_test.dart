import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';
import 'package:taskly/repositories/task_repository.dart';

// Mỗi test tự tạo kho mới trong bước Arrange để test độc lập, đọc là thấy
// đủ dữ liệu ban đầu. `repository.tasks` là bản chụp (snapshot) nên phần
// Assert luôn đọc lại `tasks` SAU bước Act.
void main() {
  group('TaskRepository', () {
    test('addTask() adds a task with the given title', () {
      // Arrange: kho rỗng.
      final repository = TaskRepository();

      // Act
      repository.addTask('Buy milk');

      // Assert: kho chứa đúng một task, đúng title, chưa hoàn thành.
      expect(repository.tasks, hasLength(1));
      expect(repository.tasks[0].title, 'Buy milk');
      expect(repository.tasks[0].completed, isFalse);
    });

    test('deleteTask() removes only the task with the given id', () {
      // Arrange: ba task.
      final repository = TaskRepository();
      repository.addTask('First');
      repository.addTask('Second');
      repository.addTask('Third');
      final secondId = repository.tasks[1].id;

      // Act: xoá task ở GIỮA, để lỗi "xoá nhầm đầu/cuối" không lọt.
      repository.deleteTask(secondId);

      // Assert: chỉ task giữa mất, hai task còn lại giữ nguyên thứ tự.
      expect(repository.tasks, hasLength(2));
      expect(repository.tasks[0].title, 'First');
      expect(repository.tasks[1].title, 'Third');
    });

    test('updateTask() changes the title and keeps the id', () {
      // Arrange: hai task; task cần sửa nằm ở dòng THỨ HAI để lỗi "luôn ghi
      // vào task đầu" không lọt.
      final repository = TaskRepository();
      repository.addTask('Untouched');
      repository.addTask('Old title');
      final oldTask = repository.tasks[1];

      // Act: lưu một Task mới: cùng id và completed, title mới.
      repository.updateTask(
        Task(id: oldTask.id, title: 'New title', completed: oldTask.completed),
      );

      // Assert: task thứ hai đổi title nhưng giữ id, task đầu không bị đụng.
      expect(repository.tasks, hasLength(2));
      expect(repository.tasks[0].title, 'Untouched');
      expect(repository.tasks[1].id, oldTask.id);
      expect(repository.tasks[1].title, 'New title');
    });
  });
}
