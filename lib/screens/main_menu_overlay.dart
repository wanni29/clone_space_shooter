import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/player.dart';
import 'package:space_shooter_game/screens/widgets/character_button.dart';
import 'package:space_shooter_game/screens/widgets/white_space.dart';

class MainMenuOverlay extends StatefulWidget {
  const MainMenuOverlay(this.game, {super.key});

  final Game game;

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  Character character = Character.player;
  final player = Player();

  @override
  Widget build(BuildContext context) {
    SpaceShooterGame game = widget.game as SpaceShooterGame;

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextStyle titleStyle =
            (constraints.maxWidth > 830)
                ? Theme.of(context).textTheme.displayLarge!
                : Theme.of(context).textTheme.displaySmall!;

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Space Shooter',
                      style: titleStyle.copyWith(height: .8),
                      textAlign: TextAlign.center,
                    ),
                    const WhiteSpace(),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Select your character:',
                        style: Theme.of(context).textTheme.headlineSmall!,
                      ),
                    ),
                    const WhiteSpace(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CharacterButton(
                          character: Character.player,
                          selected: character == Character.player,
                          onSelectChar: () {
                            setState(() {
                              character = Character.player;
                            });
                          },
                        ),
                      ],
                    ),
                    const WhiteSpace(),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          game.gameManager.selectCharacter(character);
                          game.startGame();
                        },
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(
                            const Size(100, 50),
                          ),
                          textStyle: WidgetStateProperty.all(
                            Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        child: const Text('Start'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
