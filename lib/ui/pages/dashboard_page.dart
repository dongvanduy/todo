import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_todo/models/task.dart';
import 'package:task_todo/ui/theme.dart';

import '../../controllers/task_controller.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.taskController});

  final TaskController taskController;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = widget.taskController.taskList.toList();
      final completed = tasks.where((task) => task.isCompleted == 1).length;
      final pending = tasks.where((task) => task.isCompleted != 1).length;
      final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;
      final highPriorityTasks =
          tasks.where(_isHighPriority).toList(growable: false);

      return RefreshIndicator(
        onRefresh: widget.taskController.getTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('dashboard_overview'.tr, style: headingStyle),
              const SizedBox(height: 12),
              _HeroProgressCard(progress: progress),
              const SizedBox(height: 16),
              _StatCardRow(pending: pending, completed: completed),
              const SizedBox(height: 20),
              Text('Priority Focus', style: titleStyle),
              const SizedBox(height: 12),
              _PriorityList(tasks: highPriorityTasks),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'dashboard_empty'.tr,
                    style: subTitleStyle,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  bool _isHighPriority(Task task) {
    final note = task.note?.toLowerCase() ?? '';
    final title = task.title?.toLowerCase() ?? '';
    return note.contains('high priority') || title.contains('high priority');
  }
}

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final cardColor = Get.isDarkMode ? darkHeaderClr : Colors.white;
    final percentage = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            cardColor.withOpacity(0.95),
            cardColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Progress', style: titleStyle),
                const SizedBox(height: 8),
                Text(
                  'Stay focused and keep momentum.',
                  style: subTitleStyle.copyWith(
                    color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.4),
                  valueColor: AlwaysStoppedAnimation(primaryClr),
                ),
                Text(
                  '$percentage%',
                  style: titleStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardRow extends StatelessWidget {
  const _StatCardRow({
    required this.pending,
    required this.completed,
  });

  final int pending;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PastelStatCard(
            title: 'Active Tasks',
            value: pending,
            icon: Icons.work_outline,
            startColor: const Color(0xFFE4F0FF),
            endColor: const Color(0xFFCEE2FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PastelStatCard(
            title: 'Completed Tasks',
            value: completed,
            icon: Icons.check_circle_outline,
            startColor: const Color(0xFFFFE9D8),
            endColor: const Color(0xFFFFD7B8),
          ),
        ),
      ],
    );
  }
}

class _PastelStatCard extends StatelessWidget {
  const _PastelStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: subTitleStyle),
                const SizedBox(height: 6),
                Text('$value', style: headingStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityList extends StatelessWidget {
  const _PriorityList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          'No high priority tasks yet.',
          style: subTitleStyle.copyWith(
            color: Get.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Container(
            width: 220,
            margin: EdgeInsets.only(right: index == tasks.length - 1 ? 0 : 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Untitled Task',
                  style: titleStyle.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.priority_high, color: orangeClr, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'High Priority',
                      style: subTitleStyle.copyWith(fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
