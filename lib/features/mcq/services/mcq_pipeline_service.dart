import 'dart:math';
import '../models/question_model.dart';

/// News-to-MCQ Ingestion and Lifecycle Service
class McqPipelineService {
  /// Candidate news headlines template for scheduled ingestion job
  static final List<Map<String, dynamic>> _candidateNewsHeadlines = [
    {
      'headline': 'ISRO Announces Gaganyaan Uncrewed Test Flight Window with AI Humanoid Robot Vyommitra',
      'source': 'ISRO / PIB',
      'url': 'https://isro.gov.in/gaganyaan',
      'category': 'National News',
      'question': 'What is the name of the AI-powered female humanoid robot developed for the Gaganyaan test mission?',
      'options': ['Vyommitra', 'GaganShakti', 'Pragyan-2', 'MitraSat'],
      'correctIndex': 0,
      'explanation': 'Vyommitra was engineered by ISRO to simulate human vital parameters and cabin environment telemetry during uncrewed spaceflights.',
    },
    {
      'headline': 'Global Climate Finance Framework Ratified at COP Summit with \$300B Annual Target',
      'source': 'UN Climate Action',
      'url': 'https://unfccc.int/cop',
      'category': 'International News',
      'question': 'What is the primary annual funding target established in the newly ratified New Collective Quantified Goal (NCQG)?',
      'options': ['\$300 Billion annually', '\$100 Billion annually', '\$500 Billion annually', '\$1 Trillion annually'],
      'correctIndex': 0,
      'explanation': 'The NCQG replaces the prior \$100B pledge to accelerate developing nations energy transition and climate adaptation.',
    },
    {
      'headline': 'India Expands UPI Global Acceptance to 5 New Southeast Asian Nations',
      'source': 'NPCI International',
      'url': 'https://npci.org.in',
      'category': 'National News',
      'question': 'Which payment interface expansion allows Indian travelers to make direct QR code payments across ASEAN partner countries?',
      'options': ['Unified Payments Interface (UPI)', 'National Electronic Funds Transfer', 'IMPS Global', 'RuPay CrossBorder'],
      'correctIndex': 0,
      'explanation': 'NPCI International has linked UPI QR interoperability with central banks across Singapore, UAE, France, and neighboring partners.',
    },
    {
      'headline': 'World Health Organization Approves Next-Gen Malaria Vaccine with 77% Efficacy',
      'source': 'WHO Press',
      'url': 'https://who.int/malaria',
      'category': 'International News',
      'question': 'Which next-generation malaria vaccine manufactured in high volumes was cleared for global deployment?',
      'options': ['R21/Matrix-M', 'Mosquirix RTS,S', 'BioMalaria-1', 'VaxMal-24'],
      'correctIndex': 0,
      'explanation': 'R21/Matrix-M developed with Oxford University and Serum Institute delivers over 75% efficacy in endemic regions.',
    },
    {
      'headline': 'Government Clears PM-eBus Sewa Fund for 10,000 Electric City Buses',
      'source': 'Ministry of Housing & Urban Affairs',
      'url': 'https://mohua.gov.in',
      'category': 'National News',
      'question': 'What is the primary objective of the PM-eBus Sewa initiative in tier-2 and tier-3 Indian cities?',
      'options': ['Deploying 10,000 electric buses on PPP model', 'Electrifying interstate truck highways', 'Converting auto-rickshaws to CNG', 'Subsidizing solar roof installations'],
      'correctIndex': 0,
      'explanation': 'PM-eBus Sewa augments green urban public transport with dedicated charging infrastructure support.',
    },
  ];

  /// Simulates Fetch & Auto-Drafting from latest news headlines
  Future<List<Question>> fetchAndDraftHeadlines() async {
    // Simulate API / LLM drafting delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final random = Random();
    final now = DateTime.now();

    return _candidateNewsHeadlines.map((item) {
      final id = 'draft_${now.millisecondsSinceEpoch}_${random.nextInt(9999)}';
      return Question(
        id: id,
        text: item['question'] as String,
        options: List<String>.from(item['options'] as List),
        correctOptionIndex: item['correctIndex'] as int,
        explanation: item['explanation'] as String,
        category: item['category'] as String,
        sourceName: item['source'] as String,
        sourceUrl: item['url'] as String,
        sourceDate: now,
        status: McqStatus.pendingReview,
        expiresAt: now.add(const Duration(hours: 48)),
      );
    }).toList();
  }

  /// Evaluates whether questions in a list have expired (> 48h)
  List<Question> applyExpirationFilter(List<Question> questions) {
    final now = DateTime.now();
    return questions.map((q) {
      if (now.isAfter(q.expiresAt) && q.status == McqStatus.published) {
        return q.copyWith(status: McqStatus.expired);
      }
      return q;
    }).toList();
  }
}
