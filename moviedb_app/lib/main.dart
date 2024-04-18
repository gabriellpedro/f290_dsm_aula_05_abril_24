import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moviedb_app/pages/home_page.dart';
import 'package:moviedb_app/repositories/movie_repository_impl.dart';
import 'package:moviedb_app/services/http_manager.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: [
    Provider(
      create: (context) => Dio(),
    ),
    Provider(
      create: (context) => HttpManager(
        dio: context.read(),
      ),
    ),
    Provider(
      create: (context) => MovieRepositoryImpl(
        httpManager: context.read(),
      ),
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
