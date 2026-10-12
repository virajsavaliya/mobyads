enum McqStatus {
  pendingReview,
  published,
  rejected,
  expired,
}

/// MCQ Question Domain & Pipeline Model
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final String category; // 'National News', 'International News', etc.
  final DateTime sourceDate;
  final String? sourceName;
  final String? sourceUrl;
  final McqStatus status;
  final DateTime expiresAt;

  Question({
    required this.id,
    required this.text,
    required this.options,
    this.correctOptionIndex = 0,
    this.explanation,
    required this.category,
    required this.sourceDate,
    this.sourceName,
    this.sourceUrl,
    this.status = McqStatus.published,
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ?? sourceDate.add(const Duration(hours: 48));

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Question copyWith({
    String? id,
    String? text,
    List<String>? options,
    int? correctOptionIndex,
    String? explanation,
    String? category,
    DateTime? sourceDate,
    String? sourceName,
    String? sourceUrl,
    McqStatus? status,
    DateTime? expiresAt,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      sourceDate: sourceDate ?? this.sourceDate,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctOptionIndex: json['correct_option_index'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      category: json['category'] as String? ?? 'National News',
      sourceDate: json['source_date'] != null
          ? DateTime.tryParse(json['source_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      status: McqStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => McqStatus.published,
      ),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'correct_option_index': correctOptionIndex,
        'explanation': explanation,
        'category': category,
        'source_date': sourceDate.toIso8601String(),
        'source_name': sourceName,
        'source_url': sourceUrl,
        'status': status.name,
        'expires_at': expiresAt.toIso8601String(),
      };
}

/// Initial Published Questions Pool
final List<Question> mockDailyQuizQuestions = [
  Question(
    id: 'q_01',
    category: 'National News',
    sourceName: 'PIB India',
    sourceUrl: 'https://pib.gov.in/PressReleasePage.aspx',
    sourceDate: DateTime.now(),
    text: 'Which renewable energy initiative was recently expanded across coastal states to boost offshore wind capacity?',
    options: [
      'National Offshore Wind Policy 2.0',
      'Solar Green Corridor Mission',
      'Blue Hydrogen Grid Project',
      'Coastal Clean Energy Drive',
    ],
    correctOptionIndex: 0,
    explanation: 'The Ministry of New & Renewable Energy expanded the Offshore Wind framework with revised viability gap funding.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_02',
    category: 'International News',
    sourceName: 'Reuters',
    sourceUrl: 'https://reuters.com/world',
    sourceDate: DateTime.now(),
    text: 'Which country recently signed a major bilateral clean tech trade accord with the European Union?',
    options: [
      'Japan',
      'India',
      'Canada',
      'South Korea',
    ],
    correctOptionIndex: 0,
    explanation: 'Japan and the EU formalized the Green Transformation Partnership targeting critical battery supply chains.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_03',
    category: 'National News',
    sourceName: 'The Hindu',
    sourceUrl: 'https://thehindu.com/news',
    sourceDate: DateTime.now(),
    text: 'What is the primary objective of the newly launched Unified Digital Health Interface (UDHI) update?',
    options: [
      'Interoperable electronic health records across hospitals',
      'Direct distribution of generic medicines via drones',
      'Mandatory biometric hospital check-ins',
      'Automated health insurance premium deductions',
    ],
    correctOptionIndex: 0,
    explanation: 'UDHI enables seamless consent-based sharing of longitudinal health records between private and public providers.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_04',
    category: 'International News',
    sourceName: 'BBC World',
    sourceUrl: 'https://bbc.com/news/world',
    sourceDate: DateTime.now(),
    text: 'Which global summit convened recently to negotiate global AI safety benchmarks and governance standards?',
    options: [
      'Global AI Safety & Ethics Forum',
      'World Quantum Computing Summit',
      'Cyber Future Dialogue 2026',
      'Geneva Digital Rights Assembly',
    ],
    correctOptionIndex: 0,
    explanation: 'Delegates from 40+ nations reached consensus on independent frontier model evaluation frameworks.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_05',
    category: 'National News',
    sourceName: 'Economic Times',
    sourceUrl: 'https://economictimes.indiatimes.com',
    sourceDate: DateTime.now(),
    text: 'The Reserve Bank of India (RBI) recently broadened the scope of Central Bank Digital Currency (CBDC) to include which new feature?',
    options: [
      'Offline peer-to-peer retail transactions',
      'Direct international remittance conversion',
      'Automated crypto-token trading',
      'Stock market margin settlement',
    ],
    correctOptionIndex: 0,
    explanation: 'Offline CBDC allows transactions in remote areas without active internet connectivity.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_06',
    category: 'International News',
    sourceName: 'Associated Press',
    sourceUrl: 'https://apnews.com',
    sourceDate: DateTime.now(),
    text: 'Which space agency recently unveiled the initial high-resolution imaging data from its deep-space solar telescope?',
    options: [
      'NASA & ESA Consortium',
      'JAXA',
      'ISRO Space Applications Centre',
      'Canadian Space Agency',
    ],
    correctOptionIndex: 0,
    explanation: 'The joint Solar Orbiter telescope captured unprecedented corona dynamic turbulence patterns.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_07',
    category: 'National News',
    sourceName: 'Indian Express',
    sourceUrl: 'https://indianexpress.com',
    sourceDate: DateTime.now(),
    text: 'Which Indian railway corridor recently completed full electrification and safety signaling upgrades under Mission Raftaar?',
    options: [
      'Delhi - Mumbai Semi-High Speed Sector',
      'Kolkata - Chennai Coastal Link',
      'Bengaluru - Hyderabad Express Line',
      'Ahmedabad - Jaipur Western Route',
    ],
    correctOptionIndex: 0,
    explanation: 'The 1,400 km sector received Kavach 4.0 automatic train protection system certification.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_08',
    category: 'International News',
    sourceName: 'Al Jazeera',
    sourceUrl: 'https://aljazeera.com/news',
    sourceDate: DateTime.now(),
    text: 'Which multilateral treaty for high-seas marine biodiversity protection recently reached the critical threshold of member ratifications?',
    options: [
      'High Seas Biodiversity Treaty (BBNJ)',
      'Oceans Climate Action Agreement',
      'Antarctic Conservation Protocol',
      'Pacific Fishery Protection Charter',
    ],
    correctOptionIndex: 0,
    explanation: 'The landmark UN BBNJ agreement enters into legal force to protect areas beyond national jurisdiction.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_09',
    category: 'National News',
    sourceName: 'Business Standard',
    sourceUrl: 'https://business-standard.com',
    sourceDate: DateTime.now(),
    text: 'India recently achieved a record milestone in agricultural exports led primarily by which high-value commodity?',
    options: [
      'Basmati rice and processed spices',
      'Organic cotton and silk yarn',
      'Raw tea and artisanal coffee beans',
      'Wheat and oilseeds',
    ],
    correctOptionIndex: 0,
    explanation: 'Export surges were driven by strong demand across Middle Eastern and European agricultural markets.',
    status: McqStatus.published,
  ),
  Question(
    id: 'q_10',
    category: 'International News',
    sourceName: 'Financial Times',
    sourceUrl: 'https://ft.com',
    sourceDate: DateTime.now(),
    text: 'Which semiconductor manufacturing hub announced a multi-billion dollar expansion for 2-nanometer wafer fabrication?',
    options: [
      'Taiwan Semiconductor Hub',
      'European Microelectronics Valley',
      'Arizona Silicon Desert Corridor',
      'Singapore Microchip Innovation Park',
    ],
    correctOptionIndex: 0,
    explanation: 'The facility expansion will support next-generation ultra-dense AI and mobile microchips.',
    status: McqStatus.published,
  ),
];
