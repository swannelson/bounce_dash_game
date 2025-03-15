import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/bounce_dash_game.dart';
import '../overlays/game_over.dart';
import '../overlays/hud.dart';

class GameScreen extends StatelessWidget {
  final String stageType;
  
  const GameScreen({
    super.key,
    required this.stageType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<BounceDashGame>(
        game: BounceDashGame(stageType: stageType),
        overlayBuilderMap: {
          'hud': (context, game) => HudOverlay(game: game),
          'gameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
} 