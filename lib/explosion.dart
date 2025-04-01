import 'dart:async';

import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class Explosion extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Explosion({super.position})
    : super(size: Vector2.all(32), anchor: Anchor.center, removeOnFinish: true);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(33.4),
        loop: false,
      ),
    );
  }
}
