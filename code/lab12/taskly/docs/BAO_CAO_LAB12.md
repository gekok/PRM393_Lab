# Báo cáo Lab 12 — Tối ưu hiệu năng và phát hành Taskly

Môn PRM393 · Lab 12 (Performance Optimization & Deployment) · Dự án `code/lab12/taskly`

Môi trường đo:

```
Flutter 3.47.7 (stable) · Dart 3.13.5 · DevTools 2.60.0 · provider 6.1.5+1
Android SDK 36 · build-tools 36.0.0 · Gradle 9.3.1 · Windows 11
Ngày đo: 26/10/2026
```

Mọi con số dưới đây lấy từ lệnh chạy thật. Số nào là phép tính hoặc ước tính thì có ghi rõ.

## Tóm tắt

| Bài | Kết quả chính |
|---|---|
| 12.1 | Tick 1 task: 342 → 252 lần build |
| 12.2 | Logo 512×512 → 128×128, 10 136 → 4 812 byte |
| 12.3 | APK arm64: 16 752 717 byte |
| 12.4 | Bỏ `cupertino_icons`; APK release: 48 268 655 byte |

Kiểm chứng lần cuối, chạy sau khi bỏ `cupertino_icons`, theo đúng thứ tự dưới đây:

```
flutter pub get                                    → Changed 1 dependency!
flutter analyze                                    → No issues found!
flutter test --reporter expanded                   → +10: All tests passed!
flutter build apk --release                        → ✓ Built app-release.apk (46.0MB)
flutter build apk --analyze-size                   → bị từ chối: phải chọn một ABI (mục 12.3)
flutter build apk --analyze-size
    --target-platform android-arm64                → ✓ Built app-release.apk (16.0MB)
flutter build apk --debug                          → ✓ Built app-debug.apk
flutter build apk --release                        → ✓ Built app-release.apk (46.0MB)
```

`--release` chạy hai lần. Lý do: `--analyze-size` ghi APK chỉ có arm64 vào đúng tên `app-release.apk`. Lần chạy cuối trả lại APK đủ 3 ABI để nộp. Hai lần cho cùng một cỡ: 48 268 655 byte.

Lượt này không chạy `flutter clean`. `flutter clean` đã chạy ở lượt build trước, lúc còn `cupertino_icons` (mục 12.4).

Chưa làm: `flutter run --profile` trên máy, cài APK release lên máy, mọi ảnh chụp màn hình. Chi tiết ở mục cuối.

## 12.1 — Giảm số lần build của danh sách

### Code đã đổi những gì?

1. Mỗi dòng tách thành widget `TaskTile` (`lib/widgets/task_tile.dart`).
2. Bỏ `context.watch<TaskProvider>()` ở đầu `TaskListScreen.build`. Chỉ phần danh sách nằm trong `Selector<TaskProvider, List<Task>>`.
3. Mỗi dòng có key: `TaskTile(key: ValueKey(task.id), task: task)`.
4. `const`: quét bằng lint (mục 12.4), không còn chỗ nào thiếu. Code từ Lab 11 đã đủ `const`.

Code chính trong `lib/screens/task_list_screen.dart`:

```dart
Expanded(
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
          return TaskTile(key: ValueKey(task.id), task: task);
        },
      );
    },
  ),
),
```

File nộp: `lib/screens/task_list_screen.dart` và `lib/widgets/task_tile.dart`.

### Đo bằng cách nào?

Dùng một test tạm với hook `debugOnRebuildDirtyWidget` của Flutter. DevTools cũng đếm rebuild qua hook này.

```
kho có sẵn 3 task → pump TaskListScreen
↓
ghi lại các widget đang có → bật đếm
↓
làm 1 thao tác (tick / xoá / thêm) → pump 1 frame
↓
tắt đếm, in số lần build theo loại widget
```

- **Build lại:** widget đã có từ trước, nay build lại.
- **Tạo mới:** widget mới sinh ra trong frame đó.

Cùng một test chạy trên code Lab 11 (trước) và code Lab 12 (sau). Đo xong, test đã bị xoá khỏi dự án. Code lõi ở Phụ lục A.

