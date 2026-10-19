class TaskItem{
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
  });

  final int id;
  final String title;
  final String description;

  factory TaskItem.fromJson(Map<String, dynamic> json){
    return TaskItem(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'title': title,
      'description': description,
    };
  }
}