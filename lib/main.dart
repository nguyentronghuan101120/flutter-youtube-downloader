import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/dependency_injection/injection_container.dart' as di;
import 'presentation/bloc/video_analysis/video_analysis_cubit.dart';
import 'presentation/bloc/preferences/preferences_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoAnalysisCubit>(
          create: (context) => di.sl<VideoAnalysisCubit>(),
        ),
        BlocProvider<PreferencesCubit>(
          create: (context) => di.sl<PreferencesCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'YouTube Downloader',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('vi', 'VN'),
          Locale('ja', 'JP'),
          Locale('ko', 'KR'),
        ],
        home: const HomePage(),
      ),
    );
  }
}
