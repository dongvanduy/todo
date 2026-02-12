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
              title: Text('me_title'.tr),
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
            Text('settings'.tr, style: titleStyle),
            const SizedBox(height: 8),
            _buildDarkModeTile(),
            _buildLanguageTile(),
            _buildPrivacyTile(),
            _buildBackupTile(),
            const SizedBox(height: 20),
            Text('support'.tr, style: titleStyle),
            const SizedBox(height: 8),
            _buildSupportTile(
              icon: Icons.help_outline,
              title: 'help_center'.tr,
              subtitle: 'help_center_subtitle'.tr,
            ),
            _buildSupportTile(
              icon: Icons.star_outline,
              title: 'rate_app'.tr,
              subtitle: 'rate_app_subtitle'.tr,
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
                  'account_settings_subtitle'.tr,
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
      title: Text('dark_mode'.tr),
      subtitle: Text('dark_mode_subtitle'.tr),
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
      title: Text('language'.tr),
      subtitle: Text(_languageCode == 'vi' ? 'language_vi'.tr : 'language_en'.tr),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showLanguageSheet,
    );
  }

  Widget _buildPrivacyTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.privacy_tip_outlined, color: primaryClr),
      title: Text('privacy'.tr),
      subtitle: Text('privacy_subtitle'.tr),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.to(() => const PrivacyPolicyPage()),
    );
  }

  Widget _buildBackupTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.cloud_upload_outlined, color: primaryClr),
      title: Text('drive_backup'.tr),
      subtitle: Text('drive_backup_subtitle'.tr),
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
          'feature_updating'.tr,
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
              Text('drive_sheet_title'.tr, style: titleStyle),
              const SizedBox(height: 8),
              Text(
                'drive_sheet_description'.tr,
                style: bodyStyle.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_upload_rounded, color: primaryClr),
                title: Text('backup_now'.tr),
                subtitle: Text('backup_now_subtitle'.tr),
                onTap: () {
                  Get.back();
                  _runBackup();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.restore_rounded, color: primaryClr),
                title: Text('restore_from_drive'.tr),
                subtitle: Text('restore_from_drive_subtitle'.tr),
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
        'backup_success'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'backup_failed'.tr,
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
        'restore_success'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'restore_failed'.tr,
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
                title: Text('language_vi'.tr),
                onTap: () => _updateLanguage('vi'),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text('language_en'.tr),
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
