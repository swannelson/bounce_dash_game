import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/bouncing_ball.dart';
import '../components/background.dart';
import '../managers/obstacle_manager.dart';
import '../managers/power_up_manager.dart';

class BounceDashGame extends FlameGame with TapDetector {
  late BouncingBall ball;
  late ObstacleManager obstacleManager;
  late PowerUpManager powerUpManager;
  late BackgroundComponent background;
  
  final String stageType;
  final score = ValueNotifier<int>(0);
  final distance = ValueNotifier<double>(0);
  bool isGameOver = false;
  double gameSpeed = 180;
  double elapsedTime = 0;
  final Random _random = Random();

  BounceDashGame({required this.stageType});

  @override
  Future<void> onLoad() async {
    ball = BouncingBall();
    ball.position = Vector2(size.x * 0.3, size.y / 2);
    
    background = BackgroundComponent(stageType: stageType);
    obstacleManager = ObstacleManager(
      initialGameSpeed: gameSpeed,
      stageType: stageType,
    );
    powerUpManager = PowerUpManager(spawnInterval: 12);
    
    add(background);
    add(ball);
    add(obstacleManager);
    add(powerUpManager);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isGameOver) {
      elapsedTime += dt;
      distance.value += gameSpeed * dt;
      score.value = distance.value.toInt();
      
      // More gradual speed increase
      gameSpeed = 180 + (elapsedTime * 8).clamp(0, 250);
      
      // Update managers with new game speed
      obstacleManager.updateGameSpeed(gameSpeed);
      powerUpManager.updateGameSpeed(gameSpeed);
      
      // Check for collisions
      if (obstacleManager.checkCollision(ball.position + Vector2(ball.currentSize / 2, ball.currentSize / 2), ball.currentSize / 2)) {
        if (!ball.hasShield) {
          gameOver();
        }
      }
      
      final powerUpType = powerUpManager.checkCollision(ball.position + Vector2(ball.currentSize / 2, ball.currentSize / 2), ball.currentSize / 2);
      if (powerUpType != null) {
        ball.applyPowerUp(powerUpType);
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    ball.onTapDown();
  }

  @override
  void onTapUp(TapUpInfo info) {
    ball.onTapUp();
  }

  void gameOver() async {
    isGameOver = true;
    
    // Save high score if achieved
    final prefs = await SharedPreferences.getInstance();
    final highScore = prefs.getInt('highScore') ?? 0;
    if (score.value > highScore) {
      await prefs.setInt('highScore', score.value);
    }
    
    overlays.add('gameOver');
  }

  void reset() {
    isGameOver = false;
    score.value = 0;
    distance.value = 0;
    gameSpeed = 180;
    elapsedTime = 0;
    ball.reset();
    obstacleManager.reset();
    powerUpManager.reset();
  }
} 