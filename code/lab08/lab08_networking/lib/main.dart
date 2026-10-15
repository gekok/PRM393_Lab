// lib/main.dart

import 'package:flutter/material.dart';
import 'models/post.dart';
import 'services/api_service.dart';

void main(){
  runApp(const Lab8App());
}

class Lab8App extends StatelessWidget{
  const Lab8App({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab08- api Posts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PostsScreen(),
    );
  }
}

class PostsScreen extends StatefulWidget{
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>{
  final ApiService _apiService= ApiService();
  late Future<List<Post>> _postsFuture;

  String _searchQuery='';

  @override
  void initState(){
    super.initState();
    _postsFuture= _apiService.fetchPosts();
  }

  void _retry(){
    setState(() {
      _postsFuture= _apiService.fetchPosts();
    });
  }

  @override
  void dispose() {
    _apiService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Explorer'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Padding(
                padding: const EdgeInsets.fromLTRB( 16, 0, 16, 12),
              child: TextField(
                onChanged: (value){
                  setState(() {
                    _searchQuery= value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tiêu đề hoặc nội dung',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
        )
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context,snapshot){
          if(snapshot.connectionState== ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError){
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48,),
                    const SizedBox(height: 12,),
                    const Text(
                      'Không tải được bài viết. '
                          'Hãy kiểm tra lại kết nối.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12,),
                    ElevatedButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts= snapshot.data ?? const <Post>[];

          if(posts.isEmpty){
            return const Center(
              child: Text('chưa có bài viết'),
            );
          }

          final query = _searchQuery.trim().toLowerCase();

          final filteredPosts= query.isEmpty
              ? posts
              : posts.where((post){
                  final title = post.title.toLowerCase();
                  final body= post.body.toLowerCase();
                  return title.contains(query)|| body.contains(query);
          }).toList();

          if (filteredPosts.isEmpty){
            return const Center(
              child: Text('Không tìm thấy bài biết phù hợp'),
            );
          }

          return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredPosts.length,
            itemBuilder: (context, index){
                final post= filteredPosts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${post.id}'),
                    ),
                    title: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        post.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
            },
          );
        },
      ),
    );
  }
}