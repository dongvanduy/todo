import 'package:get/get.dart';
import 'package:task_todo/db/db_helper.dart';
import 'package:task_todo/models/project.dart';

class ProjectController extends GetxController {
  final RxList<Project> projectList = <Project>[].obs;

  Future<int> addProject(String name) async {
    final id = await DBHelper.insertProject(
      Project(name: name),
      ignoreDuplicate: true,
    );
    await getProjects();
    return id;
  }

  Future<void> getProjects() async {
    final items = await DBHelper.queryProjects();
    projectList.assignAll(items.map(Project.fromJson).toList());
  }

  Future<void> updateProject({
    required Project project,
    required String previousName,
  }) async {
    await DBHelper.updateProject(project);
    await DBHelper.updateProjectTasks(previousName, project.name);
    await getProjects();
  }

  Future<void> deleteProject(Project project) async {
    await DBHelper.deleteProject(project);
    await DBHelper.deleteTasksByProject(project.name);
    await getProjects();
  }

  Future<void> ensureProject(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await DBHelper.insertProject(
      Project(name: trimmed),
      ignoreDuplicate: true,
    );
    await getProjects();
  }

  Future<void> ensureProjects(Iterable<String> names) async {
    final uniqueNames = names.map((name) => name.trim()).where((name) {
      return name.isNotEmpty;
    }).toSet();
    if (uniqueNames.isEmpty) {
      return;
    }
    for (final name in uniqueNames) {
      await DBHelper.insertProject(
        Project(name: name),
        ignoreDuplicate: true,
      );
    }
    await getProjects();
  }
}
