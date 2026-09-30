import 'package:flutter/material.dart';
import 'movie.dart';

//màn hình detail film
//dùng StatefullWidget vì nút favorite đỏi
class MovieDetailScreen extends StatefulWidget{
  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  //film được chọn truyền samg
  final Movie movie;

  @override
  State<MovieDetailScreen> createState()=> _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>{
  //trạng thái yêu thích, false là chưa thích
  bool _isFavorite=false;

  @override
  Widget build(BuildContext context) {
    //lấy film ra biến ngắn để code dưới gọn
    final movie= widget.movie;
    return Scaffold(
      //thanh tiêu đề hiện tên film
      appBar: AppBar(
        title: Text(movie.title),
      ),
      //toàn trang cuộn được để tránh tràn máy nhỏ
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Banner hero gồm ảnh, gradient, tên film
            Stack(
              children: [
                Hero(
                    tag: 'poster-${movie.id}',
                    child: Image.network(
                      movie.posterUrl,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                ),
                //lớp gradient phủ từ trong suốt tới đen
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                //tên film và điểm nằm dưới cùng banner
                Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                        const SizedBox(height: 4,),
                        Text(
                          'Điểm: ${movie.rating}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                ),
              ],
            ),
            const SizedBox(height: 2,),

            //thể loại dạng chip tự xuống dòng
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: movie.genres.map((genre){
                    return Chip(
                      avatar: const Icon(Icons.local_movies,size: 16,),
                      label: Text(genre),
                    );
                  }).toList(),
                ),
            ),
            const SizedBox(height: 12,),

            //Doạn tóm tắt nội dung film
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //nút Favorited đổi màu và icon theo state
                  IconButton(
                      tooltip: 'Yêu thích',
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _isFavorite? Colors.red:null,
                    ),
                    onPressed: (){
                        setState(() {
                          _isFavorite=!_isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                  _isFavorite
                                  ? 'Đã thêm vào yêu thích'
                                  : 'Đã bỏ khỏ yêu thích',
                                ),
                            ),
                        );
                    },
                  ),
                  //nút rate hiển điểm film
                  IconButton(
                    tooltip: 'Chấm điểm',
                    icon: const Icon(Icons.star_border),
                    onPressed: (){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                'Phim này ${movie.rating} điểm',
                              ),
                          ),
                      );
                    },
                  ),
                  //Nút Share hiện thông báo mẫu
                  IconButton(
                      tooltip: 'Chia sẻ',
                    icon: const Icon(Icons.share),
                    onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Đã sao chép link film'),
                            ),
                        );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 12,),

            //tiêu đề danh sách trailer
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Trailer',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8,),

            //từng trailer là 1 dòng có icon play
            ...movie.trailers.map((trailer){
              return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.play_circle_fill),
                      title: Text(trailer.title),
                      subtitle: Text(trailer.duration),
                    ),
                  ),
              );
            }),
            const SizedBox(height: 16,),
          ],
        ),
      ),
    );
  }
}