import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter_game/sprites/bullet.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/laser_beam.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Player() : super(size: Vector2(80, 120), anchor: Anchor.center);

  int maxHealth = 3; // 최대 체력
  int currentHealth = 3; // 현재 체력
  int bulletCount = 1;
  static const int maxBulletCount = 5;
  bool isSpreadMode = false; // 🔹 총알 모드 (기본값: 일직선)

  ValueNotifier<int> bulletCountForMode = ValueNotifier<int>(
    1,
  ); // ValueNotifier 사용

  late final SpawnComponent _bulletSpawner;
  late final SpriteAnimation _playerAnimation;

  // -- 레이저 서포트 관련 상태 --
  final int maxLaserSupporters = 2;
  final List<LaserSupporterAttachment> laserSupporters = [];

  bool isFrozen = false;

  bool canAddLaserSupporter() => laserSupporters.length < maxLaserSupporters;

  void addLaserSupporter(LaserSupporterAttachment supporter) {
    if (canAddLaserSupporter()) {
      laserSupporters.add(supporter);
      add(supporter); // Player에 붙임
    }
  }

  double laserShootCooldown = 0;
  // -- 레이저 서포트 관련 상태 --

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

  // 🔹 현재 모드에 따라 총알 생성
  List<Bullet> _createBullets() {
    return isSpreadMode ? _createSpreadBullets() : _createStraightBullets();
  }

  // 🔹 일직선으로 나가는 총알 (기본)
  List<Bullet> _createStraightBullets() {
    List<Bullet> bullets = [];
    for (int i = 0; i < bulletCount; i++) {
      bullets.add(
        Bullet(
          position:
              position + Vector2(i * 30 - (bulletCount - 1) * 15, -height / 2),
          velocity: Vector2(0, -500), // 🔹 위로 직선 이동
        ),
      );
    }
    return bullets;
  }

  // 🔹 분산형으로 나가는 총알
  List<Bullet> _createSpreadBullets() {
    List<Bullet> bullets = [];
    double spreadAngle = 0.2; // 퍼지는 각도 조절 (라디안 단위)

    for (int i = 0; i < bulletCount; i++) {
      double angle = (i - (bulletCount - 1) / 2) * spreadAngle; // 좌우로 퍼짐
      Vector2 direction = Vector2(0, -1)..rotate(angle); // 회전 적용

      bullets.add(
        Bullet(
          position: position + Vector2(0, -height / 2),
          velocity: direction * 300, // 속도 적용
        ),
      );
    }
    return bullets;
  }

  // 🔹 총알 모드 토글 (스위칭)
  void toggleBulletMode() {
    isSpreadMode = !isSpreadMode;
  }

  SpriteAnimation get playerAnimation => _playerAnimation;

  void move(Vector2 delta) {
    if (isFrozen) return;
    position.add(delta);
  }

  void startShooting() {
    if (isFrozen) return;
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
    if (bulletCount < 5) {
      bulletCount++;
      bulletCountForMode.value++;
    }
  }

  void startBossIntroPhase() {
    isFrozen = true;

    // 총알 발사 멈추기
    stopShooting();

    // 부드럽게 중앙 하단으로 이동
    final targetPosition = Vector2(
      gameRef.size.x / 2 - size.x / 2,
      gameRef.size.y - size.y - 20,
    );

    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: 1.5, curve: Curves.easeInOut),
        onComplete: () {
          // 이동 끝나고 화면 정리
          gameRef.clearScreenExceptPlayerAndBoss();

          Future.delayed(Duration(seconds: 2), () {
            gameRef.boss.startIntroFormation();
          });
        },
      ),
    );
  }

  @override
  void update(double dt) {
    // 이 부분은 애니메이션에서 가장 중요한 요소기 때문에
    // 상단에서 위치를 옮기면 안됨 -> 애니메이션 요소가 멈춰버릴수도있음!
    super.update(dt);

    if (isFrozen) return;

    // Player update 내부에서 supporter 위치 계산
    final offset1 = Vector2(130, 100);
    final offset2 = Vector2(-30, 100);

    if (laserSupporters.length == 1) {
      laserSupporters[0].position = offset1;
    }

    if (laserSupporters.length == 2) {
      laserSupporters[1].position = offset2;
    }

    // 쿨다운 관리
    laserShootCooldown -= dt;
    if (laserShootCooldown <= 0) {
      for (var supporter in laserSupporters) {
        supporter.shootLaser(); // 드론들에게 발사 명령
      }
      laserShootCooldown = 0.8; // 다음 발사까지 쿨다운
    }
  }
}

/// 여러 개의 총알을 한 번에 추가할 수 있도록 하는 그룹 컴포넌트
class BulletGroup extends PositionComponent {
  BulletGroup(List<Bullet> bullets) {
    addAll(bullets);
  }
}

class LaserSupporterAttachment extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  LaserSupporterAttachment()
    : super(size: Vector2(55, 55), anchor: Anchor.center);

  double shootCooldown = 0;

  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'item_laser_supporter.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2(32, 32),
      ),
    );
  }

  void shootLaser() {
    final currentGlobalPosition = absolutePosition;
    final laser = LaserBeam(
      startPosition: currentGlobalPosition - Vector2(0, size.y + 230),
    );
    gameRef.add(laser);
  }
}
