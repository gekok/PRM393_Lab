import 'dart:async';

abstract class Entity {
  final String id;
  Entity(this.id);
}

class Message extends Entity {
  final String content;
  Message(String id, this.content) : super(id);

  @override
  String toString() => "Msg[$id]:$content";
}

// Lớp cơ sở cho mọi Repository
abstract class BaseRepository {}

// TODO 1: Khai báo mixin SyncLogger giới hạn (on) cho BaseRepository.
// Viết hàm void logSync(String msg).
mixin SyncLogger on BaseRepository{
  void logSync(String msg){
    print('[LOG] $msg');
  }
}

// TODO 2: Khai báo MessageRepository kế thừa BaseRepository và tích hợp (with) SyncLogger.
class MessageRepository extends BaseRepository with SyncLogger {

  // TODO 3: Viết hàm Stream<Message> syncMessages() async*
  // - Lặp 3 lần.
  // - Mỗi lần chờ 300ms.
  // - Gọi logSync("Đang đồng bộ tin nhắn $i").
  // - Dùng yield để trả về Message(i.toString(), "Nội dung $i").
  Stream<Message> syncMessages() async*{
    for(int i=1;i<=3;i++){
      await Future.delayed(const Duration(milliseconds: 300));
      logSync('Đang đồng bộ tin nhắn $i');
      yield Message(i.toString(), 'Nội dung $i');
    }
  }
}

void main() {
  var repo = MessageRepository();
  print("Bắt đầu đồng bộ...");

  var stream = repo.syncMessages().asBroadcastStream();

  // BẪY LOGIC: 2 UI cùng lắng nghe một stream
  stream.listen((msg) => print("UI 1 hiển thị: $msg"));
  stream.listen((msg) => print("UI 2 hiển thị: $msg"));


  // TODO 4: Bỏ comment dòng dưới đây, chương trình sẽ báo lỗi.
  // Hãy tìm hiểu nguyên nhân và sửa lại biến `stream` ở trên để code không bị crash.
  // stream.listen((msg) => print("UI 2 hiển thị: $msg"));
}
