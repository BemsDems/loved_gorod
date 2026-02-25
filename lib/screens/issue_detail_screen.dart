import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/mock_repository.dart';
import '../models/issue.dart';

class IssueDetailScreen extends StatelessWidget {
  final Issue issue;

  const IssueDetailScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Consumer<IssuesRepository>(
      builder: (context, repository, child) {
        final currentIssue = repository.issues.firstWhere(
          (i) => i.id == issue.id,
          orElse: () => issue,
        );

        final bool isVoted = repository.hasVoted(currentIssue.id);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 300.0,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background:
                            issue.imageUrl != null
                                ? issue.imageUrl!.startsWith('assets')
                                    ? Image.asset(
                                      issue.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            color: Colors.grey.shade100,
                                            child: Center(
                                              child: Text(
                                                "Не удалось загрузить",
                                              ),
                                            ),
                                          ),
                                    )
                                    : Image.file(
                                      File(issue.imageUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            color: Colors.grey.shade100,
                                            child: Center(
                                              child: Text(
                                                "Не удалось загрузить",
                                              ),
                                            ),
                                          ),
                                    )
                                : Center(
                                  child: Text("Изображение отсутствует"),
                                ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusBadge(currentIssue.status),
                                Text(
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(currentIssue.createdAt),
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentIssue.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Поддержка жителей',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${currentIssue.votes}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: '  голосов',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection('Адрес', currentIssue.address),
                            const SizedBox(height: 24),
                            _buildInfoSection(
                              'Описание проблемы',
                              currentIssue.description,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child:
                                  isVoted
                                      ? _buildVotedState()
                                      : _buildVoteButton(
                                        context,
                                        repository,
                                        currentIssue.id,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVotedState() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            'Вы поддержали эту проблему',
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    IssuesRepository repository,
    String issueId,
  ) {
    return FilledButton(
      onPressed: () {
        repository.voteForIssue(issueId);
      },
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text(
        'Поддержать проблему',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(IssueStatus status) {
    String text;
    Color color;
    Color bg;
    switch (status) {
      case IssueStatus.newIssue:
        text = 'Новое';
        color = Colors.red.shade700;
        bg = Colors.red.shade50;
        break;
      case IssueStatus.inProgress:
        text = 'В работе';
        color = Colors.orange.shade800;
        bg = Colors.orange.shade50;
        break;
      case IssueStatus.resolved:
        text = 'Решено';
        color = Colors.green.shade700;
        bg = Colors.green.shade50;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
