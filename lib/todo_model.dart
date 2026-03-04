class Todo {
  String id;
  String title;
  String category;
  bool isCompleted;
  DateTime? dueDate;  // ← Allaqachon bor edi!

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

  // Muddat o'tganmi tekshirish
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  // Bugun tugallanishi kerakmi
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  // Ertaga tugallanishi kerakmi
  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }
}