import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_todo/controllers/task_controller.dart';
import 'package:task_todo/models/task.dart';
import 'package:task_todo/services/notification_services.dart';
import 'package:task_todo/services/theme_services.dart';
import 'package:task_todo/ui/pages/add_task_page.dart';
import 'package:task_todo/ui/pages/project_page.dart';
import 'package:task_todo/ui/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());
  late NotifyHelper notifyHelper;
  int _selectedIndex = 0;

  // Controller cho hiệu ứng xoay tròn ngày tháng
  late FixedExtentScrollController _dateScrollController;
  final int _daysRange = 365 * 2; // Cho phép chọn trong vòng 2 năm
  final int _initialOffset = 365; // Bắt đầu từ giữa (Hôm nay)

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    _taskController.getTasks();

    // Khởi tạo controller ngày ở vị trí "Hôm nay"
    _dateScrollController = FixedExtentScrollController(initialItem: _initialOffset);
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(),
          _buildDateWheelPicker(), // Thanh ngày tháng xoay tròn
          const SizedBox(height: 10),
          _buildTasksList(),       // Danh sách Timeline dọc
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGETS CON ---

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
          'Taskito',
          style: TextStyle(
              color: Get.isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold
          )
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
            icon: Icon(Icons.search, color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () {}),
        IconButton(
            icon: Icon(Icons.nightlight_round, color: Get.isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              ThemeServices().switchTheme();
            }),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Get.isDarkMode ? Colors.white : Colors.black),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM', 'vi').format(_selectedDate),
                style: titleStyle.copyWith(fontSize: 20),
              ),
              const Text("Hôm nay", style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundImage: const AssetImage('images/person.jpeg'),
            backgroundColor: Colors.grey[200],
          )
        ],
      ),
    );
  }

  Widget _buildDateWheelPicker() {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 10),
      // Sử dụng RotatedBox để biến cuộn dọc thành cuộn ngang
      child: RotatedBox(
        quarterTurns: -1,
        child: ListWheelScrollView.useDelegate(
          controller: _dateScrollController,
          itemExtent: 70, // Độ rộng của mỗi item ngày
          perspective: 0.005, // Tạo hiệu ứng cong 3D
          diameterRatio: 1.5, // Độ cong của vòng xoay
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            int daysFromStart = index - _initialOffset;
            DateTime date = DateTime.now().add(Duration(days: daysFromStart));
            setState(() {
              _selectedDate = date;
            });
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: _daysRange,
            builder: (context, index) {
              int daysFromStart = index - _initialOffset;
              DateTime date = DateTime.now().add(Duration(days: daysFromStart));
              bool isSelected = DateFormat.yMd().format(date) ==
                  DateFormat.yMd().format(_selectedDate);

              return RotatedBox(
                quarterTurns: 1,
                child: _buildDateItem(date, isSelected),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryClr : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: isSelected ? [
          BoxShadow(color: primaryClr.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
        ] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('E', 'vi').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('d').format(date),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return Expanded(
      child: Obx(() {
        var tasks = _taskController.taskList.where((task) {
          if (task.repeat == 'Daily') return true;
          return task.date == DateFormat.yMd().format(_selectedDate);
        }).toList();

        tasks.sort((a, b) => (a.startTime ?? "").compareTo(b.startTime ?? ""));

        if (tasks.isEmpty) {
          return _buildNoTaskWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 50),
          itemCount: tasks.length + 1,
          itemBuilder: (context, index) {
            if (index == tasks.length) {
              return const AddTaskButtonTimeline();
            }

            Task task = tasks[index];
            return GestureDetector(
              onTap: () => _showBottomSheet(context, task),
              child: TaskTimelineItem(
                task: task,
                isFirst: index == 0,
                isLast: index == tasks.length - 1,
              ),
            );
          },
        );
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.24
            : MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6, width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300]),
            ),
            const Spacer(),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheetButton(
              label: "Hoàn thành",
              onTap: () {
                _taskController.markTaskAsCompleted(task.id!);
                Get.back();
              },
              clr: primaryClr,
            ),
            _buildBottomSheetButton(
                label: "Xóa công việc",
                onTap: () {
                  _taskController.deleteTasks(task);
                  Get.back();
                },
                clr: Colors.red[300]!),
            const SizedBox(height: 20),
            _buildBottomSheetButton(
                label: "Đóng",
                onTap: () => Get.back(),
                clr: Colors.white,
                isClose: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _buildBottomSheetButton({
    required String label,
    required Function() onTap,
    required Color clr,
    bool isClose = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose ? Colors.grey[300]! : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle.copyWith(color: Colors.black)
                : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildNoTaskWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("Không có việc gì hôm nay!", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          AddTaskButton( // Đây là class bạn bị thiếu trước đó
              label: 'Thêm nhiệm vụ',
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              }
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryClr,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: (index) async {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          await Get.to(() => const ProjectPage());
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: primaryClr.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.access_time_filled),
          ),
          label: 'Hôm nay',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Project'),
        const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Của tôi'),
      ],
    );
  }
}

// --- CLASS UI ---

// Class này dành cho nút "Thêm nhiệm vụ" khi danh sách trống
class AddTaskButton extends StatelessWidget {
  final String label;
  final Function() onTap;

  const AddTaskButton({Key? key, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 50,
        decoration: BoxDecoration(
          color: primaryClr,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Class này dành cho Item trong danh sách Timeline
class TaskTimelineItem extends StatelessWidget {
  final Task task;
  final bool isFirst;
  final bool isLast;

  const TaskTimelineItem({
    Key? key,
    required this.task,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getBGClr(task.color ?? 0);
    bool isCompleted = task.isCompleted == 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 16),
                Text(
                  task.startTime ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  task.endTime ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 2,
                  color: Colors.grey[300],
                  margin: EdgeInsets.only(
                      top: isFirst ? 20 : 0,
                      bottom: 0
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)
                      ]
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 20, bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.grey[100] : statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(5),
                ),
                border: Border.all(
                  color: isCompleted ? Colors.transparent : statusColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green, size: 18)
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (task.note != null && task.note!.isNotEmpty)
                    Text(
                      task.note!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBGClr(int no) {
    switch (no) {
      case 0: return bluishClr;
      case 1: return pinkClr;
      case 2: return orangeClr;
      default: return bluishClr;
    }
  }
}

// Class này dành cho nút "Thêm nhiệm vụ" ở cuối danh sách Timeline
class AddTaskButtonTimeline extends StatelessWidget {
  const AddTaskButtonTimeline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 80, right: 20, bottom: 20),
      child: InkWell(
        onTap: () async {
          await Get.to(() => const AddTaskPage());
          Get.find<TaskController>().getTasks();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: Colors.grey),
              SizedBox(width: 8),
              Text("Thêm nhiệm vụ mới", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
