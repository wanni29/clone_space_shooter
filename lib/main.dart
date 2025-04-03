import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/util/color_schemes.dart';
import 'package:space_shooter_game/widgets/game_overlay.dart';
import 'package:space_shooter_game/widgets/main_menu_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Shooter',
      themeMode: ThemeMode.dark,
      theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.audiowideTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MyHomePage(title: 'Space Shooter'),
    );
  }
}

final Game game = SpaceShooterGame();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        child: GameWidget(
          game: game,
          overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
            'gameOverlay': (context, game) => GameOverlay(game),
            'mainMenuOverlay': (context, game) => MainMenuOverlay(game),
            // 'gameOverOverlay': (context, game) => GameOverOverlay(game),
          },
        ),
      ),
    );
  }
}
