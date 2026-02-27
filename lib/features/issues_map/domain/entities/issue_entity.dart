import 'package:equatable/equatable.dart';

enum IssueStatus { newIssue, inProgress, resolved }

class IssueEntity extends Equatable {
  final String id;
  final String authorId;
  final String title;
  final String description;
  final String address;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final IssueStatus status;
  final int votes;
  final Map<String, dynamic> votesMap;

  const IssueEntity({
    required this.id,
    required this.authorId,
    required this.title,
    required this.description,
    required this.address,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.status = IssueStatus.newIssue,
    this.votes = 0,
    this.votesMap = const {},
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        title,
        description,
        address,
        imageUrl,
        latitude,
        longitude,
        createdAt,
        status,
        votes,
        votesMap,
      ];
}
