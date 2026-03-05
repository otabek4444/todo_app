import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'todo_model.dart';
import 'main.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Todo> todos;

  const StatisticsScreen({required this.todos});

  @override
  Widget build(BuildContext context) {
    // Statistika hisoblash
    int totalTodos = todos.length;
    int completedTodos = todos.where((t) => t.isCompleted).length;
    int pendingTodos = totalTodos - completedTodos;
    int overdueTodos = todos.where((t) => t.isOverdue).length;

    // Kategoriya bo'yicha
    Map<String, int> categoryStats = {};
    for (var category in categoryColors.keys) {
      categoryStats[category] = todos.where((t) => t.category == category).length;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistika'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Umumiy statistika kartlari
            _buildStatsCards(totalTodos, completedTodos, pendingTodos, overdueTodos),

            SizedBox(height: 24),

            // Donut chart
            Text(
              'Bajarilganlik',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildDonutChart(completedTodos, pendingTodos),

            SizedBox(height: 32),

            // Kategoriya bo'yicha
            Text(
              'Kategoriya bo\'yicha',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildCategoryBars(categoryStats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(int total, int completed, int pending, int overdue) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Jami',
            total.toString(),
            Colors.blue,
            Icons.list_alt,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Bajarilgan',
            completed.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart(int completed, int pending) {
    if (completed == 0 && pending == 0) {
      return Container(
        height: 200,
        child: Center(
          child: Text('Vazifalar yo\'q', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              value: completed.toDouble(),
              title: '$completed',
              color: Colors.green,
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: pending.toDouble(),
              title: '$pending',
              color: Colors.orange,
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBars(Map<String, int> stats) {
    return Column(
      children: stats.entries.map((entry) {
        String category = entry.key;
        int count = entry.value;
        int maxCount = stats.values.isEmpty ? 1 : stats.values.reduce((a, b) => a > b ? a : b);
        double percentage = maxCount == 0 ? 0 : count / maxCount;

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        categoryIcons[category],
                        size: 16,
                        color: categoryColors[category],
                      ),
                      SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                  Text(
                    '$count',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(categoryColors[category]),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}