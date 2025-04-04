import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/player.dart';

class ItemPlusBullet extends SpriteComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  ItemPlusBullet({super.position})
    : super(size: itemPlusBulletSize, anchor: Anchor.center);

  static Vector2 itemPlusBulletSize = Vector2(30.0, 60.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    sprite = await game.loadSprite('item_plus_bullet.png');
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

    if (other is Player) {
      removeFromParent();
    }
  }
}