### Kết quả trước và sau

Tick checkbox của Task 1 (kho 3 task):

| Widget | Trước | Sau |
|---|---|---|
| TaskListScreen | 1 | 0 |
| AppBar | 1 | 0 |
| TextField | 1 | 0 |
| ElevatedButton (Add) | 1 | 0 |
| Selector | — | 1 |
| TaskTile | — | 3 |
| ListTile | 3 | 3 |
| Checkbox | 3 | 3 |
| **Tổng mọi widget** | **342** | **252** |

Xoá Task 2, task ở giữa (3 → 2 task):

| Widget | Trước | Sau |
|---|---|---|
| TaskListScreen | 1 | 0 |
| AppBar | 1 | 0 |
| TextField | 1 | 0 |
| ElevatedButton (Add) | 1 | 0 |
| Selector | — | 1 |
| TaskTile | — | 1 + 1 mới |
| ListTile | 2 | 1 + 1 mới |
| Checkbox | 2 | 1 + 1 mới |
| **Tổng mọi widget** | **272** | **182** (110 + 72 mới) |

Thêm Task 4 (3 → 4 task):

| Widget | Trước | Sau |
|---|---|---|
| TaskListScreen | 1 | 0 |
| AppBar | 1 | 0 |
| TextField | 1 | 0 |
| ElevatedButton (Add) | 1 | 1 |
| Selector | — | 1 |
| TaskTile | — | 3 + 1 mới |
| ListTile | 3 + 1 mới | 3 + 1 mới |
| Checkbox | 3 + 1 mới | 3 + 1 mới |
| **Tổng mọi widget** | **410** (339 + 71 mới) | **367** (295 + 72 mới) |

Gộp lại:

```
Tick : 342 → 252   (−90, −26.3%)
Xoá  : 272 → 182   (−90, −33.1%)
Thêm : 410 → 367   (−43, −10.5%)
```

### Đọc kết quả thế nào?

**Phần tĩnh của màn không còn build lại.** TaskListScreen, AppBar, ô nhập: từ `1` về `0` ở cả ba thao tác. Đây là phần `Selector` cắt bớt.

**Các dòng đang hiện vẫn build lại hết.** Tick 1 dòng thì cả 3 `TaskTile` vẫn build. Slide 15 ghi "Only the affected TaskTile rebuilds" (chỉ TaskTile bị ảnh hưởng mới build lại). Số đo cho thấy điều đó chưa đạt với cấu trúc đề yêu cầu: một `Selector` bọc cả danh sách.

Lý do, đọc trong Flutter SDK (`widgets/scroll_delegate.dart`):

```
Selector build lại → tạo ListView.builder mới
↓
SliverChildBuilderDelegate.shouldRebuild luôn trả true (dòng 579)
↓
Flutter gọi lại itemBuilder cho mọi dòng đang hiện
↓
mỗi dòng nhận một TaskTile mới → build lại
```

Muốn chỉ dòng bị đổi build lại thì phải đổi cấu trúc: `Selector` ngoài chỉ chọn thứ ít đổi (ví dụ danh sách id), còn mỗi dòng tự lắng nghe task của nó. Chỉ thêm `Selector` cho từng dòng là chưa đủ, vì `Selector` ngoài vẫn tạo lại mọi dòng. Cách này ngoài phạm vi đề và chưa thử.

**Nút Add vẫn build 1 lần khi thêm task, nhưng không phải do provider.** Đối chứng: bấm Add khi ô nhập rỗng, provider từ chối và không gọi `notifyListeners()`. Kết quả: `ElevatedButton` vẫn build 1 lần, `Selector` là 0, cả frame có 55 lần build. Nhiều khả năng nút tự build lại khi đổi trạng thái "đang bấm" (suy luận, chưa soi từng widget).

**ValueKey làm đúng dòng, không làm ít build hơn.** Khi xoá Task 2, Task 3 dời lên vị trí số 2:

```
Trước (không key): vị trí 2 dùng lại dòng cũ của Task 2 → ListTile: build lại 2, tạo mới 0
Sau (có key):      key 3 ≠ key 2 → tạo dòng mới cho Task 3 → TaskTile: build lại 1, tạo mới 1
```

