import 'dart:async';

import 'package:flame/components.dart';
import 'package:space_shooter_game/sprites/bullet.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Player() : super(size: Vector2(100, 150), anchor: Anchor.bottomCenter);

  late final SpawnComponent _bulletSpawner;
  late final SpriteAnimation _playerAnimation;
  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

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
      factory: (index) {
        return Bullet(position: position + Vector2(0, -height / 2));
      },
      autoStart: false,
    );

    game.add(_bulletSpawner);
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
}
