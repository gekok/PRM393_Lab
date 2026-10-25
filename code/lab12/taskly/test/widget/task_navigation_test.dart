import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskly/providers/task_provider.dart';
import 'package:taskly/repositories/task_repository.dart';
import 'package:taskly/screens/task_list_screen.dart';

void main() {
  testWidgets('tapping a task opens TaskDetailScreen', (tester) async {
    // Arrange: seed kho với một task, rồi pump TaskListScreen. Provider đặt
    // TRÊN MaterialApp giống TasklyApp, nên màn được push cũng đọc được
    // TaskProvider. Không pump TasklyApp vì nó luôn tạo kho rỗng, mà test này
    // cần kho có sẵn task.
    final repository = TaskRepository();
    repository.addTask('Demo task');
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(repository),
        child: const MaterialApp(home: TaskListScreen()),
      ),
    );

    // Act: bấm vào 'Demo task', chờ animation chuyển màn chạy xong.
    await tester.tap(find.text('Demo task'));
    await tester.pumpAndSettle();

    // Assert: đã sang màn chi tiết, title nằm trên AppBar (không chỉ là một
    // chữ bất kỳ trên màn hình).
    expect(find.widgetWithText(AppBar, 'Task Detail'), findsOneWidget);

    // Assert: ô sửa title (Key 'detailTitleField') tồn tại.
    expect(find.byKey(const Key('detailTitleField')), findsOneWidget);
  });
}