Dòng tạo mới không mang theo trạng thái cũ của Task 2, ví dụ hiệu ứng checkbox đang chạy dở. `ListView.builder` chỉ "dời" được dòng cũ sang chỗ mới khi có thêm `findChildIndexCallback` (`scroll_delegate.dart`, dòng 530–533). Phần đó ngoài phạm vi đề.

**Giới hạn của phép đo.** Đây là số lần build trong `flutter_test`, không phải thời gian. Chưa đo FPS hay thời gian vẽ một frame trên máy thật (cần `flutter run --profile`).

## 12.2 — Tối ưu ảnh và asset

### Đã làm gì?

Lab 11 chưa có asset nào. Lab 12 thêm một logo cho màn chi tiết, làm theo hai bước:

```
TRƯỚC  vẽ logo gốc 512×512 bằng PowerShell System.Drawing
       khai báo assets/images/taskly_logo_512.png trong pubspec.yaml
       màn chi tiết hiện ảnh này ở ô 64×64
↓
SAU    thu nhỏ còn 128×128 (nội suy HighQualityBicubic) → assets/images/taskly_logo.png
       màn chi tiết dùng ảnh 128; màn danh sách gọi precacheImage
       bỏ ảnh 512 khỏi pubspec.yaml; file 512 chuyển sang docs/images/ chỉ để so sánh
```

<p><img src="images/taskly_logo_512.png" width="96" alt="Logo gốc 512×512"> &nbsp; <img src="../assets/images/taskly_logo.png" width="96" alt="Logo 128×128"></p>

Hai ảnh trên hiện cùng cỡ 96 px. Bên trái là bản 512, bên phải là bản 128. Ở cỡ hiển thị nhỏ, mắt không phân biệt được.

### Trước và sau khác nhau bao nhiêu?

| | Trước | Sau |
|---|---|---|
| File | `taskly_logo_512.png` | `taskly_logo.png` |
| Kích thước | 512×512 px | 128×128 px |
| Dung lượng file | 10 136 byte | 4 812 byte |
| Bộ nhớ khi giải mã (số tính) | 1 048 576 byte | 65 536 byte |

```
dung lượng file:     −5 324 byte (−52.5%)
bộ nhớ khi giải mã:  ít hơn 16 lần
```

Kích thước và dung lượng file đo bằng System.Drawing và `ls -l`. Dòng bộ nhớ là **số tính**: rộng × cao × 4 byte (mỗi pixel 4 byte RGBA). Chưa đo trên máy.

Dung lượng file chỉ giảm 52.5%, vì logo là hình phẳng và PNG vốn nén tốt. Cái lợi lớn nằm ở bộ nhớ. `width: 64, height: 64` chỉ đổi kích thước hiển thị. Khi không đặt `cacheWidth`/`cacheHeight` (như code này), Flutter vẫn giải mã đúng số pixel của file.

Vì sao chọn 128? Logo hiện ở ô 64×64. Màn mật độ 2x cần 64 × 2 = 128 pixel.

### precacheImage gọi ở đâu?

