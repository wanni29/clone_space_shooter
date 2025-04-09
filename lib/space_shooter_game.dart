import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/rendering.dart';
import 'package:space_shooter_game/managers/game_manager.dart';
import 'package:space_shooter_game/sprites/boss.dart';
import 'package:space_shooter_game/sprites/enemy.dart';
import 'package:space_shooter_game/sprites/health_bar.dart';
import 'package:space_shooter_game/sprites/item_laser_supporter.dart';
import 'package:space_shooter_game/sprites/item_plus_bullet.dart';
import 'package:space_shooter_game/sprites/meteor.dart';
import 'package:space_shooter_game/sprites/player.dart';

enum Character { player }

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late Player player;
  late Boss boss;
  late HealthBar healthBar;
  late SpawnComponent enemySpawner;
  late SpawnComponent itemPlusBulletSpawner;
  late SpawnComponent itemLaserSupporterSpawner;

  GameManager gameManager = GameManager();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await add(gameManager);

    final parallax = await loadParallaxComponent(
      [ParallaxImageData('stars_1.png'), ParallaxImageData('stars_2.png')],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);

    player = Player();
    boss = Boss();
    add(player);

    healthBar = HealthBar(maxHealth: player.maxHealth);
    add(healthBar);

    enemySpawner = SpawnComponent(
      factory: (index) => Enemy(),
      period: 1,
      area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
    );
    add(enemySpawner);

    itemPlusBulletSpawner = SpawnComponent(
      factory: (index) => ItemPlusBullet(),
      period: 1,
      area: Rectangle.fromLTWH(
        40,
        70,
        size.x,
        -ItemPlusBullet.itemPlusBulletSize.x,
      ),
    );
    add(itemPlusBulletSpawner);

    itemLaserSupporterSpawner = SpawnComponent(
      factory: (index) => ItemLaserSupporter(),
      period: 1,
      area: Rectangle.fromLTWH(
        40,
        70,
        size.x,
        -ItemPlusBullet.itemPlusBulletSize.x,
      ),
    );
    add(itemLaserSupporterSpawner);

    overlays.add('gameOverlay');

    // 30초 후에 보스 등장 연출 시작
    Future.delayed(Duration(seconds: 5), () {
      player.startBossIntroPhase();
      add(boss);
    });
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }

  void startGame() {
    gameManager.reset();
    gameManager.state = GameState.playing;
    overlays.remove('mainMenuOverlay');

    // 기존 플레이어 다시 추가
    if (!children.contains(player)) {
      // 플레이어가 없을 때만 추가
      add(player);
    }
  }

  void resetGame() {
    removeAll(children.whereType<Enemy>()); // 모든 적 제거
    player.removeFromParent(); // 플레이어 제거
    healthBar.removeFromParent(); // 체력바 제거

    player = Player();
    healthBar = HealthBar(maxHealth: player.maxHealth);

    add(player);
    add(healthBar);

    startGame();
    overlays.remove('gameOverOverlay');
  }

  void onLose() {
    gameManager.state = GameState.gameOver;
    player.removeFromParent();
    overlays.add('gameOverOverlay');
  }

  void clearScreenExceptPlayerAndBoss() {
    // 적 제거: 서서히 사라짐
    for (final enemy in children.whereType<Enemy>()) {
      enemy.add(
        OpacityEffect.to(
          0, // 완전 투명
          EffectController(duration: 0.5),
          onComplete: () => enemy.removeFromParent(),
        ),
      );
    }

    // 아이템 제거: PlusBullet
    for (final item in children.whereType<ItemPlusBullet>()) {
      item.add(
        OpacityEffect.to(
          0,
          EffectController(duration: 0.5),
          onComplete: () => item.removeFromParent(),
        ),
      );
    }

    // 아이템 제거: LaserSupporter
    for (final item in children.whereType<ItemLaserSupporter>()) {
      item.add(
        OpacityEffect.to(
          0,
          EffectController(duration: 0.5),
          onComplete: () => item.removeFromParent(),
        ),
      );
    }

    // SpawnComponent 제거 (즉시)
    enemySpawner.removeFromParent();
    itemPlusBulletSpawner.removeFromParent();
    itemLaserSupporterSpawner.removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameManager.isGameOver) {
      return;
    }

    if (gameManager.isIntro) {
      overlays.add('mainMenuOverlay');
      return;
    }
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }
}
