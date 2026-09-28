import 'package:flutter/material.dart';

//màn hình 1: hiển thị widget cơ bản
// dùng StatelessWidget vì nội dung tĩnh không đổi theo tương tác
class CoreWidgetsDemo extends StatelessWidget{
  const CoreWidgetsDemo({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      //thanh tiêu đề trên cùng màn hình
      appBar: AppBar(title: const Text('Lab4 - Ex1 Core Widgets')),
      //thân màn hình cuộn tránh tràn trên máy nhỏ
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //tiêu đề lớn đầu trang
            const Text(
              'Movie Highlights',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            //1 dòng ngang: icon + chữ mô tả
            const Row(
              children: [
                Icon(Icons.movie, size: 32, color: Colors.deepPurple),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Danh sách phim nổi bật trong tuần')
                ),
              ],
            ),
            const SizedBox(height: 12),

            //Ảnh mạng, bo góc
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/600/300',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            //thẻ card chứa 1 dòng ListTile hoàn chỉnh
            const Card(
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text('Dune: Part Two'),
                subtitle: Text('Sci-Fi - 166 phút - 8.5/10'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
