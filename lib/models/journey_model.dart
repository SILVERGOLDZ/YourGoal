class JourneyItem {
  final String title;
  final String goalTitle;
  final DateTime time;
  final String? comment;

  JourneyItem({
    required this.title,
    required this.goalTitle,
    required this.time,
    this.comment,
  });
}
