import 'package:flutter_test/flutter_test.dart';
import 'package:mobyads/features/mcq/models/question_model.dart';
import 'package:mobyads/features/mcq/services/mcq_pipeline_service.dart';

void main() {
  group('MCQ Pipeline Tests', () {
    test('Question model creates and serializes properly', () {
      final q = Question(
        id: 'test_1',
        text: 'What is the capital of France?',
        options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
        correctOptionIndex: 2,
        category: 'International News',
        sourceDate: DateTime.now(),
        status: McqStatus.published,
      );

      expect(q.isExpired, isFalse);
      expect(q.status, McqStatus.published);
      expect(q.options[q.correctOptionIndex], 'Paris');
    });

    test('Pipeline Ingestion generates candidate questions', () async {
      final service = McqPipelineService();
      final drafts = await service.fetchAndDraftHeadlines();

      expect(drafts.isNotEmpty, isTrue);
      for (final draft in drafts) {
        expect(draft.status, McqStatus.pendingReview);
        expect(draft.options.length, 4);
        expect(draft.correctOptionIndex, inInclusiveRange(0, 3));
      }
    });
  });
}
