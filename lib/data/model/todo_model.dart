class TodoListModel {
  final String id;
  final String title;
  final bool status;

  TodoListModel({
    required this.id,
    required this.title,
    required this.status,
  });

  TodoListModel.fromJson(Map<String, dynamic> json)
      : this(
            id: json["id"].toString(),
            title: json["title"].toString(),
            status: json["status"] as bool);

  TodoListModel copyWith({
    String? id,
    bool? status,
    String? title,
  }) {
    return TodoListModel(
        id: id ?? this.id,
        title: title ?? this.title,
        status: status ?? this.status);
  }

  Map<String , dynamic> toJson(){
    return {
      'id' : id,
      'title' : title,
      'status' : status
    };
  }
}
