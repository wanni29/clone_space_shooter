import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/boss_formation_enemy.dart';
import 'package:space_shooter_game/sprites/enemy.dart';
import 'package:space_shooter_game/sprites/exclamation_mark.dart';
import 'package:space_shooter_game/sprites/meteor.dart';

enum BossState {
  intro,
  idle,
  movingLeft,
  movingRight,
  movingTopCenter,
  movingBottomCenter,
  waitingForCharge,
  charging,
  dropMeteor,
  hookMeteor,
}

class Boss extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  Boss({super.position})
    : super(size: Vector2(150, 300), anchor: Anchor.center);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation moveLeftAnimation;
  late final SpriteAnimation moveRightAnimation;
  late final SpriteAnimation moveBackAnimation;

  // 보스의 현재 상태
  BossState _state = BossState.intro;

  // 타겟팅 된 플레이어의 좌표값
  Vector2? playerLastPosition;

  // 타겟팅 완료 시 표시될 느낌표
  late ExclamationMark exclamationMark;
  bool showExclamation = false;

  // 패턴 시작 타이머 변수
  double _patternTimer = 0;
  int _currentPatternIndex = 0;

  bool _hasDroppedMeteor = false; // 중복 방지용
  bool _hashookedMeteor = false; // 중복 방지용

  bool _hasStartedIntro = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    add(RectangleHitbox());

    // position = Vector2(game.size.x / 2, game.size.y / 4);

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

    animation = idleAnimation;

    // 느낌표 텍스트 컴포넌트 생성
    exclamationMark = ExclamationMark(
      text: '!',
      position: Vector2(150, 0),
      textRenderer: TextPaint(
        style: GoogleFonts.notoSans(
          fontSize: 70,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFF0000),
        ),
      ),
    );
    exclamationMark.isVisible = false;
    add(exclamationMark);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 보스가 쉬고 있을 때만 타이머 증가
    if (_state == BossState.idle) {
      _patternTimer += dt;

      if (_patternTimer > 3.0) {
        _executeCurrentPattern();
        _patternTimer = 0;

        // 다음 패턴으로 전환 (무한 반복되게)
        _currentPatternIndex = (_currentPatternIndex + 1) % 4;
      }
    }
    switch (_state) {
      case BossState.intro:
        if (!_hasStartedIntro) {
          startIntroFormation();
        }
        break;
      // 아무것도 안 함
      case BossState.idle:
        break;
      case BossState.movingLeft:
        _moveToLeftEdge(dt);
        break;
      case BossState.movingRight:
        _moveToRightEdge(dt);
        break;
      case BossState.movingTopCenter:
        _moveToTopCenter(dt);
        break;
      case BossState.movingBottomCenter:
        _moveToBottomCenter(dt);
        break;
      case BossState.waitingForCharge:
        if (!showExclamation) {
          showExclamation = true;
          exclamationMark.isVisible = true;
          Future.delayed(const Duration(seconds: 1), () {
            exclamationMark.isVisible = false;
            _state = BossState.charging;
          });
        }
        break;
      case BossState.charging:
        _chargeToPlayer(dt);
        break;
      case BossState.dropMeteor:
        _dropMeteor();
        _state = BossState.idle;
        break;
      case BossState.hookMeteor:
        _hookMeteor();
        _state = BossState.idle;
        break;
    }
  }

  void startPattern1(Vector2 playerPos) {
    playerLastPosition = playerPos.clone();
    animation = moveLeftAnimation;
    showExclamation = false;
    _state = BossState.movingLeft;
  }

  void startPattern2(Vector2 playerPos) {
    playerLastPosition = playerPos.clone();
    animation = moveRightAnimation;
    showExclamation = false;
    _state = BossState.movingRight;
  }

  void startPattern3() {
    animation = idleAnimation;
    showExclamation = false;
    _state = BossState.movingTopCenter;
  }

  void startPattern4() {
    animation = idleAnimation;
    showExclamation = false;
    _state = BossState.movingBottomCenter;
  }

  void _moveToLeftEdge(double dt) {
    const double targetX = 100.0;
    if (x > targetX) {
      position.x -= 200 * dt;
    } else {
      position.x = targetX;
      animation = idleAnimation;
      _state = BossState.waitingForCharge;
    }
  }

  void _moveToRightEdge(double dt) {
    final double targetX = gameRef.size.x - size.x;
    if (x < targetX) {
      position.x += 200 * dt; // 👉 오른쪽으로 이동!
    } else {
      position.x = targetX;
      animation = idleAnimation;
      _state = BossState.waitingForCharge;
    }
  }

  void _moveToTopCenter(double dt) {
    final target = Vector2(game.size.x / 2, game.size.y / 4);
    final direction = (target - position);

    if (direction.length < 5) {
      // 목적지에 도달하면 정확히 위치 고정
      position = target.clone();

      // 한 번만 실행되도록 플래그를 씌우거나 상태 확인
      if (_state == BossState.movingTopCenter) {
        _state = BossState.idle;

        // 1초 후 느낌표 띄우기
        Future.delayed(const Duration(seconds: 1), () {
          if (!isMounted) return;
          exclamationMark.isVisible = true;
          showExclamation = true;

          // 다시 1초 후 메테오 떨어뜨리기
          Future.delayed(const Duration(seconds: 1), () {
            if (!isMounted) return;
            exclamationMark.isVisible = false;
            _state = BossState.dropMeteor;
          });
        });
      }
    } else {
      position += direction.normalized() * 250 * dt;
    }
  }

  void _moveToBottomCenter(double dt) {
    final target = Vector2(game.size.x / 2, game.size.y / 2);
    final direction = target - position;

    if (direction.length < 20) {
      position = target.clone();
      if (_state == BossState.movingBottomCenter) {
        _state = BossState.idle;

        // 1초 후 느낌표 표시
        Future.delayed(const Duration(seconds: 1), () {
          if (!isMounted) return;
          exclamationMark.isVisible = true;
          showExclamation = true;

          Future.delayed(const Duration(seconds: 1), () {
            if (!isMounted) return;
            exclamationMark.isVisible = false;
            _state = BossState.hookMeteor;
          });
        });
      }
    } else {
      position += direction.normalized() * 280 * dt;
    }
  }

  void _chargeToPlayer(double dt) {
    if (playerLastPosition == null) return;

    final direction = (playerLastPosition! - position).normalized();
    position += direction * 400 * dt;

    if ((playerLastPosition! - position).length < 10) {
      animation = idleAnimation;
      _state = BossState.idle;
    }
  }

  void _dropMeteor() {
    if (_hasDroppedMeteor) return;
    _hasDroppedMeteor = true;

    final meteorCount = 5;
    final spacing = gameRef.size.x / (meteorCount + 1);
    final y = -50.0;

    for (int i = 0; i < meteorCount; i++) {
      final x = spacing * (i + 1);
      final meteor = Meteor(position: Vector2(x, y), velocity: Vector2(0, 200));
      gameRef.add(meteor);
    }

    // 2초 후 상태 초기화
    Future.delayed(const Duration(seconds: 2), () {
      _hasDroppedMeteor = false;
      _state = BossState.idle;
    });
  }

  void _hookMeteor() {
    if (_hashookedMeteor) return;
    _hashookedMeteor = true;

    final leftStartX = -50.0;
    final rightStartX = gameRef.size.x + 50;
    final ySpacing = 230.0;

    // 왼쪽에서 출발하는 운석 4개
    for (var i = 0; i < 4; i++) {
      final y = 100 + i * ySpacing;
      final meteor = Meteor(
        size: Vector2(60, 60),
        position: Vector2(leftStartX, y),
        velocity: Vector2(400, 0),
      );
      gameRef.add(meteor);
    }

    // 오른쪽 운석은 2초 후 출발
    Future.delayed(const Duration(seconds: 1), () {
      for (var i = 0; i < 3; i++) {
        final y = 250 + i * ySpacing;
        final meteor = Meteor(
          size: Vector2(60, 60),
          position: Vector2(rightStartX, y),
          velocity: Vector2(-400, 0),
        );
        gameRef.add(meteor);
      }
    });

    // 2초 후 상태 초기화
    Future.delayed(const Duration(seconds: 2), () {
      _hashookedMeteor = false;
      _state = BossState.idle;
    });
  }

  void _executeCurrentPattern() {
    switch (_currentPatternIndex) {
      case 0:
        startPattern1(game.player.position);
        break;
      case 1:
        startPattern2(game.player.position);
        break;
      case 2:
        startPattern3();
        break;
      case 3:
        startPattern4();
        break;
    }
  }

  void startIntroFormation() {
    if (_hasStartedIntro) return;
    _hasStartedIntro = true;

    final formationYTop = 200.0;

    position = Vector2(gameRef.size.x / 2 - size.x / 2, -200);

    add(
      MoveEffect.to(
        Vector2(gameRef.size.x / 2 - size.x / 2, formationYTop),
        EffectController(duration: 1.5, curve: Curves.easeOut),
        onComplete: () {
          _state = BossState.idle;
        },
      ),
    );

    final formationYBottom = 280.0;
    final enemiesPerRow = 10;

    List<Enemy> enemies = [];

    // 💡 spacing 계산 (균등 간격 + 좌우 여백)
    final margin = 20.0; // 양쪽 여백
    final availableWidth = gameRef.size.x - margin * 2;
    final spacing = availableWidth / enemiesPerRow;
    final startX = margin + spacing / 2;

    for (int row = 0; row < 2; row++) {
      final yPos = row == 0 ? formationYTop : formationYBottom;

      for (int i = 0; i < enemiesPerRow; i++) {
        final xPos = startX + i * spacing;
        final enemy = BossFormationEnemy()..position = Vector2(xPos, -100);

        enemy.add(
          MoveEffect.to(
            Vector2(xPos, yPos),
            EffectController(
              duration: 1,
              curve: Curves.easeOut,
              startDelay: 0.5,
            ),
          ),
        );

        enemies.add(enemy);
      }
    }

    gameRef.addAll(enemies);

    Future.delayed(const Duration(seconds: 4), () {
      // 적들 동작 재개
    });
  }

  // 본격 전투 시작
  void startBattlePhase() {}
}
