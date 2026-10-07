import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart' as csv_pkg;
import 'package:excel_plus/excel_plus.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../features/memorials/data/models/memorial_model.dart';
import '../features/memorials/domain/entities/memorial.dart';
import '../utils/logger.dart';
import 'local_database_service.dart';

/// Result summary returned after importing a backup file.
class ImportResult {
  const ImportResult({
    required this.totalRows,
    required this.importedCount,
    required this.updatedCount,
    required this.failedCount,
    this.errorMessage,
  });

  final int totalRows;
  final int importedCount;
  final int updatedCount;
  final int failedCount;
  final String? errorMessage;

  bool get isSuccess =>
      errorMessage == null && (importedCount > 0 || updatedCount > 0);
}

/// Service handling data export to CSV (Google Sheets compatible), Excel (.xlsx),
/// and JSON, as well as universal import/restoration.
class BackupRestoreService {
  BackupRestoreService._();
  static final BackupRestoreService instance = BackupRestoreService._();

  static const List<String> _headers = [
    'ID',
    'Full Name',
    'Arabic / Native Name',
    'Gender',
    'Category',
    'Relationship',
    'Custom Relationship',
    'Date of Birth',
    'Birth Year',
    'Date of Death',
    'Passing Year',
    'Age',
    'Cemetery Name',
    'Cemetery Area',
    'Grave Plot',
    'Latitude',
    'Longitude',
    'Map Style',
    'Profile Photo URL',
    'Grave Photo URL',
    'Notes / Dua',
    'Favorite',
    'Created At',
  ];

  // ---------------------------------------------------------------------------
  // EXPORT
  // ---------------------------------------------------------------------------

