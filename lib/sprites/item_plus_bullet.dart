import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/sprites/player.dart';

class ItemPlusBullet extends SpriteComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  ItemPlusBullet({super.position})
    : super(size: itemPlusBulletSize, anchor: Anchor.center);

  static Vector2 itemPlusBulletSize = Vector2(30.0, 60.0);
  static const double maxSpeed = 200.0; // 이동 속도
  static const double lifeTime = 5.0; // 아이템이 유지되는 시간 : 5초
  late Vector2 velocity; // 아이템의 이동 방향 벡터
  late Timer _lifeTimer; // 수명 타이머

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    sprite = await game.loadSprite('item_plus_bullet.png');

    paint =
        Paint()
          ..colorFilter = const ColorFilter.mode(
            Colors.yellowAccent,
            BlendMode.modulate, // 원래 이미지 색상과 섞어줌
          );

    _setRandomDirection(); // 랜덤 방향 설정

    _lifeTimer = Timer(
      lifeTime,
      onTick: () {
        removeWithEffect(); // 서서히 사라지는 효과와 함께 제거
      },
    );
  }

  // 랜덤 방향을 설정하는 함수
  void _setRandomDirection() {
    final random = Random();

    // 4가지 방향 중 하나를 선택하도록 설정
    switch (random.nextInt(2)) {
      case 0: // 위에서 아래
        velocity = Vector2(0, maxSpeed);
        break;
      case 1: // 대각선 방향 (랜덤)
        velocity = Vector2(
          random.nextBool() ? maxSpeed : -maxSpeed, // X축 방향 랜덤
          random.nextBool() ? maxSpeed : -maxSpeed, // Y축 방향 랜덤
        );
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    _lifeTimer.update(dt); // 수명 타이머 업데이트

    //  화면 끝에 닿으면 튕기기
    if (position.x < 0 || position.x > game.size.x - size.x) {
      velocity.x = -velocity.x; // X축 반전
    }

    if (position.y < 0 || position.y > game.size.y - size.y) {
      velocity.y = -velocity.y; // Y축 반전
    }
  }

  // 아이템이 자연스럽게 사라지게 만들기
  void removeWithEffect() {
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.5),
        onComplete: () {
          removeFromParent();
        },
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      if (!isRemoving) {
        print("🎯 아이템 충돌 발생! increaseBullet 실행");
        removeFromParent(); // 아이템 즉시 제거해서 중복 충돌 방지
        other.increaseBullet();
      }
    }
  }
}
