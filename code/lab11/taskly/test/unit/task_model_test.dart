import 'package:flutter_test/flutter_test.dart';
import 'package:taskly/models/task.dart';

void main() {
  group('Task model', () {
    test('completed defaults to false', () {
      // Arrange + Act: tạo task mà không truyền `completed`.
      final task = Task(id: 1, title: 'Write unit tests');

      // Assert: giá trị mặc định phải là chưa hoàn thành.
      expect(task.completed, isFalse);
    });

    test('toggle() switches completed true ↔ false', () {
      // Arrange: task mới, đang ở trạng thái mặc định false.
      final task = Task(id: 1, title: 'Write unit tests');

      // Act: đảo trạng thái một lần.
      task.toggle();

      // Assert: false → true.
      expect(task.completed, isTrue);

      // Act: đảo thêm một lần nữa.
      task.toggle();

      // Assert: true → false.
      expect(task.completed, isFalse);
    });
  });
}
