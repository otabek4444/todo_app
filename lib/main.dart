import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'todo_model.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Kategoriyalar va ularning ranglari
const Map<String, Color> categoryColors = {
  'Work': Colors.blue,
  'Personal': Colors.green,
  'Shopping': Colors.orange,
  'Health': Colors.red,
  'Study': Colors.purple,
};

const Map<String, IconData> categoryIcons = {
  'Work': Icons.work_outline,
  'Personal': Icons.person_outline,
  'Shopping': Icons.shopping_cart_outlined,
  'Health': Icons.favorite_outline,
  'Study': Icons.school_outlined,
};

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> todos = [];
  final TextEditingController _controller = TextEditingController();
  String selectedCategory = 'Work';
  String filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = todos.where((todo) => todo.isCompleted).length;
    int totalCount = todos.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Tasks'),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAddTodoSection(),
          _buildFilterButtons(),
          Expanded(
            child: todos.isEmpty ? _buildEmptyState() : _buildTodoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTodoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: categoryColors.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColors[category],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(categoryIcons[category], size: 20),
                      SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Yangi vazifa qo\'shing...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    prefixIcon: Icon(
                      categoryIcons[selectedCategory],
                      color: categoryColors[selectedCategory],
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addTodo(value);
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _addTodo(_controller.text);
                  }
                },
                backgroundColor: categoryColors[selectedCategory],
                child: Icon(Icons.add),
                elevation: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All', Icons.apps),
          ...categoryColors.keys.map((category) {
            return _buildFilterChip(
              category,
              categoryIcons[category]!,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    bool isSelected = filterCategory == label;
    Color chipColor = label == 'All' ? Colors.grey : categoryColors[label]!;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            SizedBox(width: 6),
            Text(label),
          ],
        ),
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: chipColor.withOpacity(0.1),
        onSelected: (bool selected) {
          setState(() {
            filterCategory = label;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Vazifalar yo\'q',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Yangi vazifa qo\'shib boshlang!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    List<Todo> filteredTodos = filterCategory == 'All'
        ? todos
        : todos.where((todo) => todo.category == filterCategory).toList();

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        final realIndex = todos.indexOf(todo);

        return Dismissible(
          key: Key(todo.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteTodo(realIndex);
          },
          child: Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: categoryColors[todo.category]!.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: categoryColors[todo.category],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Checkbox(
                    value: todo.isCompleted,
                    activeColor: categoryColors[todo.category],
                    onChanged: (value) {
                      _toggleTodo(realIndex);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    categoryIcons[todo.category],
                    size: 14,
                    color: categoryColors[todo.category],
                  ),
                  SizedBox(width: 4),
                  Text(
                    todo.category,
                    style: TextStyle(
                      color: categoryColors[todo.category],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                onPressed: () {
                  _deleteTodo(realIndex);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString('todos');

    if (todosString != null) {
      final List<dynamic> decoded = jsonDecode(todosString);
      setState(() {
        todos = decoded.map((item) => Todo.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
    jsonEncode(todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', encoded);
  }

  void _addTodo(String title) {
    setState(() {
      todos.add(Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: selectedCategory,
        isCompleted: false,
      ));
    });
    _controller.clear();
    _saveTodos();
  }

  void _toggleTodo(int index) {
    setState(() {
      todos[index].isCompleted = !todos[index].isCompleted;
    });
    _saveTodos();
  }

  void _deleteTodo(int index) {
    final deletedTodo = todos[index];
    setState(() {
      todos.removeAt(index);
    });
    _saveTodos();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedTodo.title} o\'chirildi'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Qaytarish',
          onPressed: () {
            setState(() {
              todos.insert(index, deletedTodo);
            });
            _saveTodos();
          },
        ),
      ),
    );
  }
}