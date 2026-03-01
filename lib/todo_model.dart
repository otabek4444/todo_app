class Todo {
  String id;
  String title;
  String category;
  bool isCompleted;
  DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.dueDate,
  });

  // Map dan Todo ga aylantirish
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
    );
  }

  // Todo dan Map ga aylantirish
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}