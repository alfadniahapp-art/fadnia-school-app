import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'storage_service.dart';

class BackupService {
  static Future<void> exportBackup() async {
    final json = await StorageService.exportAll();
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/mulla_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)],
        text: 'نسخة احتياطية لنظام Mulla');
  }

  static Future<bool> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return false;
    final file = File(result.files.first.path!);
    final content = await file.readAsString();
    return await StorageService.importAll(content);
  }
}
