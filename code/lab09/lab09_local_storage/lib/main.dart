import 'package:flutter/material.dart';

import 'models/task_item.dart';
import 'services/json_storage_service.dart';

void main(){
  runApp(const Lab9App());
}

class Lab9App extends StatelessWidget{
  const Lab9App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab9- Local JSON',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TasksPage(),
    );
  }
}

class TasksPage extends StatefulWidget{
  const TasksPage({
    super.key,
  });
  
  @override
  State<TasksPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TasksPage>{
  final JsonStorageService _storage= JsonStorageService();

  List<TaskItem> _items= [];
  String _query= '';
  bool _isLoading= true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async{
    setState(() {
      _isLoading=true;
      _errorMessage=null;
    });

    try{
      final loadedItems= await _storage.loadItems();

      if(!mounted) return;

      setState(() {
        _items= loadedItems;
        _isLoading=false;
      });
    } catch (e){
      if(!mounted) return;

      setState(() {
        _errorMessage= 'không đọc được data: $e';
        _isLoading= false;
      });
    }
  }

  List<TaskItem> get _filteredItems{
    final query= _query.trim().toLowerCase();

    if (query.isEmpty){
      return _items;
    }

    return _items.where((item){
      return item.title.toLowerCase().contains(query)||
          item.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _saveItems(List<TaskItem> updatedItems) async {
    try{
      //ghi file trước; chỉ cập nhật khi dao diện ghi thành công
      await _storage.saveItems(updatedItems);

      if(!mounted) return;

      setState(() {
        _items= updatedItems;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu data')),
      );
    } catch (e){
      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    }
  }

  Future<void> _showItemDialog({TaskItem? existing}) async{
    final nextId= _items.fold<int>(
      0,
        (largestId, item)=> item.id>largestId ? item.id : largestId,
    )+1;

    TaskItem? dialogResult;

    dialogResult= await showDialog<TaskItem>(
        context: context,
        builder:(_)=> TaskDialog(
          existing: existing,
          nextId:nextId,
        ),
    );

    final savedItem= dialogResult;
    if(savedItem== null)return;

    final updatedItems= existing==null
        ? <TaskItem>[..._items,savedItem]
        : _items
            .map(
              (item)=> item.id==savedItem.id?savedItem: item,
            ).toList();

    await _saveItems(updatedItems);
  }
  
  Future<void> _deleteItem(TaskItem item) async{
    final confirmed= await showDialog<bool>(
        context: context, 
        builder: (dialogContext){
          return AlertDialog(
            title: const Text('Xóa mục này?'),
            content: Text('Bạn muốn xóa "${item.title}" chứ?'),
            actions: [
              TextButton(
                  onPressed: ()=> Navigator.of(dialogContext).pop(false), 
                  child: const Text('Hủy'),
              ),
              FilledButton(
                  onPressed: ()=> Navigator.of(dialogContext).pop(true), 
                  child: const Text('Xóa'),
              ),
            ],
          );
        },
    );
    
    if (confirmed!=true) return;
    
    final updatedItems=_items
        .where((currentItem)=> currentItem.id !=item.id)
        .toList();
    
    await _saveItems(updatedItems);
  }
  
  Widget _buildBody(){
    if (_isLoading){
      return const Center(child: CircularProgressIndicator(),);
    }
    
    if(_errorMessage!=null){
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12,),
              FilledButton(
                  onPressed: () async{
                    await _loadItems();
                  },
                  child: const Text('Thử tải lại'),
              ),
            ],
          ),
        ),
      );
    }

    final visibleItems= _filteredItems;

    if(visibleItems.isEmpty){
      return Center(
        child: Text(
          _items.isEmpty
              ?'Danh sách đang trống'
              :'Không tìm thấy mục phù hợp',
        ),
      );
    }

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value){
                setState(() {
                  _query=value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Tìm theo tiêu đề hoặc mô tả',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: visibleItems.length,
            itemBuilder: (context,index){
              final item= visibleItems[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action)async{
                      if(action=='edit'){
                        await _showItemDialog(existing: item);
                      } else if(action=='delete'){
                        await _deleteItem(item);
                      }
                    },
                    itemBuilder: (context)=> const [
                      PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa'),
                      ),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách cục bộ'),
      ),
      body: _buildBody(),
      floatingActionButton: 
            !_isLoading&&_errorMessage==null
                ? FloatingActionButton.extended(
                    onPressed: ()async{
                      await _showItemDialog();
                    }, 
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm mục'),
                  )
                :null,
    );
  }
}

class TaskDialog extends StatefulWidget{
  const TaskDialog({
    super.key,
    this.existing,
    required this.nextId,
  });
  
  final TaskItem? existing;
  final int nextId;
  
  @override
  State<TaskDialog> createState()=> _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog>{
  final _formkey= GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  
  @override
  void initState(){
    super.initState();
    _titleController= TextEditingController(
      text: widget.existing?.title??'',
    );
    _descriptionController= TextEditingController(
      text: widget.existing?.title??'',
    );
  }
  
  @override
  void dispose(){
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing= widget.existing!=null;
    
    return AlertDialog(
      title: Text(isEditing?'Sửa mục':'Thêm mục'),
      content: Form(
        key: _formkey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration:  const InputDecoration(labelText: 'Tiêu đề'),
              validator: (value){
                if(value==null||value.trim().isEmpty){
                  return 'Hãy nhập tiêu đề';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
              validator: (value){
                if(value==null||value.trim().isEmpty){
                  return 'Hãy nhập mô tả';
                }
                return null;
              },
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: ()=> Navigator.of(context).pop(), 
            child: const Text('Hủy'),
        ),
        FilledButton(
            onPressed: (){
              final isValid=
                  _formkey.currentState?.validate()??false;
              if(!isValid) return;
              
              Navigator.of(context).pop(
                TaskItem(
                    id: widget.existing?.id??widget.nextId, 
                    title: _titleController.text.trim(), 
                    description: _descriptionController.text.trim(),
                ),
              );
            }, 
            child: Text(isEditing?'Lưu':'Thêm'),
        ),
      ],
    );
  }
}