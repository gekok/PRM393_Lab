import 'package:flutter/material.dart';

//home lab 6, toàn bộ demo trong file
void main(){
  runApp(const ResponsiveMovieApp());
}

//model 1 phim cho lab 6
//giữ 5 trường: tên, năm, thể loại, ảnh, điểm
class Movie{
  const Movie({
    required this.title,
    required this.year,
    required this.genres,
    required this.posterUrl,
    required this.rating,
  });

  // Tên phim, dùng để tìm kiếm và sắp xếp A-Z.
  final String title;
  // Năm phát hành, dùng để sắp xếp Year.
  final int year;
  // Danh sách thể loại, mỗi thể loại một chip.
  final List<String> genres;
  // Link ảnh poster tải từ mạng.
  final String posterUrl;
  // Điểm đánh giá, dùng để sắp xếp Rating.
  final double rating;
}

// Danh sách 6 phim mẫu tĩnh, không gọi API.
// Seed khác nhau cho ảnh khác nhau.
const allMovies = [
  Movie(
    title: 'Dune: Part Two',
    year: 2024,
    genres: ['Sci-Fi', 'Phiêu lưu'],
    posterUrl: 'https://picsum.photos/seed/dune6/200/300',
    rating: 8.5,
  ),
  Movie(
    title: 'Oppenheimer',
    year: 2023,
    genres: ['Tiểu sử', 'Chính kịch'],
    posterUrl: 'https://picsum.photos/seed/oppen6/200/300',
    rating: 8.3,
  ),
  Movie(
    title: 'The Batman',
    year: 2022,
    genres: ['Hành động', 'Tội phạm'],
    posterUrl: 'https://picsum.photos/seed/batman6/200/300',
    rating: 7.8,
  ),
  Movie(
    title: 'Spider-Man: No Way Home',
    year: 2021,
    genres: ['Hành động', 'Phiêu lưu'],
    posterUrl: 'https://picsum.photos/seed/spider6/200/300',
    rating: 8.0,
  ),
  Movie(
    title: 'Inside Out 2',
    year: 2024,
    genres: ['Hài', 'Hoạt hình'],
    posterUrl: 'https://picsum.photos/seed/inside6/200/300',
    rating: 7.6,
  ),
  Movie(
    title: 'John Wick 4',
    year: 2023,
    genres: ['Hành động', 'Chính kịch'],
    posterUrl: 'https://picsum.photos/seed/wick6/200/300',
    rating: 7.9,
  ),
];

// mọi thể loại
const allGenres= [
  'Hành động',
  'Phiêu lưu',
  'Sci-Fi',
  'Chính kịch',
  'Tiểu sử',
  'Tội phạm',
  'Hài',
  'Hoạt hình',
];

//4 kiểu sắp xếp
const sortOptions= ['A-Z', 'Z-A', 'Year', 'Rating'];

//widget gốc giữ theme chung
// dùng StatelessWidget vì không cần nhớ thêm
class ResponsiveMovieApp extends StatelessWidget{
  const ResponsiveMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PRM393 lab6',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GenresScreen(),
    );
  }
}

