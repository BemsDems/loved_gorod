import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/issue_entity.dart';
import '../../domain/repositories/i_issues_repository.dart';
import '../datasources/issues_remote_data_source.dart';
import '../models/issue_model.dart';

class IssuesRepositoryImpl implements IIssuesRepository {
  final IssuesRemoteDataSource remoteDataSource;

  IssuesRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<IssueEntity>> getIssuesStream() {
    return remoteDataSource.getIssuesStream().map(
      (models) => models.cast<IssueEntity>(),
    );
  }

  @override
  Future<Either<String, void>> createIssue(IssueEntity issue) async {
    try {
      final model = IssueModel.fromEntity(issue);
      await remoteDataSource.createIssue(model);
      return const Right(null);
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: IssuesRepositoryImpl | Method: createIssue | Exception: $e');
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, void>> voteForIssue(
    String issueId,
    String userId,
  ) async {
    try {
      await remoteDataSource.voteForIssue(issueId, userId);
      return const Right(null);
    } catch (e) {
      debugPrint('[DATA LAYER ERROR] Class: IssuesRepositoryImpl | Method: voteForIssue | Exception: $e');
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
