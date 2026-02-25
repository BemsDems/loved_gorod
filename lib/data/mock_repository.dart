import 'package:flutter/material.dart';

import '../models/issue.dart';

class IssuesRepository extends ChangeNotifier {
  final List<Issue> _issues = [
    Issue(
      id: '1',
      title: 'Яма на дороге',
      description: 'Глубокая яма при выезде со двора.',
      address: 'г. Нальчик, ул. Ленина, д. 25',
      imageUrl: 'assets/doroga.png',
      latitude: 43.4845,
      longitude: 43.6070,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: IssueStatus.newIssue,
      votes: 5,
    ),
    Issue(
      id: '2',
      title: 'Сломан фонарь',
      description: 'Не горит освещение в парке.',
      address: 'г. Нальчик, парк Атажукинский сад',
      imageUrl: 'assets/fonar.png',
      latitude: 43.472034,
      longitude: 43.597606,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      status: IssueStatus.inProgress,
      votes: 12,
    ),
  ];

  List<Issue> get issues => _issues;

  final Set<String> _votedIssueIds = {};

  bool hasVoted(String issueId) {
    return _votedIssueIds.contains(issueId);
  }

  void addIssue(Issue issue) {
    _issues.add(issue);
    notifyListeners();
  }

  void voteForIssue(String issueId) {
    if (_votedIssueIds.contains(issueId)) return;

    final index = _issues.indexWhere((issue) => issue.id == issueId);
    if (index != -1) {
      _issues[index].votes += 1;
      _votedIssueIds.add(issueId);
      notifyListeners();
    }
  }
}
