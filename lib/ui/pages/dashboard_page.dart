import 'package:fl_chart/fl_chart.dart';
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
      final allItems = widget.taskController.taskList.toList();
      final taskItems =
          allItems.where((task) => task.isNote != 1).toList(growable: false);
      final noteItems =
          allItems.where((task) => task.isNote == 1).toList(growable: false);
      final completed =
          taskItems.where((task) => task.isCompleted == 1).length;
      final pending =
          taskItems.where((task) => task.isCompleted != 1).length;
      final progress = taskItems.isEmpty ? 0.0 : completed / taskItems.length;
      final groupedTasks = _groupTasksByProject(taskItems);

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
              _CenterPieChart(completed: completed, pending: pending),
              const SizedBox(height: 16),
              _StatGrid(
                total: taskItems.length,
                completed: completed,
                pending: pending,
                notes: noteItems.length,
                progress: progress,
              ),
              const SizedBox(height: 20),
              Text('Projects', style: titleStyle),
              const SizedBox(height: 12),
              _ProjectGroupList(groups: groupedTasks),
              if (allItems.isEmpty)
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

  Map<String, List<Task>> _groupTasksByProject(List<Task> tasks) {
    final Map<String, List<Task>> grouped = {};
    for (final task in tasks) {
      final rawProject = task.project?.trim();
      final key = rawProject == null || rawProject.isEmpty
          ? 'Unassigned'
          : rawProject;
      grouped.putIfAbsent(key, () => []).add(task);
    }
    return grouped;
  }
}

class _CenterPieChart extends StatelessWidget {
  const _CenterPieChart({
    required this.completed,
    required this.pending,
  });

  final int completed;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final total = completed + pending;
    final hasData = total > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Task Completion', style: titleStyle),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 48,
                sectionsSpace: 4,
                sections: hasData
                    ? [
                        PieChartSectionData(
                          color: primaryClr,
                          value: completed.toDouble(),
                          radius: 50,
                          title: '$completed',
                          titleStyle: titleStyle.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: orangeClr,
                          value: pending.toDouble(),
                          radius: 50,
                          title: '$pending',
                          titleStyle: titleStyle.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ]
                    : [
                        PieChartSectionData(
                          color: Colors.grey.shade300,
                          value: 1,
                          radius: 50,
                          title: '0',
                          titleStyle: titleStyle.copyWith(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _LegendDot(label: 'Completed', color: primaryClr),
              _LegendDot(label: 'Pending', color: orangeClr),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.total,
    required this.completed,
    required this.pending,
    required this.notes,
    required this.progress,
  });

  final int total;
  final int completed;
  final int pending;
  final int notes;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _PastelStatCard(
          title: 'Total Tasks',
          value: total,
          icon: Icons.list_alt,
          startColor: const Color(0xFFE3F2FD),
          endColor: const Color(0xFFCFE7FF),
        ),
        _PastelStatCard(
          title: 'Completed',
          value: completed,
          icon: Icons.check_circle_outline,
          startColor: const Color(0xFFE6F7F1),
          endColor: const Color(0xFFCBF0E3),
        ),
        _PastelStatCard(
          title: 'Pending',
          value: pending,
          icon: Icons.timelapse,
          startColor: const Color(0xFFFFF3E0),
          endColor: const Color(0xFFFFE0B2),
        ),
        _PastelStatCard(
          title: 'Notes',
          value: notes,
          icon: Icons.note_alt_outlined,
          startColor: const Color(0xFFF3E5F5),
          endColor: const Color(0xFFE1BEE7),
          footer: '$percentage% done',
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
    this.footer,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color startColor;
  final Color endColor;
  final String? footer;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(title, style: subTitleStyle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('$value', style: headingStyle),
          if (footer != null) ...[
            const SizedBox(height: 6),
            Text(
              footer!,
              style: subTitleStyle.copyWith(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectGroupList extends StatelessWidget {
  const _ProjectGroupList({required this.groups});

  final Map<String, List<Task>> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
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
          'No projects to show yet.',
          style: subTitleStyle.copyWith(
            color: Get.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      );
    }

    final sortedKeys = groups.keys.toList()..sort();
    return Column(
      children: sortedKeys.map((project) {
        final projectTasks = groups[project]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode ? darkHeaderClr : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(project, style: titleStyle),
                  const Spacer(),
                  Text(
                    '${projectTasks.length} tasks',
                    style: subTitleStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...projectTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted == 1
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.isCompleted == 1
                            ? primaryClr
                            : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.title ?? 'Untitled Task',
                          style: subTitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: subTitleStyle.copyWith(fontSize: 12)),
      ],
    );
  }
}
