import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'todo_model.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:fl_chart/fl_chart.dart';
import 'statistics_screen.dart';

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
          // Statistika tugmasi
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(todos: todos),
                ),
              );
            },
          ),
          // Hisob
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
          // Kategoriya tanlash
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

          // Vazifa qo'shish input va tugma
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

          SizedBox(height: 8),

          // Sana tanlash tugmasi
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectDate,
              icon: Icon(Icons.calendar_today, size: 18),
              label: Text('Muddat qo\'shish'),
              style: OutlinedButton.styleFrom(
                foregroundColor: categoryColors[selectedCategory],
                side: BorderSide(color: categoryColors[selectedCategory]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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

        return AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: 1.0,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.3, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: AlwaysStoppedAnimation(1),
                curve: Curves.easeOut,
              ),
            ),
            child: Dismissible(
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
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: todo.isCompleted ? 1 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: categoryColors[todo.category]!.withOpacity(
                        todo.isCompleted ? 0.2 : 0.3,
                      ),
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
                    title: AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 16,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isCompleted ? Colors.grey : Colors.black,
                      ),
                      child: Text(todo.title),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(
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
                            if (todo.dueDate != null) ...[
                              SizedBox(width: 12),
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: _getDueDateColor(todo),
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDueDate(todo.dueDate),
                                style: TextStyle(
                                  color: _getDueDateColor(todo),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (todo.dueDate != null)
                          IconButton(
                            icon: Icon(Icons.event_busy, size: 20),
                            color: Colors.grey,
                            onPressed: () {
                              setState(() {
                                todos[realIndex].dueDate = null;
                              });
                              _saveTodos();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Muddat o\'chirildi'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red[300]),
                          onPressed: () {
                            _deleteTodo(realIndex);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
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

  void _addTodo(String title, {DateTime? dueDate}) {
    setState(() {
      todos.add(Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: selectedCategory,
        isCompleted: false,
        dueDate: dueDate,
      ));
    });
    _controller.clear();
    _saveTodos();

    // Vibration qo'shish
    Vibration.vibrate(duration: 50);
  }

  void _toggleTodo(int index) {
    setState(() {
      todos[index].isCompleted = !todos[index].isCompleted;
    });
    _saveTodos();

    // Vibration qo'shish
    Vibration.vibrate(duration: 50);
  }

  void _deleteTodo(int index) {
    final deletedTodo = todos[index];
    setState(() {
      todos.removeAt(index);
    });
    _saveTodos();

    // Vibration qo'shish
    Vibration.vibrate(duration: 100);

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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: categoryColors[selectedCategory]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_controller.text.isNotEmpty) {
        _addTodo(_controller.text, dueDate: picked);
      }
    }
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Bugun';
    } else if (dateOnly == tomorrow) {
      return 'Ertaga';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  Color _getDueDateColor(Todo todo) {
    if (todo.dueDate == null) return Colors.grey;
    if (todo.isCompleted) return Colors.grey;
    if (todo.isOverdue) return Colors.red;
    if (todo.isDueToday) return Colors.orange;
    return Colors.blue;
  }
}