Trong `lib/screens/task_list_screen.dart`:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(const AssetImage(TaskDetailScreen.logoPath), context);
}
```

- **Không đặt trong `build()`**, vì build chạy lại nhiều lần.
- **Không đặt trong `initState()`**, vì `precacheImage` đọc `MediaQuery` qua `context`. Flutter không cho `initState()` đọc như vậy; bản debug ném lỗi ngay (`framework.dart`, dòng 6066–6069, nằm trong `assert`).
- **Nạp ở màn danh sách, dùng ở màn chi tiết.** Logo chỉ hiện ở màn chi tiết. Khi người dùng bấm vào task, ảnh đã nằm sẵn trong bộ nhớ đệm ảnh (image cache).
- **Dùng chung một đường dẫn.** `precacheImage` và `Image.asset` cùng dùng hằng `TaskDetailScreen.logoPath`. Lệch đường dẫn thì ảnh nạp sẵn không được dùng, mà không có lỗi nào báo.

Lợi ích thực tế nhỏ, vì logo chỉ 4 812 byte. Chưa đo trên máy.

### Asset nào đã bị bỏ?

```
assets/images/taskly_logo_512.png    khai báo ở bước "trước", bỏ ở bước "sau"
```

Đây là asset duy nhất bị bỏ khỏi `pubspec.yaml`. Lab 11 không có asset nào để bỏ.

Font `CupertinoIcons.ttf` cũng không còn trong APK. Nhưng đó là do bỏ dependency `cupertino_icons` (mục 12.3, tối ưu số 1), không phải asset khai báo trong `pubspec.yaml`.

Bằng chứng:

- **Bước trước** (quan sát lúc đó; thư mục `build/` sau này đã bị `flutter clean` xoá): bundle asset của `flutter test` ở `build/unit_test_assets/assets/images/` có `taskly_logo_512.png` (10 136 byte). Asset đã khai báo thì bị đóng gói.
- **Bước sau:** trong APK release, thư mục ảnh `assets/flutter_assets/assets/images/` chỉ có `taskly_logo.png` (4 812 byte). Không còn file 512.

`pubspec.yaml` khai báo từng file, không khai báo cả thư mục. Khai báo `- assets/images/` thì mọi file trong thư mục đều bị đóng gói, kể cả file không dùng.

## 12.3 — Phân tích dung lượng app

### Đã chạy lệnh gì?

```
flutter build apk --analyze-size
```

Flutter từ chối:

```
Cannot perform code size analysis when building for multiple ABIs. Specify one of
android-arm, android-arm64, or android-x64 in the --target-platform flag.
```

Chạy lại với một ABI (kiến trúc CPU) là arm64:

```
flutter build apk --analyze-size --target-platform android-arm64
→ ✓ Built build\app\outputs\flutter-apk\app-release.apk (16.0MB)
```

Mọi số của APK arm64 ở mục 12.3 là của lần chạy này, sau khi bỏ `cupertino_icons`. Số nào đo trước khi bỏ thì có ghi rõ.

### APK nặng tổng cộng bao nhiêu?

```
app-release.apk (chỉ arm64): 16 752 717 byte (~16.0 MiB)
Flutter in "16.0MB"; bảng tóm tắt ghi "16 MB"
trước khi bỏ cupertino_icons: 16 869 175 byte (~16.1 MiB)
```

Trên Windows, Flutter tính 1 MB = 1 048 576 byte, tức MiB (`flutter_tools/lib/src/base/utils.dart`, dòng 109; trên macOS/Linux là 1 000 000 byte). Vì vậy 16 752 717 byte hiện thành "16.0MB". Báo cáo này ghi số byte, kèm số MiB để khớp với cách Flutter in.

Số này **chỉ cho arm64**. APK release thường (mục 12.4) chứa 3 ABI nên nặng hơn nhiều.

### 3 thành phần lớn nhất là gì?

Bảng tóm tắt Flutter in ra (giữ nguyên, bỏ bớt dòng nhỏ):

```
app-release.apk (total compressed)                16 MB
  assets/
    flutter_assets                               108 KB
  classes.dex                                    232 KB
  lib/
    arm64-v8a                                     16 MB
    Dart AOT symbols accounted decompressed size   4 MB
      package:flutter                              2 MB
      dart:mixin_deduplication                   260 KB
      dart:core                                  247 KB
      dart:ui                                    224 KB
      ...
      package:provider                            14 KB
      package:taskly                              11 KB
