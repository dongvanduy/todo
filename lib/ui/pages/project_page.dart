import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_todo/controllers/project_controller.dart';
import 'package:task_todo/controllers/task_controller.dart';
import 'package:task_todo/models/project.dart';
import 'package:task_todo/models/task.dart';
import 'package:task_todo/ui/pages/add_task_page.dart';
import 'package:task_todo/ui/theme.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final TaskController _taskController = Get.put(TaskController());
  final ProjectController _projectController = Get.put(ProjectController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _taskController.getTasks();
    await _projectController.getProjects();
    await _projectController.ensureProjects(
      _taskController.taskList
          .map((task) => task.project ?? '')
          .where((project) => project.trim().isNotEmpty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Projects', style: titleStyle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Get.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final projects = _projectController.projectList;
        if (projects.isEmpty) {
          return Center(
            child: Text(
              'Chưa có project nào. Tạo project mới để bắt đầu.',
              style: subTitleStyle,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final project = projects[index];
            return _ProjectCard(
              project: project,
              taskController: _taskController,
              onEditProject: () => _showEditProjectDialog(project),
              onDeleteProject: () => _confirmDeleteProject(project),
              onAddTask: () => _openAddTask(project.name),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        backgroundColor: primaryClr,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateProjectDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tạo project mới'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Tên project',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên project';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  await _projectController.addProject(controller.text.trim());
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditProjectDialog(Project project) async {
    final controller = TextEditingController(text: project.name);
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa project'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Tên project',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên project';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final updatedName = controller.text.trim();
                  await _projectController.updateProject(
                    project: Project(id: project.id, name: updatedName),
                    previousName: project.name,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteProject(Project project) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa project?'),
          content: const Text(
            'Tất cả nhiệm vụ trong project sẽ bị xóa. Bạn có chắc chắn?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await _projectController.deleteProject(project);
                await _taskController.getTasks();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAddTask(String projectName) async {
    final result = await Get.to(() => AddTaskPage(presetProject: projectName));
    if (result == true) {
      await _taskController.getTasks();
      await _projectController.getProjects();
    }
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.taskController,
    required this.onEditProject,
    required this.onDeleteProject,
    required this.onAddTask,
  });

  final Project project;
  final TaskController taskController;
  final VoidCallback onEditProject;
  final VoidCallback onDeleteProject;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasks = taskController.taskList
          .where((task) => task.project == project.name)
          .toList();
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                Expanded(
                  child: Text(
                    project.name,
                    style: titleStyle,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEditProject,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDeleteProject,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${tasks.length} nhiệm vụ', style: subTitleStyle),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Text('Chưa có nhiệm vụ', style: subTitleStyle)
            else
              Column(
                children: tasks.map((task) {
                  return _ProjectTaskRow(
                    task: task,
                    onEdit: () => _editTask(context, task),
                    onDelete: () => taskController.deleteTasks(task),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Thêm nhiệm vụ'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final result = await Get.to(() => AddTaskPage(task: task));
    if (result == true) {
      await taskController.getTasks();
    }
  }
}

class _ProjectTaskRow extends StatelessWidget {
  const _ProjectTaskRow({
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Get.isDarkMode ? Colors.black26 : Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Nhiệm vụ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (task.note != null && task.note!.isNotEmpty)
                  Text(
                    task.note!,
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
