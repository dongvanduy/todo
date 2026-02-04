import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_todo/services/lunar_calendar.dart';
import 'package:task_todo/ui/theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final lunarDate = LunarCalendar.solarToLunar(_selectedDate);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch'),
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
        elevation: 0,
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text('Lịch dương', style: titleStyle),
            const SizedBox(height: 12),
            _buildCalendarCard(theme),
            const SizedBox(height: 18),
            Text('Lịch âm', style: titleStyle),
            const SizedBox(height: 12),
            _buildLunarCard(theme, lunarDate),
            const SizedBox(height: 18),
            _buildTipsCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
              style: subHeadingStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLunarCard(ThemeData theme, LunarDate lunarDate) {
    final leapLabel = lunarDate.isLeapMonth ? ' (Nhuận)' : '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày ${lunarDate.day} tháng ${lunarDate.month} năm ${lunarDate.year}$leapLabel',
            style: subHeadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn ngày để xem lịch âm/dương tương ứng.',
            style: bodyStyle.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryClr.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: primaryClr),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Theo dõi lịch âm/dương để lên lịch các sự kiện quan trọng.',
              style: bodyStyle.copyWith(color: theme.colorScheme.onBackground),
            ),
          ),
        ],
      ),
    );
  }
}
