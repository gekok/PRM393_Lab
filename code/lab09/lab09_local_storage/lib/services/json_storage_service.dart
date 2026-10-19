import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../models/task_item.dart';

class JsonStorageService {
  static const String _assetPath= 'assets/data/seed_items.json';
  static const String _fileName= 'tasks.json';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<TaskItem>> loadItems() async {
    final file = await _getLocalFile();

    if(await file.exists()){
      final contents= await file.readAsString();

      if(contents.trim().isNotEmpty){
        return _decodeItems(contents);
      }
    }

    //chưa có file cục bộ: đọc data ẫu trong assets
    final assetContents= await rootBundle.loadString(_assetPath);
    final seedItems= _decodeItems(assetContents);

    //tạo bản data đầu cho bộ nhớ của app
    await saveItems(seedItems);
    return seedItems;
  }

  List<TaskItem> _decodeItems( String source){
    final decoded= jsonDecode(source) as List<dynamic>;

    return decoded
        .map((item)=> TaskItem.fromJson(item as Map<String, dynamic>),
    ).toList();
  }

  Future<void> saveItems(List<TaskItem> items) async {
    final file = await _getLocalFile();

    final jsonText = jsonEncode(
      items.map((item)=> item.toJson()).toList(),
    );

    await file.writeAsString(jsonText);
  }
}