// processed_data.dart
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';

class ProcessedData {
  ProcessedData({
    required this.candidates,
    required this.faqs,
    required this.news,
  });
  final List<CandidateModel> candidates;
  final List<FaqModel> faqs;
  final List<NewsModel> news;
}
