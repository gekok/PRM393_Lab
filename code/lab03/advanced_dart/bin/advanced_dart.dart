import 'package:advanced_dart/advanced_dart.dart';

// main điều phối năm exercise Lab 3 và in kết quả từng phần.
Future<void> main() async {
  final repository = ProductRepository();
  final added = repository.liveAdded().first;
  repository.add(Product(id: 3, name: 'Monitor', price: 180.0));
  print('Exercise 1 - Products: ${await repository.getAll()}');
  print('Exercise 1 - Live added: ${await added}');
  await repository.dispose();

  print('Exercise 2 - Users from JSON: ${await fetchUsersFromJson()}');
  print('Exercise 3 - Event order: ${await microtaskOrder()}');
  print('Exercise 4 - Even squares: ${await evenSquares().toList()}');
  print('Exercise 5 - Singleton: ${identical(Settings(), Settings())}');
}
