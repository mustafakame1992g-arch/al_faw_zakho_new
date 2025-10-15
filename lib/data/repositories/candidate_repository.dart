import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';

class CandidateRepository {
  static const String _boxName = 'candidates';
  final Uuid _uuid = Uuid();

  Future<Box<CandidateModel>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<CandidateModel>(
        _boxName,
        crashRecovery: true,
      );
    }
    return Hive.box<CandidateModel>(_boxName);
  }

  // الحصول على جميع المرشحين
  Future<List<CandidateModel>> getAllCandidates() async {
    try {
      final box = await _openBox();
      final candidates = box.values.toList();
      
      // ترتيب حسب آخر تحديث (الأحدث أولاً)
      candidates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      return candidates;
    } catch (e) {
      AnalyticsService.trackError('getAllCandidates', e, StackTrace.current);
      rethrow;
    }
  }

  // الحصول على مرشحين حسب المحافظة
  Future<List<CandidateModel>> getCandidatesByProvince(String province) async {
    try {
      final allCandidates = await getAllCandidates();
      return allCandidates
          .where((candidate) => candidate.province == province)
          .toList();
    } catch (e) {
      AnalyticsService.trackError('getCandidatesByProvince', e, StackTrace.current);
      rethrow;
    }
  }

  // البحث في المرشحين
  Future<List<CandidateModel>> searchCandidates(String query) async {
    try {
      final allCandidates = await getAllCandidates();
      final normalizedQuery = query.toLowerCase().trim();
      
      return allCandidates.where((candidate) {
        return candidate.nameAr.toLowerCase().contains(normalizedQuery) ||
               candidate.nameEn.toLowerCase().contains(normalizedQuery) ||
               candidate.nicknameAr.toLowerCase().contains(normalizedQuery) ||
               candidate.positionAr.toLowerCase().contains(normalizedQuery) ||
               candidate.province.toLowerCase().contains(normalizedQuery);
      }).toList();
    } catch (e) {
      AnalyticsService.trackError('searchCandidates', e, StackTrace.current);
      rethrow;
    }
  }

  // إضافة مرشح جديد
  Future<void> addCandidate(CandidateModel candidate) async {
    try {
      candidate.validate();
      final box = await _openBox();
      await box.put(candidate.id, candidate);
      
      AnalyticsService.trackEvent('candidate_added', parameters: {
        'candidate_id': candidate.id,
        'province': candidate.province,
      });
    } catch (e) {
      AnalyticsService.trackError('addCandidate', e, StackTrace.current);
      rethrow;
    }
  }

  // إضافة مجموعة من المرشحين
  Future<void> addCandidatesBatch(List<CandidateModel> candidates) async {
    try {
      final box = await _openBox();
      final Map<String, CandidateModel> candidatesMap = {};
      
      for (final candidate in candidates) {
        candidate.validate();
        candidatesMap[candidate.id] = candidate;
      }
      
      await box.putAll(candidatesMap);
      
      AnalyticsService.trackEvent('candidates_batch_added', parameters: {
        'count': candidates.length,
      });
    } catch (e) {
      AnalyticsService.trackError('addCandidatesBatch', e, StackTrace.current);
      rethrow;
    }
  }

  // تحديث مرشح
  Future<void> updateCandidate(CandidateModel candidate) async {
    try {
      candidate.validate();
      final updatedCandidate = candidate.copyWith(updatedAt: DateTime.now());
      final box = await _openBox();
      await box.put(updatedCandidate.id, updatedCandidate);
      
      AnalyticsService.trackEvent('candidate_updated', parameters: {
        'candidate_id': candidate.id,
      });
    } catch (e) {
      AnalyticsService.trackError('updateCandidate', e, StackTrace.current);
      rethrow;
    }
  }

  // حذف مرشح
  Future<void> deleteCandidate(String candidateId) async {
    try {
      final box = await _openBox();
      await box.delete(candidateId);
      
      AnalyticsService.trackEvent('candidate_deleted', parameters: {
        'candidate_id': candidateId,
      });
    } catch (e) {
      AnalyticsService.trackError('deleteCandidate', e, StackTrace.current);
      rethrow;
    }
  }

  // الحصول على مرشح بواسطة ID
  Future<CandidateModel?> getCandidateById(String id) async {
    try {
      final box = await _openBox();
      return box.get(id);
    } catch (e) {
      AnalyticsService.trackError('getCandidateById', e, StackTrace.current);
      return null;
    }
  }

  // حفظ صورة المرشح
  Future<String> saveCandidateImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final candidatesDir = Directory('${directory.path}/candidates');
      
      if (!await candidatesDir.exists()) {
        await candidatesDir.create(recursive: true);
      }
      
      final String newFileName = '${_uuid.v4()}.jpg';
      final String newPath = '${candidatesDir.path}/$newFileName';
      
      final savedFile = await imageFile.copy(newPath);
      
      AnalyticsService.trackEvent('candidate_image_saved', parameters: {
        'file_path': newPath,
      });
      
      return savedFile.path;
    } catch (e) {
      AnalyticsService.trackError('saveCandidateImage', e, StackTrace.current);
      rethrow;
    }
  }

  // الحصول على إحصائيات
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final candidates = await getAllCandidates();
      final provinces = <String, int>{};
      
      for (final candidate in candidates) {
        provinces.update(
          candidate.province,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      
      return {
        'total_candidates': candidates.length,
        'provinces_distribution': provinces,
        'with_images': candidates.where((c) => c.hasImage).length,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AnalyticsService.trackError('getStatistics', e, StackTrace.current);
      return {
        'total_candidates': 0,
        'provinces_distribution': {},
        'with_images': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  // تنظيف البيانات القديمة
  Future<void> cleanupOldData() async {
    try {
      final box = await _openBox();
      final candidates = box.values.toList();
      final cutoffDate = DateTime.now().subtract(const Duration(days: 365));
      
      final oldCandidates = candidates
          .where((candidate) => candidate.updatedAt.isBefore(cutoffDate))
          .map((candidate) => candidate.id)
          .toList();
      
      if (oldCandidates.isNotEmpty) {
        await box.deleteAll(oldCandidates);
        AnalyticsService.trackEvent('old_data_cleaned', parameters: {
          'cleaned_count': oldCandidates.length,
        });
      }
    } catch (e) {
      AnalyticsService.trackError('cleanupOldData', e, StackTrace.current);
    }
  }

  // التحقق من وجود بيانات
  Future<bool> hasData() async {
    try {
      final box = await _openBox();
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // مسح جميع البيانات (للتطوير فقط)
  Future<void> clearAll() async {
    try {
      final box = await _openBox();
      await box.clear();
      
      AnalyticsService.trackEvent('candidates_cleared_all');
    } catch (e) {
      AnalyticsService.trackError('clearAll', e, StackTrace.current);
      rethrow;
    }
  }
}