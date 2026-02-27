import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/firebase_error_handler.dart';
import '../models/issue_model.dart';

abstract class IssuesRemoteDataSource {
  Stream<List<IssueModel>> getIssuesStream();
  Future<void> createIssue(IssueModel issue);
  Future<void> voteForIssue(String issueId, String userId);
}

class IssuesRemoteDataSourceImpl implements IssuesRemoteDataSource {
  final FirebaseDatabase _database;
  late final DatabaseReference _issuesRef;

  IssuesRemoteDataSourceImpl(this._database) {
    _issuesRef = _database.ref('issues');
  }

  @override
  Stream<List<IssueModel>> getIssuesStream() {
    return _issuesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      
      final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
      return map.entries.map((e) {
        final issueId = e.key as String;
        final issueData = Map<String, dynamic>.from(e.value as Map);
        return IssueModel.fromJson(issueData, issueId);
      }).toList();
    });
  }

  @override
  Future<void> createIssue(IssueModel issue) async {
    try {
      print('FIREBASE: Creating issue at /issues/${issue.id} by author ${issue.authorId}');
      final newIssueRef = _issuesRef.child(issue.id);
      await newIssueRef.set(issue.toJson());
      print('FIREBASE: Issue created successfully');
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: IssuesRemoteDataSourceImpl | Method: createIssue | Exception: $e');
      throw Exception(FirebaseErrorHandler.getMessage(e));
    }
  }

  @override
  Future<void> voteForIssue(String issueId, String userId) async {
    try {
      final voteRef = _issuesRef.child('$issueId/votes/$userId');
      
      // Checking if user already voted to toggle or just set true
      final snapshot = await voteRef.get();
      if (snapshot.exists) {
        await voteRef.remove(); // Unlike/revoke vote
      } else {
        await voteRef.set(true); // Like/vote
      }
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: IssuesRemoteDataSourceImpl | Method: voteForIssue | Exception: $e');
      throw Exception(FirebaseErrorHandler.getMessage(e));
    }
  }
}
