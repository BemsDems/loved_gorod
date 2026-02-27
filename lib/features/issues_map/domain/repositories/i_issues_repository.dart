import 'dart:async';
import 'package:dartz/dartz.dart';
import '../entities/issue_entity.dart';

abstract class IIssuesRepository {
  Stream<List<IssueEntity>> getIssuesStream();
  Future<Either<String, void>> createIssue(IssueEntity issue);
  Future<Either<String, void>> voteForIssue(String issueId, String userId);
}
