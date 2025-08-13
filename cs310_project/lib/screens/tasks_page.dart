import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/app_styles.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Günlük Meditasyon',
      description: 'Sabah 10 dakika nefes egzersizi ve mindfulness pratiği yapın',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Günlük Günlük Yazma',
      description: 'Bugün yaşadığınız en güzel anıyı yazın ve neden özel olduğunu düşünün',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Task(
      id: '3',
      title: 'Sosyal Bağlantı',
      description: 'Bir arkadaşınızla veya aile üyenizle iletişime geçin',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Task(
      id: '4',
      title: 'Fiziksel Aktivite',
      description: 'En az 30 dakika yürüyüş veya hafif egzersiz yapın',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _removeTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Görev kaldırıldı'),
          ],
        ),
        backgroundColor: AppStyles.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
        ),
      ),
    );
  }

  void _toggleTaskCompletion(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      }
    });
    
    final task = _tasks.firstWhere((task) => task.id == taskId);
    if (task.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text('Tebrikler! Görevi tamamladınız'),
            ],
          ),
          backgroundColor: AppStyles.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    final totalTasks = _tasks.length;
    final progressPercentage = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppStyles.secondaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.task_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Günlük Görevler',
              style: AppStyles.headingSmallStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppStyles.secondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppStyles.largePadding),
                decoration: BoxDecoration(
                  gradient: AppStyles.secondaryGradient,
                  borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
                  boxShadow: AppStyles.elevatedShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Günlük İlerleme',
                                style: AppStyles.headingSmallStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$completedTasks / $totalTasks görev tamamlandı',
                                style: AppStyles.bodyStyle.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: progressPercentage,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(progressPercentage * 100).toInt()}% tamamlandı',
                      style: AppStyles.bodyMediumStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppStyles.largePadding),
              
              // Tasks Section
              Text(
                'Görevleriniz',
                style: AppStyles.headingMediumStyle,
              ),
              const SizedBox(height: AppStyles.defaultPadding),
              
              if (_tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.extraLargePadding),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppStyles.textLightColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.task_alt,
                          size: 40,
                          color: AppStyles.textLightColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz görev yok',
                        style: AppStyles.headingSmallStyle.copyWith(
                          color: AppStyles.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni görevler ekleyerek günlük rutininizi oluşturun',
                        style: AppStyles.bodyMediumStyle.copyWith(
                          color: AppStyles.textLightColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = index * 0.1;
                        final animation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(delay, delay + 0.6, curve: Curves.easeOutCubic),
                        ));
                        
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - animation.value)),
                          child: Opacity(
                            opacity: animation.value,
                            child: _buildTaskCard(task),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppStyles.secondaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppStyles.elevatedShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showAddTaskDialog();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      decoration: AppStyles.elevatedCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTaskCompletion(task.id),
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: task.isCompleted 
                      ? AppStyles.successColor 
                      : AppStyles.backgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: task.isCompleted 
                        ? AppStyles.successColor 
                        : AppStyles.textLightColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    task.isCompleted ? Icons.check : Icons.circle_outlined,
                    color: task.isCompleted ? Colors.white : AppStyles.textLightColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppStyles.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted 
                            ? AppStyles.textLightColor 
                            : AppStyles.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description,
                        style: AppStyles.bodyMediumStyle.copyWith(
                          color: AppStyles.textSecondaryColor,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppStyles.textLightColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(task.createdAt),
                            style: AppStyles.captionStyle.copyWith(
                              color: AppStyles.textLightColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Delete Button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppStyles.errorColor,
                  ),
                  onPressed: () => _showDeleteConfirmation(task),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppStyles.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: AppStyles.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Görevi Sil',
              style: AppStyles.headingSmallStyle,
            ),
          ],
        ),
        content: Text(
          'Bu görevi silmek istediğinize emin misiniz?',
          style: AppStyles.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppStyles.bodyStyle.copyWith(
                color: AppStyles.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeTask(task.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.largeBorderRadius),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppStyles.secondaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_task,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Yeni Görev Ekle',
              style: AppStyles.headingSmallStyle,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: AppStyles.textFieldDecoration(
                'Görev Başlığı',
                hint: 'Örn: Günlük meditasyon',
              ),
            ),
            const SizedBox(height: AppStyles.defaultPadding),
            TextFormField(
              controller: descriptionController,
              decoration: AppStyles.textFieldDecoration(
                'Açıklama',
                hint: 'Görev detaylarını yazın',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppStyles.bodyStyle.copyWith(
                color: AppStyles.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  createdAt: DateTime.now(),
                );
                
                setState(() {
                  _tasks.insert(0, newTask);
                });
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Yeni görev eklendi'),
                      ],
                    ),
                    backgroundColor: AppStyles.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppStyles.smallBorderRadius),
                    ),
                  ),
                );
              }
            },
            style: AppStyles.primaryButtonStyle,
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
} 