  /// Fetches all memorials and exports them as a UTF-8 CSV file, then prompts
  /// the system share/save dialog (easily opened in Google Sheets or Excel).
  Future<bool> exportToCsv() async {
    try {
      final rawMemorials =
          await LocalDatabaseService.instance.getAllMemorialsRaw();
      final memorials =
          rawMemorials.map((m) => MemorialModel.fromMap(m)).toList();

      final List<List<dynamic>> rows = [];
      // Header row
      rows.add(_headers);

      // Data rows
      for (final m in memorials) {
        rows.add(_memorialToRow(m));
      }

      // Convert to CSV string with UTF-8 BOM so Excel & Google Sheets correctly decode non-ASCII (Arabic, Bengali)
      final csvContent = csv_pkg.csv.encode(rows);
      final utf8BomWithCsv = '\uFEFF$csvContent';

      final tempDir = await getTemporaryDirectory();
      final timestamp = _formatTimestamp(DateTime.now());
      final fileName = 'memorial_keeper_$timestamp.csv';
      final filePath = p.join(tempDir.path, fileName);

      final file = File(filePath);
      await file.writeAsString(utf8BomWithCsv, encoding: utf8);

      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              name: fileName,
              mimeType: 'text/csv',
            ),
          ],
          subject: fileName,
        ),
      );

      return shareResult.status != ShareResultStatus.dismissed;
    } catch (e, stack) {
      AppLogger.error('Failed to export CSV: $e', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Exports all memorials as a formatted Microsoft Excel (.xlsx) workbook,
  /// then prompts the system share dialog.
  Future<bool> exportToExcel() async {
    try {
      final rawMemorials =
          await LocalDatabaseService.instance.getAllMemorialsRaw();
      final memorials =
          rawMemorials.map((m) => MemorialModel.fromMap(m)).toList();

      final excel = Excel.createExcel();
      // Rename default sheet
      const sheetName = 'Memorials';
      final sheet = excel[sheetName];
      excel.setDefaultSheet(sheetName);

      // Append header row
      sheet.appendRow(_headers.map((h) => TextCellValue(h)).toList());

      // Append data rows
      for (final m in memorials) {
        final rowData = _memorialToRow(m);
        final cells = rowData.map((val) {
          if (val == null) return TextCellValue('');
          if (val is int) return IntCellValue(val);
          if (val is double) return DoubleCellValue(val);
          return TextCellValue(val.toString());
        }).toList();
        sheet.appendRow(cells);
      }

      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Excel generation returned empty bytes');
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = _formatTimestamp(DateTime.now());
      final fileName = 'memorial_keeper_$timestamp.xlsx';
      final filePath = p.join(tempDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              name: fileName,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
          subject: fileName,
        ),
      );

      return shareResult.status != ShareResultStatus.dismissed;
    } catch (e, stack) {
      AppLogger.error('Failed to export Excel: $e',
          error: e, stackTrace: stack);
      return false;
    }
  }

  /// Exports full local database as a structured JSON file.
  Future<bool> exportToJson() async {
    try {
      final rawMemorials =
          await LocalDatabaseService.instance.getAllMemorialsRaw();

      final exportPayload = {
        'version': 1,
        'appName': 'Memorial Keeper',
        'exportedAt': DateTime.now().toIso8601String(),
        'totalCount': rawMemorials.length,
        'memorials': rawMemorials,
      };

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(exportPayload);

      final tempDir = await getTemporaryDirectory();
      final timestamp = _formatTimestamp(DateTime.now());
      final fileName = 'memorial_keeper_backup_$timestamp.json';
      final filePath = p.join(tempDir.path, fileName);

      final file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);

      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              name: fileName,
              mimeType: 'application/json',
            ),
          ],
          subject: fileName,
        ),
      );

      return shareResult.status != ShareResultStatus.dismissed;
    } catch (e, stack) {
      AppLogger.error('Failed to export JSON: $e', error: e, stackTrace: stack);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // IMPORT / RESTORE
  // ---------------------------------------------------------------------------

  /// Opens the native document/file picker to let the user select a `.csv`,
  /// `.xlsx`, or `.json` file, parses the records, and inserts/updates them in SQLite.
  Future<ImportResult?> pickAndRestoreFile() async {
    try {
      final pickResult = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'json'],
      );

      if (pickResult == null || pickResult.files.isEmpty) {
        return null; // User cancelled
      }

      final pickedFile = pickResult.files.first;
      final filePath = pickedFile.path;
      if (filePath == null) {
        return const ImportResult(
          totalRows: 0,
          importedCount: 0,
          updatedCount: 0,
          failedCount: 0,
          errorMessage: 'Could not access the selected file.',
        );
      }

      final file = File(filePath);
      final ext = p.extension(filePath).toLowerCase();

      if (ext == '.csv') {
        return await _importCsv(file);
      } else if (ext == '.xlsx') {
        return await _importExcel(file);
      } else if (ext == '.json') {
        return await _importJson(file);
      } else {
        return const ImportResult(
          totalRows: 0,
          importedCount: 0,
          updatedCount: 0,
          failedCount: 0,
          errorMessage:
              'Unsupported file format. Please choose .csv, .xlsx, or .json.',
        );
      }
    } catch (e, stack) {
      AppLogger.error('Restore error: $e', error: e, stackTrace: stack);
      return ImportResult(
        totalRows: 0,
        importedCount: 0,
        updatedCount: 0,
        failedCount: 0,
        errorMessage: 'Failed to process file: $e',
      );
    }
  }

  Future<ImportResult> _importCsv(File file) async {
    final rawString = await file.readAsString(encoding: utf8);
    // Strip optional UTF-8 BOM
    final cleanString =
        rawString.startsWith('\uFEFF') ? rawString.substring(1) : rawString;

    final List<List<dynamic>> rows = csv_pkg.csv.decode(cleanString);

    if (rows.isEmpty) {
      return const ImportResult(
        totalRows: 0,
        importedCount: 0,
        updatedCount: 0,
        failedCount: 0,
        errorMessage: 'CSV file is empty.',
      );
    }

    final headerRow =
        rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    final dataRows = rows.skip(1).toList();

    return await _saveParsedRows(headerRow, dataRows);
  }

  Future<ImportResult> _importExcel(File file) async {
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      return const ImportResult(
        totalRows: 0,
        importedCount: 0,
        updatedCount: 0,
        failedCount: 0,
        errorMessage: 'Excel file contains no worksheets.',
      );
    }

    final sheet = excel.tables[excel.tables.keys.first]!;
    if (sheet.rows.isEmpty) {
      return const ImportResult(
        totalRows: 0,
        importedCount: 0,
        updatedCount: 0,
        failedCount: 0,
        errorMessage: 'Worksheet is empty.',
      );
    }

    final headerRow = sheet.rows.first
        .map((cell) => cell?.value?.toString().trim().toLowerCase() ?? '')
        .toList();

    final dataRows = sheet.rows.skip(1).map((row) {
      return row.map((cell) => cell?.value?.toString() ?? '').toList();
    }).toList();

    return await _saveParsedRows(headerRow, dataRows);
  }

  Future<ImportResult> _importJson(File file) async {
    final content = await file.readAsString();
    final dynamic decoded = jsonDecode(content);

    List<dynamic> list;
    if (decoded is Map && decoded['memorials'] is List) {
      list = decoded['memorials'] as List;
    } else if (decoded is List) {
      list = decoded;
    } else {
      return const ImportResult(
        totalRows: 0,
        importedCount: 0,
        updatedCount: 0,
        failedCount: 0,
        errorMessage: 'Invalid JSON backup format.',
      );
    }

    int imported = 0;
    int updated = 0;
    int failed = 0;

    for (final item in list) {
      try {
        if (item is Map<String, dynamic>) {
          final model = MemorialModel.fromMap(item);
          final existing =
              await LocalDatabaseService.instance.getMemorialById(model.id);
          await LocalDatabaseService.instance.insertMemorial(model.toMap());
          if (existing != null) {
            updated++;
          } else {
            imported++;
          }
        }
      } catch (_) {
        failed++;
      }
    }

    return ImportResult(
      totalRows: list.length,
      importedCount: imported,
      updatedCount: updated,
      failedCount: failed,
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Future<ImportResult> _saveParsedRows(
    List<String> headers,
    List<List<dynamic>> dataRows,
  ) async {
    int imported = 0;
    int updated = 0;
    int failed = 0;

    // Map header names to column index
    int findCol(List<String> synonyms) {
      for (final s in synonyms) {
        final idx = headers.indexOf(s.toLowerCase());
        if (idx != -1) return idx;
      }
      return -1;
    }

    final idCol = findCol(['id']);
    final nameCol = findCol(['full name', 'name', 'fullname']);
    final arabicCol =
        findCol(['arabic / native name', 'arabic name', 'arabicname']);
    final genderCol = findCol(['gender', 'sex']);
    final categoryCol = findCol(['category']);
    final relationCol = findCol(['relationship', 'relation']);
    final customRelationCol =
        findCol(['custom relationship', 'custom relation']);
    final dobCol = findCol(['date of birth', 'dob', 'birth date']);
    final bYearCol = findCol(['birth year']);
    final dodCol =
        findCol(['date of death', 'dod', 'death date', 'passing date']);
    final pYearCol = findCol(['passing year', 'death year']);
    final ageCol = findCol(['age']);
    final cemeteryCol = findCol(['cemetery name', 'cemetery', 'graveyard']);
    final areaCol = findCol(['cemetery area', 'area', 'location']);
    final plotCol = findCol(['grave plot', 'plot', 'grave number']);
    final latCol = findCol(['latitude', 'lat']);
    final lngCol = findCol(['longitude', 'lng', 'long']);
    final mapStyleCol = findCol(['map style']);
    final profilePhotoCol =
        findCol(['profile photo url', 'profile photo', 'avatar']);
    final gravePhotoCol = findCol(['grave photo url', 'grave photo']);
    final notesCol = findCol(['notes / dua', 'notes', 'dua']);
    final favCol = findCol(['favorite', 'is favorite']);

    if (nameCol == -1) {
      return const ImportResult(
        totalRows: 0,
        importedCount: 0,
        updatedCount: 0,
        failedCount: 0,
        errorMessage:
            'Could not find a "Full Name" or "Name" column in this file.',
      );
    }

    for (final row in dataRows) {
      try {
        String getVal(int col) {
          if (col == -1 || col >= row.length) return '';
          return row[col]?.toString().trim() ?? '';
        }

        final name = getVal(nameCol);
        if (name.isEmpty) continue; // Skip blank rows

        String id = getVal(idCol);
        if (id.isEmpty) {
          id = const Uuid().v4();
        }

        final gender =
            getVal(genderCol).toLowerCase() == 'female' ? 'female' : 'male';
        final category =
            getVal(categoryCol).toLowerCase() == 'others' ? 'others' : 'family';
        final relation = getVal(relationCol).isNotEmpty
            ? getVal(relationCol).toLowerCase()
            : 'other';

        final dobStr = getVal(dobCol);
        final dodStr = getVal(dodCol);

        final DateTime? dob = DateTime.tryParse(dobStr);
        final DateTime? dod = DateTime.tryParse(dodStr);

        final int? bYear = int.tryParse(getVal(bYearCol)) ?? dob?.year;
        final int? pYear = int.tryParse(getVal(pYearCol)) ?? dod?.year;
        int? age = int.tryParse(getVal(ageCol));
        if (age == null && bYear != null && pYear != null && pYear >= bYear) {
          age = pYear - bYear;
        }

        final lat = double.tryParse(getVal(latCol));
        final lng = double.tryParse(getVal(lngCol));

        final favVal = getVal(favCol).toLowerCase();
        final bool isFav = favVal == 'yes' || favVal == '1' || favVal == 'true';

        final existingMap =
            await LocalDatabaseService.instance.getMemorialById(id);

        DateTime createdAt = DateTime.now();
        if (existingMap != null && existingMap['createdAt'] != null) {
          final parsedCreated =
              DateTime.tryParse(existingMap['createdAt'].toString());
          if (parsedCreated != null) {
            createdAt = parsedCreated;
          }
        }

        final memorial = Memorial(
          id: id,
          fullName: name,
          arabicName: getVal(arabicCol).isEmpty ? null : getVal(arabicCol),
          gender: gender,
          category: category,
          relationship: relation,
          customRelation: getVal(customRelationCol).isEmpty
              ? null
              : getVal(customRelationCol),
          dateOfBirth: dob,
          birthYear: bYear,
          dateOfDeath: dod,
          passingYear: pYear,
          age: age,
          cemeteryName:
              getVal(cemeteryCol).isEmpty ? null : getVal(cemeteryCol),
          cemeteryArea: getVal(areaCol).isEmpty ? null : getVal(areaCol),
          gravePlot: getVal(plotCol).isEmpty ? null : getVal(plotCol),
          latitude: lat,
          longitude: lng,
          mapStyle:
              getVal(mapStyleCol).isEmpty ? 'streets' : getVal(mapStyleCol),
          profilePhotoPath:
              getVal(profilePhotoCol).isEmpty ? null : getVal(profilePhotoCol),
          gravePhotoPath:
              getVal(gravePhotoCol).isEmpty ? null : getVal(gravePhotoCol),
          notesOrDua: getVal(notesCol).isEmpty ? null : getVal(notesCol),
          isFavorite: isFav,
          syncStatus: 'pending_update',
          createdAt: createdAt,
          updatedAt: DateTime.now(),
        );

        final model = MemorialModel.fromEntity(memorial);
        await LocalDatabaseService.instance.insertMemorial(model.toMap());

        if (existingMap != null) {
          updated++;
        } else {
          imported++;
        }
      } catch (e) {
        failed++;
      }
    }

    return ImportResult(
      totalRows: dataRows.length,
      importedCount: imported,
      updatedCount: updated,
      failedCount: failed,
    );
  }

  List<dynamic> _memorialToRow(Memorial m) {
    return [
      m.id,
      m.fullName,
      m.arabicName ?? '',
      m.gender,
      m.category,
      m.relationship,
      m.customRelation ?? '',
      if (m.dateOfBirth != null) _formatDate(m.dateOfBirth!) else '',
      m.birthYear ?? '',
      if (m.dateOfDeath != null) _formatDate(m.dateOfDeath!) else '',
      m.passingYear ?? '',
      m.age ?? '',
      m.cemeteryName ?? '',
      m.cemeteryArea ?? '',
      m.gravePlot ?? '',
      m.latitude ?? '',
      m.longitude ?? '',
      m.mapStyle,
      m.profilePhotoPath ?? '',
      m.gravePhotoPath ?? '',
      m.notesOrDua ?? '',
      if (m.isFavorite) 'Yes' else 'No',
      m.createdAt.toIso8601String(),
    ];
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _formatTimestamp(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final h = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$y$m${day}_$h$min';
  }
}
