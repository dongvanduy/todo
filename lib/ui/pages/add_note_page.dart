import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_todo/controllers/task_controller.dart';
import 'package:task_todo/models/task.dart';
import 'package:task_todo/ui/theme.dart';
import 'package:task_todo/ui/widgets/button.dart';
import '../widgets/input_field.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({Key? key}) : super(key: key);

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: context.theme.colorScheme.background,
      appBar: _customAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Add Note',
                style: headingStyle,
              ),
              InputField(
                title: 'Title',
                hint: 'Enter title here',
                controller: _titleController,
              ),
              InputField(
                title: 'Content',
                hint: 'Enter note content here',
                controller: _noteController,
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: MyButton(
                  label: 'Save Note',
                  onTap: _validateData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _customAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: primaryClr,
        ),
      ),
      elevation: 0,
      // ignore: deprecated_member_use
      backgroundColor: context.theme.colorScheme.background,
      actions: const [
        CircleAvatar(
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
        SizedBox(
          width: 20,
        ),
      ],
      centerTitle: true,
    );
  }

  void _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addNoteToDb();
      Get.back();
    } else if (_titleController.text.isNotEmpty ||
        _noteController.text.isNotEmpty) {
      Get.snackbar('required', 'All fields are required!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ));
    } else {
      print(
          '############################ SOMETHING WRONG HAPPENED #############################');
    }
  }

  Future<void> _addNoteToDb() async {
    try {
      final value = await _taskController.addTask(
        task: Task(
          title: _titleController.text,
          note: _noteController.text,
          isCompleted: 0,
          isNote: 1,
          date: null,
          startTime: null,
          endTime: null,
          color: 0,
          remind: 0,
          repeat: 'None',
        ),
      );
      print('Value: $value');
    } catch (e) {
      print('error: $e');
    }
  }
}
