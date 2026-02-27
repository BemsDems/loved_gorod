import 'dart:async';
import 'package:dartz/dartz.dart';
import '../entities/issue_entity.dart';
import '../repositories/i_issues_repository.dart';

class GetIssuesStreamUseCase {
  final IIssuesRepository repository;

  GetIssuesStreamUseCase(this.repository);

  Stream<List<IssueEntity>> call() {
    return repository.getIssuesStream();
  }
}

class CreateIssueUseCase {
  final IIssuesRepository repository;

  CreateIssueUseCase(this.repository);

  Future<Either<String, void>> call(IssueEntity issue) {
    return repository.createIssue(issue);
  }
}

class VoteIssueUseCase {
  final IIssuesRepository repository;

  VoteIssueUseCase(this.repository);

  Future<Either<String, void>> call(String issueId, String userId) {
    return repository.voteForIssue(issueId, userId);
  }
}
