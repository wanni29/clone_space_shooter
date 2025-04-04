import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter_game/screens/widgets/white_space.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Game Over',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(),
              ),
              const WhiteSpace(height: 50),
              ElevatedButton(
                onPressed: () {
                  (game as SpaceShooterGame).resetGame();
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(200, 75)),
                  textStyle: MaterialStateProperty.all(
                    Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
