import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/sprites/bullet.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Player() : super(size: Vector2(100, 150), anchor: Anchor.bottomCenter);

  int maxHealth = 3; // 최대 체력
  int currentHealth = 3; // 현재 체력
  int bulletCount = 1;
  static const int maxBulletCount = 5;

  late final SpawnComponent _bulletSpawner;
  late final SpriteAnimation _playerAnimation;
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    add(RectangleHitbox());

    _playerAnimation = await game.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.09,
        textureSize: Vector2(32, 48),
      ),
    );

    animation = _playerAnimation;
    position = game.size / 2;

    _bulletSpawner = SpawnComponent(
      period: .2,
      selfPositioning: true,
      factory: (index) => BulletGroup(_createBullets()),
      autoStart: false,
    );

    game.add(_bulletSpawner);
  }

  List<Bullet> _createBullets() {
    List<Bullet> bullets = [];
    for (int i = 0; i < bulletCount; i++) {
      bullets.add(
        Bullet(
          position:
              position + Vector2(i * 30 - (bulletCount - 1) * 15, -height / 2),
        ),
      );
    }
    return bullets;
  }

  SpriteAnimation get playerAnimation => _playerAnimation;

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }

  void takeDamage() {
    currentHealth--;
    if (currentHealth <= 0) {
      game.onLose(); // 체력이 0이 되면 게임 오버 처리
    }
  }

  void onPlayerHit() {
    takeDamage();
    gameRef.healthBar.updateHealth(currentHealth);
  }

  void increaseBullet() {
    if (bulletCount < maxBulletCount) {
      bulletCount++;
    }
  }
}

/// 여러 개의 총알을 한 번에 추가할 수 있도록 하는 그룹 컴포넌트
class BulletGroup extends PositionComponent {
  BulletGroup(List<Bullet> bullets) {
    addAll(bullets);
  }
}
