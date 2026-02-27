import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/issue_entity.dart';
import '../../domain/usecases/issues_usecases.dart';

part 'issues_event.dart';
part 'issues_state.dart';

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  final GetIssuesStreamUseCase _getIssuesStreamUseCase;
  final CreateIssueUseCase _createIssueUseCase;
  final VoteIssueUseCase _voteIssueUseCase;
  
  StreamSubscription<List<IssueEntity>>? _issuesSubscription;

  IssuesBloc({
    required GetIssuesStreamUseCase getIssuesStreamUseCase,
    required CreateIssueUseCase createIssueUseCase,
    required VoteIssueUseCase voteIssueUseCase,
  })  : _getIssuesStreamUseCase = getIssuesStreamUseCase,
        _createIssueUseCase = createIssueUseCase,
        _voteIssueUseCase = voteIssueUseCase,
        super(const IssuesState()) {
    on<IssuesSubscriptionRequested>(_onIssuesSubscriptionRequested);
    on<IssuesCreateRequested>(_onIssuesCreateRequested);
    on<IssuesVoteRequested>(_onIssuesVoteRequested);
    on<IssuesResetCreateStatus>(_onIssuesResetCreateStatus);
  }

  Future<void> _onIssuesSubscriptionRequested(
    IssuesSubscriptionRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(state.copyWith(status: IssuesStatus.loading));
    
    await emit.forEach<List<IssueEntity>>(
      _getIssuesStreamUseCase(),
      onData: (issues) => state.copyWith(
        status: IssuesStatus.success,
        issues: issues,
      ),
      onError: (error, stackTrace) => state.copyWith(
        status: IssuesStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> _onIssuesCreateRequested(
    IssuesCreateRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(state.copyWith(
      createStatus: IssuesCreateStatus.submitting,
      clearError: true,
    ));
    
    final result = await _createIssueUseCase(event.issue);
    result.fold(
      (error) => emit(state.copyWith(
        createStatus: IssuesCreateStatus.failure,
        errorMessage: error,
      )),
      (_) => emit(state.copyWith(createStatus: IssuesCreateStatus.success)),
    );
  }

  void _onIssuesResetCreateStatus(
    IssuesResetCreateStatus event,
    Emitter<IssuesState> emit,
  ) {
    emit(state.copyWith(
      createStatus: IssuesCreateStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onIssuesVoteRequested(
    IssuesVoteRequested event,
    Emitter<IssuesState> emit,
  ) async {
    final result = await _voteIssueUseCase(event.issueId, event.userId);
    result.fold(
      (error) => emit(state.copyWith(
        status: IssuesStatus.failure,
        errorMessage: error,
      )),
      (_) {} // stream handles success
    );
  }

  @override
  Future<void> close() {
    _issuesSubscription?.cancel();
    return super.close();
  }
}
