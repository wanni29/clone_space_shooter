import 'dart:io' show Platform;
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:space_shooter_game/space_shooter_game.dart';

class GameOverlay extends StatefulWidget {
  const GameOverlay(this.game, {super.key});

  final Game game;

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay> {
  bool isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 게임 영역 터치는 무시 (즉, 게임으로 전달)
        IgnorePointer(
          ignoring: true,
          child: Container(color: Colors.transparent),
        ),

        // 일시정지 버튼은 터치 가능하게 함
        Positioned(
          top: 30,
          right: 30,
          child: GestureDetector(
            onTap: () {
              (widget.game as SpaceShooterGame).togglePauseState();
              setState(() {
                isPaused = !isPaused;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // 버튼이 잘 보이게 반투명 배경 추가
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
