import 'package:flutter/material.dart';
import 'package:loved_gorod/models/issue.dart';
import 'package:loved_gorod/screens/issue_detail_screen.dart';

class IssuePreviewCard extends StatelessWidget {
  final Issue issue;

  const IssuePreviewCard({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(issue.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${issue.votes} голосов',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IssueDetailScreen(issue: issue),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Подробнее"),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
