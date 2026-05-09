import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/hn_item.dart';
import '../repositories/hn_repository.dart';
import '../utils/time_utils.dart';

/// A self-contained comment widget that lazily loads its own nested replies.
/// [depth] controls left indentation (max depth rendered is 5).
class CommentWidget extends StatefulWidget {
  final HnItem comment;
  final HnRepository repository;
  final int depth;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.repository,
    this.depth = 0,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _expanded = true;
  bool _repliesLoaded = false;
  bool _loadingReplies = false;
  List<HnItem> _replies = [];

  static const int _maxDepth = 5;
  static const int _maxReplies = 10;

  // Indent colours cycle through shades for visual depth cues
  static const List<Color> _depthColors = [
    Color(0xFFFF6600), // HN orange
    Color(0xFF0000FF),
    Color(0xFF009900),
    Color(0xFFCC0000),
    Color(0xFF9900CC),
  ];

  Color get _borderColor =>
      _depthColors[widget.depth % _depthColors.length];

  @override
  void initState() {
    super.initState();
    // Auto-load first two levels of nesting
    if (widget.depth < 2 && widget.comment.kids.isNotEmpty) {
      _loadReplies();
    }
  }

  Future<void> _loadReplies() async {
    if (_repliesLoaded || _loadingReplies) return;
    setState(() => _loadingReplies = true);
    final ids = widget.comment.kids.take(_maxReplies).toList();
    final replies = await widget.repository.getItems(ids);
    if (mounted) {
      setState(() {
        _replies = replies;
        _repliesLoaded = true;
        _loadingReplies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReplies = widget.comment.kids.isNotEmpty;
    final indent = (widget.depth * 12.0).clamp(0.0, 60.0);

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left-border accent
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 2, color: _borderColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_up,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.comment.by ?? '[deleted]',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF828282),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatTime(widget.comment.time),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              if (!_expanded && hasReplies) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '[${widget.comment.kids.length} more]',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Comment body
                      if (_expanded && widget.comment.text != null)
                        Html(
                          data: widget.comment.text!,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(13),
                              color: const Color(0xFF333333),
                            ),
                            'a': Style(
                              color: const Color(0xFFFF6600),
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 4),
                            ),
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Replies section
          if (_expanded && hasReplies && widget.depth < _maxDepth) ...[
            if (_loadingReplies)
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 4, bottom: 4),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (!_repliesLoaded)
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _loadReplies,
                child: Text(
                  'Load ${widget.comment.kids.length} repl${widget.comment.kids.length == 1 ? 'y' : 'ies'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFFF6600),
                  ),
                ),
              )
            else
              for (final reply in _replies)
                CommentWidget(
                  key: ValueKey(reply.id),
                  comment: reply,
                  repository: widget.repository,
                  depth: widget.depth + 1,
                ),
          ],

          const Divider(height: 8, thickness: 0.5),
        ],
      ),
    );
  }
}
