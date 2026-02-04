import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_todo/services/theme_services.dart';
import 'package:task_todo/ui/pages/privacy_policy_page.dart';
import 'package:task_todo/ui/theme.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  final _settingsBox = GetStorage();
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
      appBar: AppBar(
        title: const Text('Tôi'),
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
        elevation: 0,
      ),
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
            backgroundImage: const AssetImage('images/person.jpeg'),
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
      onTap: () {
        Get.snackbar(
          'Sao lưu',
          'Tính năng đang được phát triển.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      },
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
