class QuestionModel {
  final String id;
  final String text;
  final int orderIndex;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.orderIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      orderIndex: json['order_index'] ?? 0,
    );
  }
}

class SectionModel {
  final String id;
  final String title;
  final int orderIndex;
  final List<QuestionModel> questions;

  const SectionModel({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.questions,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      orderIndex: json['order_index'] ?? 0,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuestionModel.fromJson(e))
          .toList(),
    );
  }
}

class AnswerModel {
  final String questionId;
  final bool answerValue;

  const AnswerModel({
    required this.questionId,
    required this.answerValue,
  });

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'answer_value': answerValue,
      };
}

class QuestionnaireResponseModel {
  final String id;
  final String sessionId;
  final int totalYesCount;
  final String outcome;
  final String? filledByName;
  final String? submittedAt;

  const QuestionnaireResponseModel({
    required this.id,
    required this.sessionId,
    required this.totalYesCount,
    required this.outcome,
    this.filledByName,
    this.submittedAt,
  });

  factory QuestionnaireResponseModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponseModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      totalYesCount: json['total_yes_count'] ?? 0,
      outcome: json['outcome']?.toString() ?? '',
      filledByName: json['filled_by_name']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
    );
  }

  bool get isPassed => outcome == 'pass';
  bool get isReferred => outcome == 'refer';
}