enum IssueStatus { newIssue, inProgress, resolved }

class Issue {
  final String id;
  final String title;
  final String description;
  final String address;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  IssueStatus status;
  int votes;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.status = IssueStatus.newIssue,
    this.votes = 0,
  });
}
