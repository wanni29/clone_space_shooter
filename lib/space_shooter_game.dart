import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flutter/rendering.dart';
import 'package:space_shooter_game/managers/game_manager.dart';
import 'package:space_shooter_game/sprites/enemy.dart';
import 'package:space_shooter_game/sprites/health_bar.dart';
import 'package:space_shooter_game/sprites/item_plus_bullet.dart';
import 'package:space_shooter_game/sprites/player.dart';

enum Character { player }

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late Player player;
  late HealthBar healthBar;

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
    add(player);

    healthBar = HealthBar(maxHealth: player.maxHealth);
    add(healthBar);

    add(
      SpawnComponent(
        factory: (index) {
          return Enemy();
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );

    add(
      SpawnComponent(
        factory: (index) {
          return ItemPlusBullet();
        },
        period: 1, // 아이템이 나오는 주기를 조절 할수있음
        area: Rectangle.fromLTWH(
          0,
          0,
          size.x,
          -ItemPlusBullet.itemPlusBulletSize.x,
        ),
      ),
    );

    overlays.add('gameOverlay');
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
