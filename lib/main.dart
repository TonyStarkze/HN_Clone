import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/stories/stories_cubit.dart';
import 'repositories/hn_repository.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HnReaderApp());
}

class HnReaderApp extends StatelessWidget {
  const HnReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = HnRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HnRepository>.value(value: repository),
      ],
      child: BlocProvider(
        create: (_) => StoriesCubit(repository),
        child: MaterialApp(
          title: 'HN Reader',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF6600),
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
