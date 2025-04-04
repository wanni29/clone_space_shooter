import 'dart:async';

import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class HealthBar extends PositionComponent with HasGameRef<SpaceShooterGame> {
  final int maxHealth;
  late List<SpriteComponent> hearts;

  HealthBar({required this.maxHealth}) : super(size: Vector2(150, 50));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    hearts = List.generate(
      maxHealth,
      (index) => SpriteComponent(
        size: Vector2(100, 100),
        position: Vector2(index * 70, 0),
      ),
    );

    final heartSprite = await game.loadSprite('heart.png');
    for (var heart in hearts) {
      heart.sprite = heartSprite;
      add(heart);
    }

    position = Vector2(0, 20);
  }

  void updateHealth(int currentHealth) {
    for (int i = 0; i < hearts.length; i++) {
      hearts[i].opacity = i < currentHealth ? 1.0 : 0.3;
    }
  }
}