```

Xếp hạng:

| # | Thành phần | Dung lượng | Là gì |
|---|---|---|---|
| 1 | `lib/arm64-v8a` | 16 MB | Thư viện native |
| 2 | `classes.dex` | 232 KB | Code Android (Java/Kotlin) |
| 3 | `assets/flutter_assets` | 108 KB | Font, ảnh, shader, giấy phép |

`flutter_assets` trước khi bỏ `cupertino_icons` là 222 KB. Phần chênh lệch gần như toàn bộ là font Cupertino.

Đọc từng file trong APK (APK là file zip, liệt kê bằng `zipfile` của Python):

```
lib/arm64-v8a/libflutter.so   11 747 864 byte   engine Flutter
lib/arm64-v8a/libapp.so        4 588 424 byte   code Dart đã biên dịch AOT
classes.dex                      238 047 byte   (đã nén; gốc 520 160)
NOTICES.Z                         96 351 byte   (đã nén; gốc 98 210) giấy phép các thư viện
taskly_logo.png                    4 812 byte
MaterialIcons-Regular.otf            896 byte   (đã nén; tree-shake từ 1 645 184)
```

Nhận xét:

- Code của chính Taskly (`package:taskly`) chỉ 11 KB. Gần như toàn bộ dung lượng là phần Flutter mang theo.
- Thư viện native chiếm 97.5% APK arm64 (16 336 288 / 16 752 717 byte).

### Cái gì tối ưu được?

**1. Bỏ dependency `cupertino_icons`: đã làm, mỗi APK release nhẹ đi 116 458 byte.**

- Lý do bỏ: app không dùng nó, và đề 12.4 yêu cầu bỏ dependency không dùng. Grep `lib/` và `test/` ra 0 chỗ dùng icon Cupertino.
- Trước khi bỏ, font vẫn bị đóng gói **nguyên vẹn**. `CupertinoIcons.ttf` trong APK là 257 628 byte, bằng đúng file gốc trong pub cache. Đã nén thì còn 115 944 byte.
- Log build chỉ báo tree-shake MaterialIcons (`1645184 → 1512 bytes`). Font Cupertino không được cắt.
- Cách bỏ: xoá dòng `cupertino_icons: ^1.0.8` và 2 dòng comment đi kèm trong `pubspec.yaml`, rồi chạy `flutter pub get`.

Đo thật, trước và sau khi bỏ:

```
APK arm64 (mục 12.3):     16 869 175 → 16 752 717 byte   (−116 458)
APK release (mục 12.4):   48 385 113 → 48 268 655 byte   (−116 458)
flutter_assets:               222 KB → 108 KB
file tên Cupertino trong APK release sau khi bỏ: 0
```

- Mức giảm lớn hơn font đã nén (115 944 byte) đúng 514 byte. So hai file JSON của `--analyze-size`, ba file nhỏ cũng nhỏ đi: `NOTICES.Z` 216 byte, `FontManifest.json` 42 byte, `AssetManifest.bin` 40 byte.
- 216 byte còn lại nằm ngoài dữ liệu các file, tức thuộc cấu trúc zip. Header và dòng mục lục zip của font cộng lại là (30 + 72) + (46 + 72) = 220 byte. Ở đây 72 là số ký tự đường dẫn của font trong APK. Chênh 4 byte nhiều khả năng do phần đệm căn lề (suy luận).
- APK debug gần như không đổi. Lý do ở mục 12.4.

**2. Phát hành bằng AAB, hoặc tách APK theo ABI.** Máy arm64 chỉ cần khoảng 16.0 MiB, thay vì cả APK 48 268 655 byte (~46.0 MiB).

- APK release thường chứa 3 ABI: 48 268 655 byte (mục 12.4).
- Phần arm64 trong APK đó là 16 336 288 byte (`libflutter.so` + `libapp.so`), giống hệt APK arm64 ở trên.
- Lệnh: `flutter build appbundle --release` (Google Play tự tách theo máy), hoặc `flutter build apk --split-per-abi`.
- Chưa chạy hai lệnh này. Con số ~16.0 MiB là **ước tính** từ APK arm64 đã đo.

**3. Build với `--obfuscate --split-debug-info=<thư mục>`.** Thông tin debug của code Dart được tách ra khỏi `libapp.so`. Chưa đo, nên chưa biết giảm bao nhiêu.

**4. Giữ icon tree-shaking (mặc định đang bật).** MaterialIcons giảm từ 1 645 184 xuống 1 512 byte (−99.9%). Đừng build với `--no-tree-shake-icons`.

Không nên bỏ:

- `libflutter.so` — engine, app Flutter nào cũng phải có.
- `NOTICES.Z` — giấy phép các thư viện, Flutter tự sinh.
- `provider` — đang dùng, chỉ 14 KB.
- Logo — 4 812 byte, đã nhỏ.

### File báo cáo dung lượng ở đâu?

Lệnh in bảng tóm tắt ra terminal, rồi chỉ báo đường dẫn **một file JSON**. Output không nhắc tới file HTML nào, khác với slide 17.

Lần chạy sau khi bỏ `cupertino_icons` tạo một file mới, không ghi đè file cũ:

```
lần chạy cuối:
<thư mục người dùng>\.flutter-devtools\apk-code-size-analysis_02.json   (5 587 663 byte)

