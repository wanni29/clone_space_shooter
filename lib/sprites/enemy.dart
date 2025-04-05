import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/sprites/bullet.dart';
import 'package:space_shooter_game/sprites/explosion.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/laser_beam.dart';
import 'package:space_shooter_game/sprites/player.dart';

class Enemy extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  Enemy({super.position})
    : super(size: Vector2.all(enemySize), anchor: Anchor.center);

  static const enemySize = 80.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    animation = await game.loadSpriteAnimation(
      'enemy.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2.all(32),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += dt * 250;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
    }

    if (other is LaserBeam) {
      removeFromParent();
      game.add(Explosion(position: position));
    }

    if (other is Player) {
      game.player.onPlayerHit(); // 체력 감소
      removeFromParent(); // 적 제거
    }
  }
}
