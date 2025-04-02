import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class GameManager extends Component with HasGameRef<SpaceShooterGame> {
  GameManager();

  Character character = Character.player;

  ValueNotifier<int> score = ValueNotifier(0);

  GameState state = GameState.intro;

  bool get isPlaying => state == GameState.playing;
  bool get isGameOver => state == GameState.gameOver;
  bool get isIntro => state == GameState.intro;

  void reset() {
    score.value = 0;
    state = GameState.intro;
  }

  void increaseScore() {
    score.value++;
  }

  void selectCharacter(Character selectedCharacter) {
    character = selectedCharacter;
  }
}

enum GameState { intro, playing, gameOver }
