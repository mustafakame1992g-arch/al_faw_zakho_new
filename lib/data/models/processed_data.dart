// processed_data.dart
import '../models/candidate_model.dart';
import '../models/faq_model.dart';
import '../models/news_model.dart';

class ProcessedData {
  final List<CandidateModel> candidates;
  final List<FaqModel> faqs;
  final List<NewsModel> news;
  ProcessedData({required this.candidates, required this.faqs, required this.news});
}