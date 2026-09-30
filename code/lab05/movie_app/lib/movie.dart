//model data cho lab0
//file không có widget, chỉ có khung data

//1 trailer gồm tên và thời lượng
class Trailer{
  const Trailer({
    required this.title,
    required this.duration,
  });

  //tên trailer
  final String title;
  // thời lượng dạng chữ
  final String duration;
}

// 1 phim có 7 field
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
  });
  //id dùng làm hero tag và key
  final int id;
  //tên phim trên thẻ và banner
  final String title;
  // Link ảnh poster tải từ mạng.
  final String posterUrl;
  // Đoạn tóm tắt nội dung phim.
  final String overview;
  // Danh sách thể loại, mỗi thể loại một Chip.
  final List<String> genres;
  // Điểm đánh giá dạng số thập phân.
  final double rating;
  // Danh sách trailer của phim này.
  final List<Trailer> trailers;

}
