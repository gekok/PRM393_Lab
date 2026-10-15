// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  ApiService({http.Client? client}) : _client= client ?? http.Client();

  final http.Client _client;

  Future<List<Post>> fetchPosts() async{
    final uri = Uri.https('jsonplaceholder.typicode.com', '/posts');

    final response= await _client
    .get(uri)
    .timeout(const Duration(seconds: 15));

    if(response.statusCode != 200){
      throw Exception('Máy chủ trả ${response.statusCode}');
    }

    final decoded= jsonDecode(response.body) as List<dynamic>;

    return decoded
        .map((item)=> Post.fromJson(item as Map<String,dynamic>))
        .toList();
  }

  //Phần tùy chọn của đề: gửi bài viết mới
Future<Post> createPost({
  required String title,
  required String body,
}) async {
    final uri= Uri.https('jsonplaceholder.typicode.com','/posts');

    final response= await _client
    .post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'userId':1,
        'title': title,
        'body': body,
      }),
    ).timeout(const Duration(seconds: 15));

    if(response.statusCode !=201){
      throw Exception('Không tạo được bài viết: HTTP ${response.statusCode}');
    }

    return Post.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
}
  void close(){
    _client.close();
  }
}