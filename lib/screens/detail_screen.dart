import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubits/detail/detail_cubit.dart';
import '../cubits/detail/detail_state.dart';
import '../models/hn_item.dart';
import '../repositories/hn_repository.dart';
import '../utils/time_utils.dart';
import '../widgets/comment_widget.dart';

class DetailScreen extends StatelessWidget {
  final HnItem story;

  const DetailScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Comments',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          if (story.url != null)
            IconButton(
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              tooltip: 'Open article',
              onPressed: () => _launchUrl(story.url!),
            ),
        ],
      ),
      body: BlocBuilder<DetailCubit, DetailState>(
        builder: (context, state) {
          if (state is DetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DetailError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DetailCubit>().loadDetail(story),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DetailLoaded) {
            return CustomScrollView(
              slivers: [
                // Story header
                SliverToBoxAdapter(
                  child: _StoryHeader(story: state.story),
                ),
                // Comments
                if (state.topComments.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => CommentWidget(
                        key: ValueKey(state.topComments[index].id),
                        comment: state.topComments[index],
                        repository: context.read<HnRepository>(),
                        depth: 0,
                      ),
                      childCount: state.topComments.length,
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _StoryHeader extends StatelessWidget {
  final HnItem story;

  const _StoryHeader({required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            story.title ?? '(untitled)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (story.domain.isNotEmpty) ...[
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () async {
                if (story.url != null) {
                  final uri = Uri.parse(story.url!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Text(
                story.domain,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFFF6600),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Meta info
          Text(
            '${story.score} points by ${story.by ?? '?'}  '
            '${formatTime(story.time)}  '
            '${story.descendants} comment${story.descendants == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          // Self-post text (Ask HN, etc.)
          if (story.text != null) ...[
            const SizedBox(height: 8),
            Html(
              data: story.text!,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(13),
                ),
              },
            ),
          ],
        ],
      ),
    );
  }
}
