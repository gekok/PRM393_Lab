import 'movie.dart';

//data mẫu do không gọi api
//danh sách 3 phim mẫu
const sampleMovie=[
  Movie(
      id: 1,
      title: 'Dune: Part Two',
      posterUrl: 'https://picsum.photos/seed/dune/600/900',
      overview: 'Paul Atreides hợp nhất với người Fremen. Anh bước vào cuộc chiến giành Arrakis.',
      genres: ['Sci-Fi', 'Phiêu lưu', 'Chính kịch'],
      rating: 8.5,
      trailers: [
        Trailer(
            title: 'Trailer chính thức',
            duration: '2:31'
        ),
        Trailer(title: 'Nhạc phim IMAX', duration: '1:12')
      ]),
  Movie(
    id: 2,
    title: 'Oppenheimer',
    posterUrl: 'https://picsum.photos/seed/oppenheimer/600/900',
    overview: 'Câu chuyện về cha đẻ bom nguyên tử. Ông giằng xé giữa vinh quang và tội lỗi.',
    genres: ['Tiểu sử', 'Chính kịch', 'Lịch sử'],
    rating: 8.3,
    trailers: [
      Trailer(title: 'Trailer chính thức', duration: '2:05'),
      Trailer(title: 'Hậu trường', duration: '3:40'),
    ],
  ),
  Movie(
    id: 3,
    title: 'The Batman',
    posterUrl: 'https://picsum.photos/seed/batman/600/900',
    overview: 'Batman lần theo dấu Riddler trong lòng Gotham. Mọi manh mối đều dẫn về gia đình anh.',
    genres: ['Hành động', 'Tội phạm', 'Bí ẩn'],
    rating: 7.8,
    trailers: [
      Trailer(title: 'Trailer chính thức', duration: '2:57'),
    ],
  ),
];