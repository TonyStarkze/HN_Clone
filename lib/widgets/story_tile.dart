import 'package:flutter/material.dart';
import '../models/hn_item.dart';
import '../utils/time_utils.dart';

class StoryTile extends StatelessWidget {
  final int index;
  final HnItem story;
  final VoidCallback onTap;

  const StoryTile({
    super.key,
    required this.index,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final domain = story.domain;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index number
            SizedBox(
              width: 28,
              child: Text(
                '$index.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            // Arrow icon
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 6),
              child: Icon(Icons.arrow_drop_up, size: 18, color: Colors.grey),
            ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + domain
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: story.title ?? '(untitled)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (domain.isNotEmpty) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: '($domain)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Meta row
                  Text(
                    '${story.score} points by ${story.by ?? '?'} '
                    '${formatTime(story.time)} | '
                    '${story.descendants} comment${story.descendants == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
