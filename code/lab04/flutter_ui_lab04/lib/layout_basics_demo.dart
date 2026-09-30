import 'package:flutter/material.dart';

//màn hình 3: bố cục nhiều section như home thực tế
// dùng StatelessWidget vì danh sách mẫu cố định
class LayoutBasicsDemo extends StatelessWidget {
  const LayoutBasicsDemo({super.key});

  //danh sách phim mẫu
  static const movies= [
    'Dune: Part two',
    'Oppenheimer',
    'Spider-Man: No Way Home',
    'The Batman',
    'Avatar: The Way of Water',
    'John Wick 4',
    'Guardians of the Galaxy 3',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab04- ex3 layout basics'),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //section1K banner chào, lề đều 16
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'chào buổi tối, mời chọn phim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ),
          
          //section 2: 2 thẻ thống kê nằm ngang
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Đã xem\n12 phim'),
                      ),
                    ),
                ),
                SizedBox(width: 12,),
                Expanded(
                    child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Yêu thích\n5 phim'),
                      ),
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16,),

          //section 3: tiêu đề danh sách
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Phim đề xuất',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8,),

          //section 4 danh sách chiếm hết chỗ còn lại
          //Expaned bắt buộc vì ListView cần chiều cao giới hạn
          Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context,index){
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}'),),
                      title: Text(movies[index]),
                      trailing: const Icon(Icons.favorite_border),
                    ),
                  );
                }
              )
          )
        ],
      ),
    );
  }
}