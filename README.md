# PRM393 - Mobile Development Lab Repository

All PRM393 lab work (Flutter + Dart). Source code and lab evidence are kept in
two separate top-level folders so the repository stays easy to review.

## Repository layout

```text
repo_lab/
|-- code/            Flutter & Dart source code, one folder per lab
|   |-- lab01/
|   |   |-- hello_flutter_lab1/  one Flutter project for Lab 1
|   `-- lab02/ ... lab12/
|-- screenshots/     evidence required by each lab, one folder per lab
|   |-- lab01/
|   |   |-- ex1/     flutter doctor + Android Studio plugin screens
|   |   `-- ex2/ ex3/ ex4/
|   `-- lab02/ ... lab12/
|-- README.md
`-- .gitignore
```

## Conventions

1. Folder name = lab number, zero padded: `lab01` ... `lab12`.
2. Each lab uses one Flutter project under its lab folder. Exercises are
   tracked by the project code and the matching folders under `screenshots/`.
3. For Lab 1, run the project from `code/lab01/hello_flutter_lab1`.
4. Screenshots are PNG and named after what they prove, e.g.
   `Screenshot_of_flutter_doctor.png`, `Screenshot_of_hot_reload_title.png`.
5. Build output (`build/`, `.dart_tool/`, `.gradle/`, `Pods/`) is never
   committed - see `.gitignore`.
6. Commit per lab milestone or exercise milestone; do not create a separate
   Flutter project for every exercise unless the lab explicitly requires it.

## Lab index

| Lab | Topic | Code | Screenshots |
|---|---|---|---|
| 1 | Setting up Flutter and running your first app | `code/lab01` | `screenshots/lab01` |
| 2 | Dart essentials practice | `code/lab02` | `screenshots/lab02` |
| 3 | Advanced Dart practice exercises | `code/lab03` | `screenshots/lab03` |
| 4 | Flutter UI fundamentals | `code/lab04` | `screenshots/lab04` |
| 5 | Building a movie detail app with navigation | `code/lab05` | `screenshots/lab05` |
| 6 | Responsive movie genre browsing screen | `code/lab06` | `screenshots/lab06` |
| 7 | Signup form with validation and good UX | `code/lab07` | `screenshots/lab07` |
| 8 | API-powered list screen (+ 8B REST API integration) | `code/lab08` | `screenshots/lab08` |
| 9 | Working with local JSON storage | `code/lab09` | `screenshots/lab09` |
| 10 | Authentication, session management and notifications | `code/lab10` | `screenshots/lab10` |
| 11 | Testing and debugging in Flutter (Taskly app) | `code/lab11` | `screenshots/lab11` |
| 12 | Performance optimization and app deployment | `code/lab12` | `screenshots/lab12` |

## Environment (verified 2026-09-10 with `flutter doctor`)

| Component | Version / path |
|---|---|
| Flutter | 3.47.2 stable - `C:\src\flutter` |
| Dart | 3.13.2 |
| DevTools | 2.60.0 |
| Android SDK | 36.0.0 - `C:\Android\Sdk` (platform android-36) |
| Android Studio | 2026.1.3, Flutter + Dart plugins installed (`screenshots/lab01/ex1`) |
| VS Code | extensions `dart-code.flutter`, `dart-code.dart-code` |

Android emulator is available: AVD `pixel7_api36` targeting Android 36 was
detected on 2026-09-14. Chrome, Edge and Windows desktop targets are also
available.
