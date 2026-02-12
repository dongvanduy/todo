import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_todo/controllers/project_controller.dart';
import 'package:task_todo/controllers/task_controller.dart';
import 'package:task_todo/services/google_drive_backup_service.dart';
import 'package:task_todo/services/theme_services.dart';
import 'package:task_todo/ui/pages/privacy_policy_page.dart';
import 'package:task_todo/ui/theme.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key, this.showTopBar = true}) : super(key: key);

  final bool showTopBar;

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  final _settingsBox = GetStorage();
  final _backupService = GoogleDriveBackupService();
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _languageCode = _settingsBox.read<String>('language_code') ??
        Get.deviceLocale?.languageCode ??
        'vi';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.showTopBar
          ? AppBar(
              title: const Text('Tôi'),
              backgroundColor: theme.colorScheme.background,
              foregroundColor: theme.colorScheme.onBackground,
              elevation: 0,
            )
          : null,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildProfileCard(theme),
            const SizedBox(height: 16),
            Text('Cài đặt', style: titleStyle),
            const SizedBox(height: 8),
            _buildDarkModeTile(),
            _buildLanguageTile(),
            _buildPrivacyTile(),
            _buildBackupTile(),
            const SizedBox(height: 20),
            Text('Hỗ trợ', style: titleStyle),
            const SizedBox(height: 8),
            _buildSupportTile(
              icon: Icons.help_outline,
              title: 'Trung tâm trợ giúp',
              subtitle: 'Câu hỏi thường gặp và liên hệ hỗ trợ',
            ),
            _buildSupportTile(
              icon: Icons.star_outline,
              title: 'Đánh giá ứng dụng',
              subtitle: 'Chia sẻ cảm nhận của bạn',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: const AssetImage('images/user.png'),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jayden', style: subHeadingStyle),
                const SizedBox(height: 4),
                Text(
                  'Quản lý lịch trình của bạn mỗi ngày',
                  style: bodyStyle.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildDarkModeTile() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Chế độ tối'),
      subtitle: const Text('Bật/tắt giao diện tối'),
      secondary: Icon(Icons.dark_mode_outlined, color: primaryClr),
      value: Get.isDarkMode,
      onChanged: (value) {
        ThemeServices().switchTheme();
        setState(() {});
      },
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.language, color: primaryClr),
      title: const Text('Ngôn ngữ'),
      subtitle: Text(_languageCode == 'vi' ? 'Tiếng Việt' : 'English'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showLanguageSheet,
    );
  }

  Widget _buildPrivacyTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.privacy_tip_outlined, color: primaryClr),
      title: const Text('Quyền riêng tư'),
      subtitle: const Text('Xem chính sách và điều khoản'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.to(() => const PrivacyPolicyPage()),
    );
  }

  Widget _buildBackupTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.cloud_upload_outlined, color: primaryClr),
      title: const Text('Sao lưu Google Drive'),
      subtitle: const Text('Đồng bộ và lưu trữ dữ liệu'),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showBackupSheet,
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: primaryClr),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Get.snackbar(
          title,
          'Chức năng này đang được cập nhật.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      },
    );
  }

  void _showBackupSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text('Google Drive', style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'Sao lưu hoặc khôi phục dữ liệu nhiệm vụ của bạn.',
                style: bodyStyle.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_upload_rounded, color: primaryClr),
                title: const Text('Sao lưu ngay'),
                subtitle: const Text('Tải dữ liệu hiện tại lên Google Drive'),
                onTap: () {
                  Get.back();
                  _runBackup();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.restore_rounded, color: primaryClr),
                title: const Text('Khôi phục từ Drive'),
                subtitle: const Text('Ghi đè dữ liệu cục bộ bằng bản sao lưu mới nhất'),
                onTap: () {
                  Get.back();
                  _runRestore();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _runBackup() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final message = await _backupService.backupToDrive();
      Get.back();
      Get.snackbar(
        'Sao lưu thành công',
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Không thể sao lưu',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _runRestore() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final message = await _backupService.restoreLatestBackup();
      if (Get.isRegistered<TaskController>()) {
        await Get.find<TaskController>().getTasks();
      }
      if (Get.isRegistered<ProjectController>()) {
        await Get.find<ProjectController>().getProjects();
      }
      Get.back();
      Get.snackbar(
        'Khôi phục thành công',
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Không thể khôi phục',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Tiếng Việt'),
                onTap: () => _updateLanguage('vi'),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('English'),
                onTap: () => _updateLanguage('en'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateLanguage(String code) async {
    Navigator.of(context).pop();
    await initializeDateFormatting(code);
    _settingsBox.write('language_code', code);
    Get.updateLocale(Locale(code));
    setState(() {
      _languageCode = code;
    });
  }
}
