import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class LaserBeam extends RectangleComponent with HasGameRef<SpaceShooterGame> {
  LaserBeam({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2(6, 0), // 처음엔 아주 짧게 시작!
        paint: Paint()..color = const Color(0xFF00FFFF),
      );

  double maxLifetime = 0.4;
  double lifetime = 0.4;
  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    lifetime -= dt;

    final progress = (1 - (lifetime / maxLifetime)).clamp(0, 1);

    // ⚡️ 1. 길이 점점 늘리기
    final double maxHeight = 240;
    final double newHeight = maxHeight * (progress < 0.3 ? progress * 3.3 : 1);
    size.y = newHeight;

    // ⚡️ 2. 색상 번갈아: 보라색 or 파란색
    final bool usePurple = _random.nextBool();
    final baseColor =
        usePurple ? const Color(0xFFAA00FF) : const Color(0xFF00FFFF);

    // ⚡️ 3. 투명도 서서히 줄이기
    final double alphaRatio = lifetime / maxLifetime;
    final int alpha = (255 * alphaRatio).clamp(0, 255).toInt();
    paint.color = baseColor.withAlpha(alpha);

    // ⚡️ 4. 제거
    if (lifetime <= 0) {
      removeFromParent();
    }
  }
}
