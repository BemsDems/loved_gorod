part of 'issues_bloc.dart';

enum IssuesStatus { initial, loading, success, failure }
enum IssuesCreateStatus { initial, submitting, success, failure }

class IssuesState extends Equatable {
  final IssuesStatus status;
  final IssuesCreateStatus createStatus;
  final List<IssueEntity> issues;
  final String? errorMessage;

  const IssuesState({
    this.status = IssuesStatus.initial,
    this.createStatus = IssuesCreateStatus.initial,
    this.issues = const [],
    this.errorMessage,
  });

  IssuesState copyWith({
    IssuesStatus? status,
    IssuesCreateStatus? createStatus,
    List<IssueEntity>? issues,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IssuesState(
      status: status ?? this.status,
      createStatus: createStatus ?? this.createStatus,
      issues: issues ?? this.issues,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, createStatus, issues, errorMessage];
}
