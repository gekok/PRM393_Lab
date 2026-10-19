# Đề ôn Dart 60 phút — bám 5 lab

Bao phủ: lab2, lab3, lab1.1, lab1.2, lab1.6.
Cách dùng: đọc đề → tự làm `practice_todo.dart` → so với `practice_solution.dart`.

Chạy đáp án:

```
dart run code/practice/practice_solution.dart
```

Chạy khung tự làm (ban đầu sẽ thiếu, điền dần):

```
dart run code/practice/practice_todo.dart
```

---

## Bài 1 — Lab 2: cú pháp lõi (10 phút)

File gốc:

```
code/lab02/dart_essentials/lib/dart_essentials.dart:23-55
```

Yêu cầu:

1. Viết `basicSyntaxSummary()` trả về đúng chuỗi:
   `age=20, gpa=3.75, campus=FPT HCM, passed=true`.
2. Viết `collectionsSummary()`:
   - Từ `[1, 2, 3]` → `add(4)` → `remove(1)` → còn `[2, 3, 4]`.
   - Từ `[1, 2, 2, 3]` → `toSet()` → `{1, 2, 3}`.
   - Đọc `user['name']` ra `Nam`, `reduce` cộng dồn ra `9`.
3. Viết `controlFlowSummary(80)`:
   - `score >= 50 ? 'Pass' : 'Fail'`.
   - `switch` dạng biểu thức: chẵn → `Even score`, lẻ → `Odd score`.
   - Kết quả `80` phải ra `Pass - Even score`.

Tự hỏi: `Set` loại trùng lúc nào? `reduce` chạy ra sao?

## Bài 2 — Lab 1.1: kế thừa Vehicle (10 phút)

File gốc: `code/lab1.1/lab1_1.dart:1-38`.

Yêu cầu:

1. `Vehicle` giữ `brand`, `year`, hàm `startEngine()`.
2. `Car extends Vehicle` thêm `isElectric`.
3. Named constructor `Car.tesla(int year)` gửi `super('Tesla', year)`.
4. `@override startEngine()`:
   - Điện → `Tesla Khởi động bằng động cơ điện`.
   - Xăng → `Toyota khởi động bằng động cơ xăng`.

Tự hỏi: `super` gửi gì lên cha? `@override` đổi hành vi nào?

## Bài 3 — Lab 1.2 + Lab 2 OOP: mixin và spread (10 phút)

File gốc:

```
code/lab1.2/lab1_2.dart:1-33
code/lab02/dart_essentials/lib/dart_essentials.dart:2-20
```

Yêu cầu:

1. `abstract class Employee` có `name` và `work()`.
2. `mixin CheckInAbility on Employee` in `$name đã điểm danh`.
3. `Developer extends Employee with CheckInAbility`, `work()` in đang viết code.
4. Gộp `[...teamA, ...teamB]` rồi `for` gọi `checkIn()` từng người.
5. Thêm `ElectricCar extends Car`, `start()` trả `started silently`.

Tự hỏi: `extends` khác `with` chỗ nào? `on Employee` chặn gì?

## Bài 4 — Lab 1.6 + Lab 3 Ex2: JSON thiếu field (10 phút)

File gốc:

```
code/lab1.6/lab1_6.dart:6-25
code/lab03/advanced_dart/lib/advanced_dart.dart:54-70
```

Yêu cầu:

1. `String? email` cho phép null.
2. `factory User.fromJson` dùng `as String? ?? "Khách"`.
3. `showProfile()` dùng `email ?? "Chưa cập nhật"`.
4. Test 2 map:
   - Đủ field → `ID: 1 | Tên: Nam | Email: nam@fpt.edu.vn`.
   - Null hết → `ID: 2 | Tên: Khách | Email: Chưa cập nhật`.
5. So sánh với bản lab3 dùng `as String` — hỏi khi nào crash?

Bẫy: `??` chỉ bắt `null`, không bắt chuỗi rỗng.

## Bài 5 — Lab 2 Ex5 + Lab 3 Ex4: Future và Stream (10 phút)

File gốc:

```
code/lab02/dart_essentials/lib/dart_essentials.dart:58-69
code/lab03/advanced_dart/lib/advanced_dart.dart:87-89
```

Yêu cầu:

1. `loadStudents()` dùng `Future.delayed` trả `['An', 'Binh']`.
2. `numberStream() async*` dùng `yield` phát `1, 2, 3`.
3. `evenSquares()` dùng `map` bình phương rồi `where` giữ chẵn → `[4, 16]`.
4. `main()` phải `await` cả hai rồi mới in.

Tự hỏi: `Future` trả mấy giá trị? `Stream` trả mấy giá trị?

## Bài 6 — Lab 3 Ex1 + Ex3 + Ex5: repo, event, singleton (10 phút)

File gốc: `code/lab03/advanced_dart/lib/advanced_dart.dart:19-44,73-101`.

Yêu cầu:

1. `ProductRepository` giữ list `Keyboard`, `Mouse`, `add(Monitor)`.
2. `liveAdded()` là broadcast stream, `add()` vừa lưu vừa phát event.
3. `dispose()` đóng `StreamController`.
4. `microtaskOrder()` trả `['A', 'B', 'microtask', 'event']`.
5. `Settings()` factory luôn trả cùng instance, `identical` ra `true`.

Thứ tự event nhớ thế này:

```
code đồng bộ
↓
microtask
↓
event queue
```

---

## Checklist chốt 5 phút cuối

- [ ] Viết lại `fromJson` có `??` không nhìn mẫu.
- [ ] Viết lại `mixin ... on ... with` không nhìn mẫu.
- [ ] Viết lại `async*` có `yield` không nhìn mẫu.
- [ ] Đoán đúng `[A, B, microtask, event]` và `[4, 16]`.
- [ ] Giải thích được vì sao phải `dispose()`.
