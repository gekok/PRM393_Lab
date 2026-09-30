import 'package:flutter/material.dart';

//màn hình 4: Scaffold hoàn chỉnh + Dark mode
// nhận công tắc từ main.dart qua  tham số, không giữ riêng
class AppStructureDemo extends StatelessWidget{
   const AppStructureDemo({
     super.key,
     required this.isDark,
     required this.onThemeChanged,
   });

   //giá trị theme hiện tại do main.dart đưa xuống
    final bool isDark;
    //hàm gạt công tắc gọi về main.dart
    final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Phòng 1: thanh tiêu đề trên cùng
      appBar: AppBar(
        title: const Text('Lab 4 Ex4 Scaffold & Theme'),
      ),
      //phòng 2 thân màn hình viết ở bước 4
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Icon đổi theo theme: tối là trăng, sáng là mặt trời
            Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 64,
            ),
            const SizedBox(height: 12,),
            //chữ báo ở chế độ nào
            Text(
              isDark ? 'Dark mode' : 'Light mode',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12,),
            //công tắc đổi theme cả app khi gạt
            Switch(
                value: isDark,
                onChanged: onThemeChanged,
            ),
          ],
        ),
      ),
      // phòng 3: nút tròn nổi góc dưới viết ở bước 5
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vừa bấm nút +')),
            );
          },
          child: Icon(Icons.add),
      ),
    );
  }
}