import 'package:flutter/material.dart';
import 'movie.dart';
import 'sample_data.dart';
import 'movie_detail_screen.dart';

//Màn home: list film+ thanh search
//dùng StatefullWidget vì khóa lọc đổi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  //Từ khóa người dùng gõ vào ô tìm kiếm
  String _query='';

  //list sau khi lọc
List<Movie> get _filtered{
  //từ khóa trống trả full
  if(_query.trim().isEmpty) return sampleMovie;
  //so sánh không phân biệt hoa thường
  final keyword= _query.toLowerCase();
  return sampleMovie.where((movie){
    return movie.title.toLowerCase().contains(keyword);
  }).toList();
}

// mở màn hình detail film
void _openDetail(Movie movie){
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MovieDetailScreen(movie:movie),
      ),
  );
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      //Thanh tiêu đềcủa home
      appBar: AppBar(
        title: const Text('Lab5- Movie App'),
      ),
      //cột gồm ô tìm kiếm và list film
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'tìm phim',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value){
                setState(() {
                  _query=value;
                });
              },
            ),
          ),
          //danh sách chiếmheetst chỗ còn lại
          Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtered.length,
                itemBuilder: (context,index){
                  final movie= _filtered[index];
                  return Card(
                    child: ListTile(
                      // ảnh nhỏ có hero để bay sang detail
                      leading: Hero(
                          tag: 'poster-${movie.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              movie.posterUrl,
                              width: 48,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ),
                      title: Text(movie.title),
                      subtitle: Text('Điểm: ${movie.rating}'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: ()=>_openDetail(movie),
                    ),
                  );
                },
              ))
        ],
      ),
    );
  }
}