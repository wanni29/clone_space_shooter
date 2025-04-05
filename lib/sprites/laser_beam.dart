import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class LaserBeam extends RectangleComponent with HasGameRef<SpaceShooterGame> {
  LaserBeam({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2(6, 240),
        paint: Paint()..color = const Color(0xFF00FFFF), // 초기 색상
      );

  double lifetime = 0.3;
  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 보라색 + 파란색 계열 번갈아 표현 (플래시 느낌)
    final bool usePurple = _random.nextBool();
    if (usePurple) {
      paint.color = const Color(0xFFAA00FF); // 보라색
    } else {
      paint.color = const Color(0xFF00FFFF); // 파란색
    }

    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
    }
  }
}
