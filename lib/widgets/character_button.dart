import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:space_shooter_game/space_shooter_game.dart';
import 'package:space_shooter_game/widgets/white_space.dart';

class CharacterButton extends StatefulWidget {
  const CharacterButton({
    super.key,
    required this.character,
    this.selected = false,
    required this.onSelectChar,
  });

  final Character character;
  final bool selected;
  final void Function() onSelectChar;

  @override
  State<CharacterButton> createState() => _CharacterButtonState();
}

class _CharacterButtonState extends State<CharacterButton> {
  Sprite? _characterSprite;

  @override
  void initState() {
    super.initState();
    _loadSprite();
  }

  Future<void> _loadSprite() async {
    final spriteSheet = await Flame.images.load('player.png');
    setState(() {
      _characterSprite = Sprite(
        spriteSheet,
        srcPosition: Vector2(1, 2),
        srcSize: Vector2(30, 39),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style:
          widget.selected
              ? ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(31, 64, 195, 255),
                ),
              )
              : null,
      onPressed: widget.onSelectChar,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              width: 80,
              height: 100,
              child:
                  _characterSprite != null
                      ? SpriteWidget(
                        sprite: _characterSprite!,
                      ) // 🔥 스프라이트 위젯 사용
                      : const CircularProgressIndicator(), // 로딩 중 표시
            ),
            const WhiteSpace(height: 18),
            Text(widget.character.name, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
