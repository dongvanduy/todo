import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_todo/controllers/project_controller.dart';
import 'package:task_todo/controllers/task_controller.dart';
import 'package:task_todo/ui/theme.dart';
import 'package:task_todo/ui/widgets/button.dart';

import '../../models/task.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key, this.task, this.presetProject}) : super(key: key);

  final Task? task;
  final String? presetProject;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final ProjectController _projectController = Get.put(ProjectController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();

  int _selectedRemind = 5;
  final List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'None';
  final List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];

  int _selectedColor = 0;
  String? _selectedProjectOption;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _taskController.getTasks();
      await _projectController.getProjects();
      await _projectController.ensureProjects(
        _taskController.taskList
            .map((task) => task.project ?? '')
            .where((project) => project.trim().isNotEmpty),
      );
    });

    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title ?? '';
      _noteController.text = task.note ?? '';
      _projectNameController.text = task.project ?? '';
      _selectedDate =
          task.date != null ? DateFormat.yMd().parse(task.date!) : _selectedDate;
      _startTime = task.startTime ?? _startTime;
      _endTime = task.endTime ?? _endTime;
      _selectedRemind = task.remind ?? _selectedRemind;
      _selectedRepeat = task.repeat ?? _selectedRepeat;
      _selectedColor = task.color ?? _selectedColor;
      _selectedProjectOption = task.project;
    } else if (widget.presetProject != null) {
      _projectNameController.text = widget.presetProject!.trim();
      _selectedProjectOption = widget.presetProject!.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.task != null;
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: _customAppBar(isEditMode),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(isEditMode),
              const SizedBox(height: 16),
              _sectionCard(
                child: Column(
                  children: [
                    InputField(
                      title: 'field_title'.tr,
                      hint: 'field_title_hint'.tr,
                      controller: _titleController,
                    ),
                    InputField(
                      title: 'field_note'.tr,
                      hint: 'field_note_hint'.tr,
                      controller: _noteController,
                    ),
                    InputField(
                      title: 'field_project'.tr,
                      hint: 'field_project_hint'.tr,
                      controller: _projectNameController,
                    ),
                    _projectDropdown(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                child: Column(
                  children: [
                    InputField(
                      title: 'field_date'.tr,
                      hint: DateFormat.yMd().format(_selectedDate),
                      widget: IconButton(
                        onPressed: _getDateFromUser,
                        icon: const Icon(Icons.calendar_today_outlined,
                            color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InputField(
                            title: 'field_start_time'.tr,
                            hint: _startTime,
                            widget: IconButton(
                              onPressed: () =>
                                  _getTimeFromUser(isStartTime: true),
                              icon: const Icon(Icons.access_time_rounded,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputField(
                            title: 'field_end_time'.tr,
                            hint: _endTime,
                            widget: IconButton(
                              onPressed: () =>
                                  _getTimeFromUser(isStartTime: false),
                              icon: const Icon(Icons.access_time_rounded,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _modernSelector<int>(
                      label: 'field_remind'.tr,
                      value: _selectedRemind,
                      items: remindList,
                      display: (value) => '$value ${'minutes_short'.tr}',
                      onChanged: (value) => setState(() => _selectedRemind = value),
                    ),
                    const SizedBox(height: 12),
                    _modernSelector<String>(
                      label: 'field_repeat'.tr,
                      value: _selectedRepeat,
                      items: repeatList,
                      display: (value) {
                        switch (value) {
                          case 'Daily':
                            return 'repeat_daily'.tr;
                          case 'Weekly':
                            return 'repeat_weekly'.tr;
                          case 'Monthly':
                            return 'repeat_monthly'.tr;
                          default:
                            return 'repeat_none'.tr;
                        }
                      },
                      onChanged: (value) => setState(() => _selectedRepeat = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _colorPalette(),
                    MyButton(
                      label: isEditMode ? 'save_task_button'.tr : 'create_task_button'.tr,
                      onTap: _validateData,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection(bool isEditMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryClr.withOpacity(0.9), primaryClr.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditMode ? 'edit_task_title'.tr : 'add_task_title'.tr,
            style: headingStyle.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'task_form_header_desc'.tr,
            style: subTitleStyle.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _projectDropdown() {
    return Obx(() {
      final projectOptions = _projectController.projectList
          .map((project) => project.name)
          .toSet()
          .toList()
        ..sort();

      if (projectOptions.isEmpty) {
        return const SizedBox.shrink();
      }

      final currentSelection = projectOptions.contains(_selectedProjectOption)
          ? _selectedProjectOption
          : null;

      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentSelection,
            hint: Text('field_project_select'.tr, style: subTitleStyle),
            isExpanded: true,
            items: projectOptions
                .map(
                  (project) => DropdownMenuItem(
                    value: project,
                    child: Text(project, style: subTitleStyle),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedProjectOption = value;
                if (value != null) {
                  _projectNameController.text = value;
                }
              });
            },
          ),
        ),
      );
    });
  }

  Widget _modernSelector<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) display,
    required void Function(T) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(label, style: titleStyle),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final selected = item == value;
              return ChoiceChip(
                label: Text(display(item)),
                selected: selected,
                onSelected: (_) => onChanged(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  AppBar _customAppBar(bool isEditMode) {
    return AppBar(
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: primaryClr,
        ),
      ),
      elevation: 0,
      backgroundColor: context.theme.colorScheme.background,
      centerTitle: true,
      title: Text(isEditMode ? 'edit_task_nav_title'.tr : 'create_task_title'.tr, style: titleStyle),
    );
  }

  void _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _saveTask();
    } else {
      Get.snackbar(
        'required'.tr,
        'all_fields_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveTask() async {
    try {
      final projectName = _projectNameController.text.trim();
      final normalizedProject = projectName.isEmpty ? null : projectName;
      if (normalizedProject != null) {
        await _projectController.ensureProject(normalizedProject);
      }

      if (widget.task == null) {
        await _taskController.addTask(
          task: Task(
            title: _titleController.text,
            note: _noteController.text,
            isCompleted: 0,
            date: DateFormat.yMd().format(_selectedDate),
            startTime: _startTime,
            endTime: _endTime,
            color: _selectedColor,
            remind: _selectedRemind,
            repeat: _selectedRepeat,
            project: normalizedProject,
            isNote: 0,
          ),
        );
      } else {
        final existing = widget.task!;
        await _taskController.updateTask(
          Task(
            id: existing.id,
            title: _titleController.text,
            note: _noteController.text,
            isCompleted: existing.isCompleted,
            date: DateFormat.yMd().format(_selectedDate),
            startTime: _startTime,
            endTime: _endTime,
            color: _selectedColor,
            remind: _selectedRemind,
            repeat: _selectedRepeat,
            project: normalizedProject,
            isNote: existing.isNote,
          ),
        );
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('field_color'.tr, style: titleStyle),
        const SizedBox(height: 8),
        Wrap(
          children: List<Widget>.generate(
            3,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: CircleAvatar(
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : orangeClr,
                  radius: 14,
                  child: _selectedColor == index
                      ? const Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _getDateFromUser() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _getTimeFromUser({required bool isStartTime}) async {
    final pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 15))),
    );

    if (pickedTime == null) {
      return;
    }

    final formattedTime = pickedTime.format(context);

    if (isStartTime) {
      setState(() => _startTime = formattedTime);
    } else {
      setState(() => _endTime = formattedTime);
    }
  }
}