lần chạy trước, lúc còn cupertino_icons (cùng thư mục):
apk-code-size-analysis_01.json   (5 587 846 byte)
```

Xem dạng cây (treemap) của lần chạy cuối trong DevTools:

```
dart devtools --appSizeBase="<thư mục người dùng>\.flutter-devtools\apk-code-size-analysis_02.json"
```

Trên máy khác, file nằm ở `%USERPROFILE%\.flutter-devtools\`, và đường dẫn chính xác được in ở cuối lệnh `--analyze-size`.

Ảnh chụp cây dung lượng: **chưa có**, vì chưa mở DevTools.

## 12.4 — Hoàn thiện và build bản release

### Đã dọn code những gì?

| Việc | Kết quả | Bằng chứng |
|---|---|---|
| Bỏ `print()`, log debug | Không có chỗ nào | grep `lib/`: 0 kết quả |
| Thêm `const` | Không thiếu chỗ nào | lint quét: 0 vấn đề |
| Bỏ asset thừa | Đã bỏ ảnh 512 | mục 12.2 |
| Bỏ dependency thừa | Đã bỏ `cupertino_icons` | mục 12.3, tối ưu số 1 |

Cách quét `const`:

```
flutter_lints 6.0.0 không bật prefer_const_constructors (lint nhắc thêm const khi tạo widget)
↓
bật tạm prefer_const_constructors, prefer_const_declarations,
prefer_const_literals_to_create_immutables trong analysis_options.yaml
↓
flutter analyze → No issues found!
↓
thử một file mẫu cố ý thiếu const → lint báo prefer_const_constructors → lint chạy thật
↓
xoá file mẫu, trả analysis_options.yaml về như cũ (so từng byte với Lab 11: giống hệt)
```

### Build ra sao?

Lượt build đầu, lúc còn `cupertino_icons`: dọn sạch rồi build release và debug.

```
flutter clean
→ Deleting build...        356ms
→ Deleting .dart_tool...    11ms

flutter build apk --release
→ ✓ Built build\app\outputs\flutter-apk\app-release.apk (46.1MB)

flutter build apk --debug
→ ✓ Built build\app\outputs\flutter-apk\app-debug.apk
```

Lượt build cuối, sau khi bỏ `cupertino_icons`. Lượt này không chạy `flutter clean` lại. Thứ tự đầy đủ các lệnh ở phần Tóm tắt.

```
flutter build apk --release
→ Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 1512 bytes (99.9% reduction).
→ ✓ Built build\app\outputs\flutter-apk\app-release.apk (46.0MB)

