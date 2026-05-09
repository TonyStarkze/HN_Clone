import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/stories/stories_cubit.dart';
import '../cubits/stories/stories_state.dart';
import '../cubits/detail/detail_cubit.dart';
import '../repositories/hn_repository.dart';
import '../widgets/story_tile.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<StoriesCubit>().loadStories();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) context.read<StoriesCubit>().loadMore();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    return current >= maxScroll - 300;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white,
              child: const Text(
                'Y',
                style: TextStyle(
                  color: Color(0xFFFF6600),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Text(
              'Hacker News',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<StoriesCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<StoriesCubit, StoriesState>(
        builder: (context, state) {
          if (state is StoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StoriesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.read<StoriesCubit>().loadStories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StoriesLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<StoriesCubit>().refresh(),
              child: ListView.separated(
                controller: _scrollController,
                itemCount: state.stories.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 0.5),
                itemBuilder: (context, index) {
                  if (index >= state.stories.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final story = state.stories[index];
                  return StoryTile(
                    index: index + 1,
                    story: story,
                    onTap: () => _openDetail(context, story),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openDetail(BuildContext context, story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              DetailCubit(context.read<HnRepository>())..loadDetail(story),
          child: DetailScreen(story: story),
        ),
      ),
    );
  }
}
