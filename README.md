# PRM393 - Mobile Development Lab Repository

All PRM393 lab work (Flutter + Dart). Source code and lab evidence are kept in
two separate top-level folders so the repository stays easy to review.

## Repository layout

```text
repo_lab/
|-- code/            Flutter & Dart source code, one folder per lab
|   |-- lab01/
|   |   |-- ex2/     `flutter create <project>` goes here
|   |   |-- ex3/
|   |   |-- ex4/
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
2. Inside a lab, one sub-folder per exercise: `ex1`, `ex2`, ...
3. Create each Flutter project inside its exercise folder:
   `cd code/lab01/ex2` then `flutter create hello_flutter_lab1`.
4. Screenshots are PNG and named after what they prove, e.g.
   `Screenshot_of_flutter_doctor.png`, `Screenshot_of_hot_reload_title.png`.
5. Build output (`build/`, `.dart_tool/`, `.gradle/`, `Pods/`) is never
   committed - see `.gitignore`.
6. Commit per exercise so the history matches lab progress.

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

Known gap: the `emulator` and `system-images` SDK packages are not installed and
no AVD exists yet, so Android runs need
`sdkmanager "emulator" "system-images;android-36;google_apis;x86_64"` followed by
`avdmanager create avd` first. Chrome, Edge and Windows desktop targets already
work.