//màn hình duyệt film theo thể loại
//dùng StatefullWidget vì phải nhớ: chữ tìm, chip chọn, kiểu sort
class GenresScreen extends StatefulWidget{
  const GenresScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen>{
  // chữ trong ô tìm kiếm, rỗng là chưa lọc
  String _query='';
  //tập thể loại đã chọn, rỗng là hiện tất cả
  final Set<String> _selectedGenres={};
  //kểu sắp xếp hiện tại, mặc định A-Z
  String _sort= 'A-Z';

  //danh sách sau lọc và sắp xếp, tính lại mỗi lượt build
  List<Movie> get _visibleMovies {
    //Bước Lọc 1: giữ phim có tên chứa từ khóa
    final keyword= _query.trim().toLowerCase();
    final filtered= allMovies.where((movie){
      final matchSearch= keyword.isEmpty
      || movie.title.toLowerCase().contains(keyword);
      //Bước Lọc 2: giữ film có ít nhất 1 thể loại đã chọn
      final matchGenre= _selectedGenres.isEmpty
      || movie.genres.any(_selectedGenres.contains);
      return matchSearch && matchGenre;
    }).toList();

    //copy ra list mới để sort không đụng bản gốc
    final sorted= List<Movie>.from(filtered);
    if(_sort == 'A-Z'){
      sorted.sort((a,b)=>a.title.compareTo(b.title));
    }else if(_sort == 'Z-A'){
      sorted.sort((a,b)=>b.title.compareTo(a.title));
    }else if(_sort == 'Year'){
      sorted.sort((a,b)=> b.year.compareTo(a.year));
    }else{
      sorted.sort((a,b)=>b.rating.compareTo(a.rating));
    }
    return sorted;
  }

  // đảo trạng thái 1 chíp thể loại
  void _toggleGenre(String genre){
    setState(() {
      if(_selectedGenres.contains(genre)){
        _selectedGenres.remove(genre);
      }else{
        _selectedGenres.add(genre);
      }
    });
  }
  
  //xóa toàn bộ lọc trả về ban đầu
  void _clearFilters(){
    setState(() {
      _query='';
      _selectedGenres.clear();
      _sort='A-Z';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // đọc rộng mành hình thiết bị để hiện vùng hero
    final screenWidth= MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('lab 6 - find a movie'),
      ),
      //tránh tai thỏ và camera đục lỗ
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //vùng hero 6.1: tiêu đề rộng hiện tại
                Text(
                  'Find a Movie',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4,),
                Text(
                  'Rộng màn hình: ${screenWidth.toStringAsFixed(0)} px',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12,),
                
                //Ô tìm kiếm 6.2, bo tròn cho giống thanh search
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'TÌm phim theo tên',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                  ),
                  onChanged: (value){
                    setState(() {
                      _query=value;
                    });
                  },
                ),
                const SizedBox(height: 12,),
                
                //hàng tiêu đề chip kèm huy hiệu điểm và nút xóa
                Row(
                  children: [
                    const Text(
                      'Thể loại',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8,),
                    //huy hiệu đếm số chip đã chọn
                    CircleAvatar(
                      radius: 12,
                      child: Text('${_selectedGenres.length}'),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: _clearFilters, 
                        child: const Text('Xóa Lọc'),
                    ),
                  ],
                ),
                //chíp tự rớt dòng nhờ Wrap
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allGenres.map((genre){
                    return FilterChip(
                        label: Text(genre), 
                        selected: _selectedGenres.contains(genre),
                        onSelected: (_)=>_toggleGenre(genre),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12,),
                
                //thanh sắp xếp 6.2: nhãn và dropdown
                Row(
                  children: [
                    const Text(
                      'Sắp xếp',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12,),
                    DropdownButton<String>(
                      value: _sort,
                      items: sortOptions.map((option){
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                    }).toList(),
                      onChanged: (value){
                        if(value == null)return;
                        setState(() {
                          _sort= value;
                        });
                      },
                    ),
                    const Spacer(),
                    //đếm số phim đang hiện
                    Text('${_visibleMovies.length} phim'),
                  ],
                ),
                const SizedBox(height: 8,),
                
                //vùng danh sách 6.3 chiếm hết chỗ còn lại
                //Expand bắt buộc vì ListVIew cần chiều cao giới hạn
                Expanded(
                  child: LayoutBuilder(
                      builder: (context, constraints){
                        //điểm ngắt để cho: rộng từ 800px là tablet
                        final isWide= constraints.maxWidth>=800;
                        if(isWide){
                          return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _visibleMovies.length,
                              itemBuilder: (context,index){
                                return _movieCard(_visibleMovies[index]);
                              },
                          );
                        }
                        return ListView.builder(
                          itemCount: _visibleMovies.length,
                          itemBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _movieCard(_visibleMovies[index]),
                            );
                          },
                        );
                      },
                  ),
                )
              ],
            ),
          ),
      ),
    );
  }

  //1 thẻ film dùng chung cho cả List và Grid
  // dùng LayoutBuilder trong thẻ để đổi cỡ poster
  Widget _movieCard(Movie movie){
    return LayoutBuilder(
        builder: (context, constraints){
          //thẻ rộng thì poster lớn, thẻ hẹp thì poster nhỏ
          final posterWidth= constraints.maxWidth>400?96.0:64.0;
          final posterHeight= constraints.maxWidth>400?128.0:96.0;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie.posterUrl,
                      width: posterWidth,
                      height: posterHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12,),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4,),
                        Text('Năm: ${movie.year} - Điểm: ${movie.rating}'),
                        const SizedBox(height: 4,),
                        Text(movie.genres.join(' - ')),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
    );
  }
}