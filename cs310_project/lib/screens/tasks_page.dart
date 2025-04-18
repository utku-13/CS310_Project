import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_styles.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Complete Flutter Assignment',
      description: 'Implement all required features for the CS310 project',
      createdAt: DateTime.now(),
    ),
    Task(
      id: '2',
      title: 'Study for Exam',
      description: 'Review all course materials and practice problems',
      createdAt: DateTime.now(),
    ),
    Task(
      id: '3',
      title: 'Team Meeting',
      description: 'Discuss project progress and next steps',
      createdAt: DateTime.now(),
    ),
  ];

  void _removeTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }

  void _toggleTaskCompletion(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppStyles.defaultPadding),
              title: Text(
                task.title,
                style: AppStyles.bodyStyle.copyWith(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppStyles.smallPadding),
                  Text(
                    task.description,
                    style: AppStyles.bodyStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: AppStyles.smallPadding),
                  Text(
                    'Created: ${task.createdAt.toString().split('.')[0]}',
                    style: AppStyles.bodyStyle.copyWith(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: task.isCompleted ? Colors.green : Colors.grey,
                    ),
                    onPressed: () => _toggleTaskCompletion(task.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppStyles.errorColor),
                    onPressed: () => _removeTask(task.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add task functionality
        },
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
} 