flutter build apk --debug
→ ✓ Built build\app\outputs\flutter-apk\app-debug.apk
```

Dung lượng đo bằng `ls -l`:

| Bản build | Trước khi bỏ `cupertino_icons` | Sau khi bỏ |
|---|---|---|
| `app-release.apk` (3 ABI) | 48 385 113 byte | 48 268 655 byte (~46.0 MiB) |
| `app-release.apk` chỉ arm64 (mục 12.3) | 16 869 175 byte | 16 752 717 byte (~16.0 MiB) |
| `app-debug.apk` | 150 595 403 byte | 150 595 285 byte (~143.6 MiB) |

Bản release nhẹ hơn bản debug khoảng 3.1 lần.

**Vì sao APK debug chỉ nhỏ đi 118 byte?**

Đo được trên APK debug:

- Liệt kê bằng `zipfile`: 0 file tên Cupertino. Font không còn trong mục lục của file zip (central directory).
- 118 byte khớp đúng cỡ một dòng mục lục của font. Đó là 46 byte phần cố định, cộng 72 ký tự tên file `assets/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf`.
- Ngoài khối chữ ký APK (APK Signing Block, 4 096 byte), có hai vùng không thuộc file nào: 127 114 byte và 311 byte. Mỗi vùng đứng ngay trước một asset.
- Mỗi vùng mở đầu bằng header zip không có tên file (`name_len = 0`), chỉ dùng để lấp chỗ.

APK release không có vùng lấp chỗ nào. Vùng duy nhất không thuộc file nào là khối chữ ký APK (8 192 byte), nằm ngay trước mục lục.

Suy luận từ cấu trúc file, chưa đọc code của Gradle:

```
Gradle sửa APK debug cũ tại chỗ, không ghi lại từ đầu
↓
gỡ dòng của font khỏi mục lục → file nhỏ đi đúng 118 byte
↓
chỗ dữ liệu cũ của font được lấp bằng vùng không tên, các file khác không bị dồn lại
```

Muốn đo mức giảm thật của bản debug thì phải `flutter clean` rồi build lại. Lượt này chưa làm.

Thông tin APK release, đọc bằng `aapt dump badging` và `apksigner verify --print-certs`:

```
package       com.example.taskly   (applicationId giữ nguyên)
version       versionCode 1 · versionName 1.0.0   (từ version: 1.0.0+1 trong pubspec.yaml)
SDK           minSdk 24 · targetSdk 36
ABI           arm64-v8a, armeabi-v7a, x86_64
chữ ký        CN=Android Debug
```

**Bản release được ký bằng khoá debug.** `android/app/build.gradle.kts` của template Flutter ghi `signingConfig = signingConfigs.getByName("debug")`. `apksigner` xác nhận chứng chỉ là `CN=Android Debug`.

- Loại chữ ký này đủ để cài thử.
- Không dùng được để đưa lên Google Play.
- Chưa tạo keystore riêng trong bài này.
- Máy đã cài một bản `com.example.taskly` ký bằng khoá khác (ví dụ bản tự build trên máy khác) sẽ không cài đè được bản này, vì Android chỉ cho cập nhật app khi chữ ký trùng nhau. Phải gỡ bản cũ trước. App không lưu dữ liệu nên gỡ không mất gì. Điểm này chưa thử trên máy.

APK release nằm trong `build/`. Thư mục này bị `.gitignore` bỏ qua và bị `flutter clean` xoá. Cần chép `app-release.apk` ra chỗ khác trước khi nén file nộp.

### Checklist hiệu năng

| Mục | Trạng thái |
|---|---|
| Tách TaskTile thành widget riêng | Đã làm |
| Selector thay watch ở đầu màn | Đã làm |
| ValueKey(task.id) cho từng dòng | Đã làm |
| const ở mọi chỗ hợp lệ | Đã đủ (lint: 0) |
| Không làm việc nặng trong build() | Đạt |
| Danh sách dùng ListView.builder | Đạt |
| Ảnh đúng kích thước cần dùng | Đã làm |
| precacheImage ngoài build() | Đã làm |
| Không asset thừa trong APK | Đạt |
| Không print() / log debug | Đạt |
| Icon tree-shaking | Đang bật (−99.9%) |
| Bỏ dependency không dùng | Đã làm (cupertino_icons) |
| flutter clean + build release | Đã làm; lượt cuối build không clean |
| flutter analyze | Sạch |
| 10 test hồi quy | Xanh |
| Profile mode: FPS, jank | Chưa làm |
| Cài release lên máy, thử tay | Chưa làm |
| Ký bằng keystore riêng | Chưa làm |
| AAB / tách APK theo ABI | Chưa làm |

Về mục "Không làm việc nặng trong build()": các hàm `build()` chỉ dựng widget. Phần tỉ lệ với số task nằm ở mỗi lần provider báo tin. Lúc đó `selector` tạo một bản copy danh sách (`List.unmodifiable`), rồi `Selector` so danh sách mới với cũ từng phần tử. Cả hai việc đều lặp qua toàn bộ danh sách. Chưa đo với danh sách lớn.

### Vì sao app sẵn sàng phát hành?

App **sẵn sàng để cài thử và nộp lab**, vì năm lý do:

1. Màn danh sách không còn build lại phần tĩnh. Tick 1 task: 342 → 252 lần build.
2. Ảnh đúng kích thước dùng. APK không còn asset thừa, cũng không còn dependency thừa (đã bỏ `cupertino_icons`).
3. Không còn log debug. `flutter analyze` sạch, 10 test hồi quy vẫn xanh sau khi tối ưu.
4. `flutter clean` rồi build release thành công. Sau khi bỏ `cupertino_icons`, build lại vẫn thành công. APK đã ký bằng khoá debug, loại chữ ký đủ để cài thử.
5. Đã biết dung lượng nằm ở đâu và cách giảm tiếp (mục 12.3).

App **chưa sẵn sàng để đưa lên Google Play**, còn ba việc:

1. Ký bằng keystore riêng, thay cho khoá debug.
2. Build AAB: `flutter build appbundle --release`.
3. Chạy bản profile và cài bản release trên máy thật, để kiểm FPS, jank và hành vi thực tế.

## Còn gì chưa làm, chưa kiểm được?

- **`flutter run --profile`:** chưa chạy trên máy hay emulator, nên chưa có số FPS, jank.
- **Cài APK release lên máy và thử tay:** chưa làm.
- **Ảnh chụp:** chưa có ảnh nào. Còn thiếu: đếm rebuild trước/sau trong DevTools, cây App Size, app chạy bản release. Bằng chứng của 12.1 hiện là output của test tạm (Phụ lục A).
- **Lợi ích của precacheImage:** chưa đo trên máy.
- **AAB, `--split-per-abi`, `--obfuscate`:** chưa build. Các con số liên quan ở mục 12.3 là ước tính.
- **Keystore riêng:** chưa tạo.
- **Build lại từ đầu sau khi bỏ `cupertino_icons`:** lượt build cuối không chạy `flutter clean`. APK release đã kiểm: không còn file Cupertino, không có vùng lấp chỗ. APK debug còn hai vùng lấp chỗ, 127 114 và 311 byte (mục 12.4).

## Phụ lục A — Test tạm đếm số lần build (đã xoá khỏi dự án)

Code lõi:

```dart
final rebuilt = <String, int>{};
final firstBuilt = <String, int>{};

