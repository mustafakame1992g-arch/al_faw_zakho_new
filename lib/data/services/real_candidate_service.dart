import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/repositories/candidate_repository.dart';
import 'package:al_faw_zakho/data/static/iraqi_provinces.dart';
import 'dart:developer' as developer;

class RealCandidateService {
  final CandidateRepository _repository = CandidateRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // إدخال مرشحين حقيقيين مثال
  Future<void> insertRealCandidates() async {
    try {
      const realCandidates = [
        {
          'id': 'real_1',
          'nameAr': 'أحمد محمد علي',
          'nameEn': 'Ahmed Mohammed Ali',
          'nicknameAr': 'أبو محمد',
          'nicknameEn': 'Abu Mohammed',
          'positionAr': 'مرشح عن بغداد',
          'positionEn': 'Candidate for Baghdad',
          'bioAr':
              'خريج كلية الهندسة - جامعة بغداد. ناشط سياسي منذ 2010. عضو في تجمع الفاو زاخو منذ تأسيسه. له العديد من المساهمات في تطوير المنطقة.',
          'bioEn':
              'Engineering graduate - University of Baghdad. Political activist since 2010. Member of Al-Faw Zakhо Gathering since its establishment.',
          'imagePath': 'assets/images/candidates/ahmed.jpg',
          'phoneNumber': '+9647701234567',
          'province': 'بغداد',
        },
        {
          'id': 'real_2',
          'nameAr': 'سارة عبد الكريم',
          'nameEn': 'Sara Abdul Kareem',
          'nicknameAr': 'أم علي',
          'nicknameEn': 'Umm Ali',
          'positionAr': 'مرشحة عن أربيل',
          'positionEn': 'Candidate for Erbil',
          'bioAr':
              'حاصلة على ماجستير في القانون الدولي. ناشطة في مجال حقوق المرأة والطفل. عضو مؤسس في جمعية تمكين المرأة العراقية.',
          'bioEn':
              'Holds a masters degree in International Law. Activist in women and children rights.',
          'imagePath': 'assets/images/candidates/sara.jpg',
          'phoneNumber': '+9647509876543',
          'province': 'أربيل',
        },
        {
          'id': 'real_3',
          'nameAr': 'حسن عبد الله',
          'nameEn': 'Hassan Abdullah',
          'nicknameAr': 'أبو علي',
          'nicknameEn': 'Abu Ali',
          'positionAr': 'مرشح عن البصرة',
          'positionEn': 'Candidate for Basra',
          'bioAr':
              'مهندس نفط بخبرة 15 سنة. رئيس لجنة الطاقة في المحافظة. حاصل على عدة جوائز في مجال تطوير القطاع النفطي.',
          'bioEn':
              'Petroleum engineer with 15 years experience. Head of Energy Committee in the province.',
          'imagePath': 'assets/images/candidates/hassan.jpg',
          'phoneNumber': '+9647812345678',
          'province': 'البصرة',
        },
        {
          'id': 'real_4',
          'nameAr': 'ليلى مصطفى',
          'nameEn': 'Layla Mustafa',
          'nicknameAr': 'أم حسين',
          'nicknameEn': 'Umm Hussein',
          'positionAr': 'مرشحة عن نينوى',
          'positionEn': 'Candidate for Nineveh',
          'bioAr':
              'طبيبة أطفال ومديرة مستشفى سابقاً. ناشطة في مجال الصحة المجتمعية. حاصلة على جوائز تقديرية لجهودها أثناء جائحة كورونا.',
          'bioEn':
              'Pediatrician and former hospital director. Community health activist.',
          'imagePath': 'assets/images/candidates/layla.jpg',
          'phoneNumber': '+9647911223344',
          'province': 'نينوى',
        },
      ];

      final candidates =
          realCandidates.map((data) => CandidateModel.fromJson(data)).toList();

      await _repository.addCandidatesBatch(candidates);

      developer.log('✅ تم إدخال ${candidates.length} مرشح حقيقي بنجاح');
    } catch (e) {
      developer.log('❌ فشل إدخال المرشحين الحقيقيين: $e');
      rethrow;
    }
  }

  // اختيار صورة من المعرض
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        return await _repository.saveCandidateImage(file);
      }
      return null;
    } catch (e) {
      developer.log('❌ فشل اختيار الصورة: $e');
      rethrow;
    }
  }

  // التقاط صورة بالكاميرا
  Future<String?> captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        return await _repository.saveCandidateImage(file);
      }
      return null;
    } catch (e) {
      developer.log('❌ فشل التقاط الصورة: $e');
      rethrow;
    }
  }

  // إنشاء مرشح جديد
  Future<CandidateModel> createNewCandidate({
    required String nameAr,
    required String nameEn,
    required String nicknameAr,
    required String nicknameEn,
    required String positionAr,
    required String positionEn,
    required String bioAr,
    required String bioEn,
    required String phoneNumber,
    required String province,
    String? imagePath,
  }) async {
    try {
      final candidate = CandidateModel(
        id: 'candidate_${DateTime.now().millisecondsSinceEpoch}',
        nameAr: nameAr,
        nameEn: nameEn,
        nicknameAr: nicknameAr,
        nicknameEn: nicknameEn,
        positionAr: positionAr,
        positionEn: positionEn,
        bioAr: bioAr,
        bioEn: bioEn,
        imagePath: imagePath ?? '',
        phoneNumber: phoneNumber,
        province: province,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addCandidate(candidate);
      return candidate;
    } catch (e) {
      developer.log('❌ فشل إنشاء المرشح: $e');
      rethrow;
    }
  }

  // الحصول على قائمة المحافظات للاستخدام في الواجهات
  List<String> getAvailableProvinces() {
    return IraqiProvinces.allProvinces;
  }

  // التحقق من صحة المحافظة
  bool isValidProvince(String province) {
    return IraqiProvinces.isValidProvince(province);
  }

  // الحصول على جميع المرشحين
  Future<List<CandidateModel>> getAllCandidates() async {
    return await _repository.getAllCandidates();
  }

  // الحصول على مرشحين حسب المحافظة
  Future<List<CandidateModel>> getCandidatesByProvince(String province) async {
    return await _repository.getCandidatesByProvince(province);
  }

  // البحث في المرشحين
  Future<List<CandidateModel>> searchCandidates(String query) async {
    return await _repository.searchCandidates(query);
  }

  // الحصول على إحصائيات
  Future<Map<String, dynamic>> getStatistics() async {
    return await _repository.getStatistics();
  }
}
