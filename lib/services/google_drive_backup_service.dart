import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:intl/intl.dart';
import 'package:task_todo/db/db_helper.dart';

class GoogleDriveBackupService {
  static const _backupFileName = 'task_todo_backup.json';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [DriveApi.driveAppdataScope],
  );

  Future<String> backupToDrive() async {
    final client = await _authenticate();
    final drive = DriveApi(client);

    final backupData = await DBHelper.exportData();
    final payload = {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      ...backupData,
    };
    final jsonString = jsonEncode(payload);
    final media = Media(Stream.value(utf8.encode(jsonString)), jsonString.length);

    final existingFile = await _findLatestBackupFile(drive);
    final file = File()
      ..name = _backupFileName
      ..parents = ['appDataFolder'];

    if (existingFile != null) {
      await drive.files.update(
        file,
        existingFile.id!,
        uploadMedia: media,
      );
    } else {
      await drive.files.create(
        file,
        uploadMedia: media,
      );
    }

    return 'Đã sao lưu lúc ${DateFormat('HH:mm, dd/MM/yyyy').format(DateTime.now())}';
  }

  Future<String> restoreLatestBackup() async {
    final client = await _authenticate();
    final drive = DriveApi(client);

    final backupFile = await _findLatestBackupFile(drive);
    if (backupFile?.id == null) {
      throw Exception('Không tìm thấy bản sao lưu trên Google Drive.');
    }

    final media = await drive.files.get(
      backupFile!.id!,
      downloadOptions: DownloadOptions.fullMedia,
    );

    if (media is! Media) {
      throw Exception('Không đọc được dữ liệu sao lưu từ Google Drive.');
    }

    final chunks = await media.stream.toList();
    final bytes = chunks.expand((chunk) => chunk).toList();
    final rawJson = utf8.decode(bytes);
    final dynamic decoded = jsonDecode(rawJson);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Định dạng dữ liệu sao lưu không hợp lệ.');
    }

    await DBHelper.restoreData(decoded);

    final modifiedAt = backupFile.modifiedTime?.toLocal();
    if (modifiedAt != null) {
      return 'Đã khôi phục bản sao lưu lúc ${DateFormat('HH:mm, dd/MM/yyyy').format(modifiedAt)}';
    }
    return 'Đã khôi phục thành công từ Google Drive.';
  }

  Future<File?> _findLatestBackupFile(DriveApi drive) async {
    final files = await drive.files.list(
      q: "name='$_backupFileName' and 'appDataFolder' in parents and trashed=false",
      spaces: 'appDataFolder',
      orderBy: 'modifiedTime desc',
      pageSize: 1,
      $fields: 'files(id,name,modifiedTime)',
    );

    if (files.files == null || files.files!.isEmpty) {
      return null;
    }
    return files.files!.first;
  }

  Future<dynamic> _authenticate() async {
    await _googleSignIn.signInSilently();
    if (_googleSignIn.currentUser == null) {
      await _googleSignIn.signIn();
    }

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Không thể đăng nhập Google. Vui lòng thử lại.');
    }
    return client;
  }
}