void startCounting(WidgetTester tester) {
  rebuilt.clear();
  firstBuilt.clear();
  final aliveBefore = tester.allElements.toSet();
  debugOnRebuildDirtyWidget = (element, _) {
    final name = element.widget.runtimeType.toString();
    final counts = aliveBefore.contains(element) ? rebuilt : firstBuilt;
    counts[name] = (counts[name] ?? 0) + 1;
  };
}

testWidgets('tick Task 1', (tester) async {
  await pumpWithThreeTasks(tester); // kho 3 task + MaterialApp(home: TaskListScreen())
  startCounting(tester);
  await tester.tap(find.byType(Checkbox).first);
  await tester.pump();
  stopCounting('Tick checkbox của Task 1 (3 task)'); // gỡ hook, in số đếm
});
```

Không dùng tham số `builtOnce` của hook. Flutter chỉ cập nhật cờ đó khi bật `debugPrintRebuildDirtyWidgets` (`framework.dart`, dòng 5522–5526). Ở chế độ thường cờ luôn là `false`. Lần chạy đầu dính đúng bẫy này: mọi lần build đều bị tính là "tạo mới".

## Phụ lục B — Thu nhỏ ảnh bằng PowerShell System.Drawing

Bản rút gọn. Script thật đặt thêm ba thiết lập chất lượng: `PixelOffsetMode`, `SmoothingMode` và `CompositingQuality` đều là `HighQuality`.

```powershell
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Image]::FromFile($InPath)    # ảnh gốc 512×512
$dst = New-Object System.Drawing.Bitmap(128, 128,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($dst)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.Clear([System.Drawing.Color]::Transparent)
$g.DrawImage($src, 0, 0, 128, 128)
$g.Dispose(); $src.Dispose()
$dst.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)   # ảnh 128×128
$dst.Dispose()
```
