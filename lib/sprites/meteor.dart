import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/player.dart';

class Meteor extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  Vector2 velocity; // 운석 속도 추가
  late final SpriteAnimation fallAnimation;

  Meteor({super.position, required this.velocity})
    : super(size: Vector2(80, 80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    final image = await game.images.load('meteor.png');
    fallAnimation = SpriteAnimation.spriteList([
      Sprite(image, srcPosition: Vector2(6, 13), srcSize: Vector2(44, 32)),
      Sprite(image, srcPosition: Vector2(70, 13), srcSize: Vector2(57, 32)),
      Sprite(image, srcPosition: Vector2(134, 13), srcSize: Vector2(56, 32)),
      Sprite(image, srcPosition: Vector2(198, 13), srcSize: Vector2(56, 32)),
      Sprite(image, srcPosition: Vector2(265, 15), srcSize: Vector2(50, 38)),
      Sprite(image, srcPosition: Vector2(327, 15), srcSize: Vector2(53, 36)),
      Sprite(image, srcPosition: Vector2(400, 20), srcSize: Vector2(30, 34)),
    ], stepTime: .8);

    animation = fallAnimation;

    angle = -pi / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt; // 🔹 속도 적용

    if (position.y < -height) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      game.player.onPlayerHit(); // 체력 감소
      removeFromParent(); // 적 제거
    }
  }
}
