import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class Bullet extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Vector2 velocity; // 🔹 총알 속도 추가

  Bullet({super.position, required this.velocity})
    : super(size: Vector2(25, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox(collisionType: CollisionType.passive));

    animation = await game.loadSpriteAnimation(
      'bullet.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2(32, 48),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt; // 🔹 속도 적용

    if (position.y < -height) {
      removeFromParent();
    }
  }
}
