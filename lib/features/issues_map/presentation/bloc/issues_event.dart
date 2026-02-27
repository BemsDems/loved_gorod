part of 'issues_bloc.dart';

abstract class IssuesEvent extends Equatable {
  const IssuesEvent();

  @override
  List<Object?> get props => [];
}

class IssuesSubscriptionRequested extends IssuesEvent {
  const IssuesSubscriptionRequested();
}

class IssuesCreateRequested extends IssuesEvent {
  final IssueEntity issue;

  const IssuesCreateRequested(this.issue);

  @override
  List<Object?> get props => [issue];
}

class IssuesVoteRequested extends IssuesEvent {
  final String issueId;
  final String userId;

  const IssuesVoteRequested({
    required this.issueId,
    required this.userId,
  });

  @override
  List<Object?> get props => [issueId, userId];
}
class IssuesResetCreateStatus extends IssuesEvent {
  const IssuesResetCreateStatus();
}
