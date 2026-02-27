import '../../domain/entities/issue_entity.dart';

class IssueModel extends IssueEntity {
  const IssueModel({
    required super.id,
    required super.authorId,
    required super.title,
    required super.description,
    required super.address,
    super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.createdAt,
    super.status,
    super.votes,
    super.votesMap,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json, String id) {
    final votesData = json['votes'] != null ? Map<String, dynamic>.from(json['votes'] as Map) : <String, dynamic>{};
    return IssueModel(
      id: id,
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? 'Без названия',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IssueStatus.newIssue,
      ),
      votes: votesData.length,
      votesMap: votesData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'description': description,
      'address': address,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.name,
      // Note: votes are handled separately in Firebase using a sub-node 'votes'
    };
  }

  factory IssueModel.fromEntity(IssueEntity entity) {
    return IssueModel(
      id: entity.id,
      authorId: entity.authorId,
      title: entity.title,
      description: entity.description,
      address: entity.address,
      imageUrl: entity.imageUrl,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
      status: entity.status,
      votes: entity.votes,
      votesMap: entity.votesMap,
    );
  }
}
