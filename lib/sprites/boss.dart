import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class Boss extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  Boss({super.position})
    : super(size: Vector2(150, 300), anchor: Anchor.center);

  static const bossSize = 200.0;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation moveLeftAnimation;
  late final SpriteAnimation moveRightAnimation;
  late final SpriteAnimation moveBackAnimation;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(RectangleHitbox());

    position = Vector2(game.size.x / 2, game.size.y / 4);

    // 어떤 이미지인지 일단 들고오는 과정
    final image = await game.images.load('boss.png');

    // 정면
    idleAnimation = SpriteAnimation.spriteList([
      Sprite(image, srcPosition: Vector2(8, 4), srcSize: Vector2(32, 59)),
      Sprite(image, srcPosition: Vector2(56, 2), srcSize: Vector2(32, 60)),
      Sprite(image, srcPosition: Vector2(104, 0), srcSize: Vector2(32, 63)),
    ], stepTime: 0.16);

    // 왼쪽
    moveLeftAnimation = SpriteAnimation.spriteList([
      Sprite(image, srcPosition: Vector2(14, 64), srcSize: Vector2(21, 63)),
      Sprite(image, srcPosition: Vector2(62, 66), srcSize: Vector2(21, 60)),
      Sprite(image, srcPosition: Vector2(110, 68), srcSize: Vector2(21, 59)),
    ], stepTime: 0.16);

    // 오른쪽
    moveRightAnimation = SpriteAnimation.spriteList([
      Sprite(image, srcPosition: Vector2(13, 132), srcSize: Vector2(21, 59)),
      Sprite(image, srcPosition: Vector2(61, 130), srcSize: Vector2(21, 60)),
      Sprite(image, srcPosition: Vector2(109, 128), srcSize: Vector2(21, 63)),
    ], stepTime: 0.16);

    // 뒤
    moveBackAnimation = SpriteAnimation.spriteList([
      Sprite(image, srcPosition: Vector2(8, 196), srcSize: Vector2(32, 59)),
      Sprite(image, srcPosition: Vector2(56, 194), srcSize: Vector2(32, 60)),
      Sprite(image, srcPosition: Vector2(104, 192), srcSize: Vector2(32, 63)),
    ], stepTime: 0.16);

    // 초기 상태는 정면
    // 테스트 시작
    // animation = idleAnimation;
    animation = moveLeftAnimation;
    // animation = moveRightAnimation;
    // animation = moveBackAnimation;
  }

  void moveLeft() {
    animation = moveLeftAnimation;
  }

  void moveRight() {
    animation = moveRightAnimation;
  }

  void moveBack() {
    animation = moveBackAnimation;
  }

  void idle() {
    animation = idleAnimation;
  }
}
