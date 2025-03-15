import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum PowerUpType {
  shield,
  miniBall,
  slowMotion,
}

class PowerUpManager extends Component with HasGameRef {
  final double spawnInterval;
  double gameSpeed;
  final Random _random = Random();
  final List<PowerUpComponent> powerUps = [];
  double _timeSinceLastSpawn = 0;

  PowerUpManager({required this.spawnInterval}) : gameSpeed = 200;

  @override
  void update(double dt) {
    _timeSinceLastSpawn += dt;
    
    // Spawn new power-up
    if (_timeSinceLastSpawn >= spawnInterval) {
      _spawnPowerUp();
      _timeSinceLastSpawn = 0;
    }
    
    // Update and remove power-ups
    for (final powerUp in powerUps.toList()) {
      powerUp.position.x -= gameSpeed * dt;
      if (powerUp.position.x < -PowerUpComponent.powerUpSize) {
        powerUp.removeFromParent();
        powerUps.remove(powerUp);
      }
    }
  }

  void updateGameSpeed(double newSpeed) {
    gameSpeed = newSpeed;
  }

  PowerUpType? checkCollision(Vector2 position, double radius) {
    for (final powerUp in powerUps.toList()) {
      if (powerUp.checkCollision(position, radius)) {
        final type = powerUp.type;
        powerUp.removeFromParent();
        powerUps.remove(powerUp);
        return type;
      }
    }
    return null;
  }

  void _spawnPowerUp() {
    final type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];
    final powerUp = PowerUpComponent(
      position: Vector2(gameRef.size.x + 50, _random.nextDouble() * (gameRef.size.y - 100) + 50),
      type: type,
    );
    add(powerUp);
    powerUps.add(powerUp);
  }

  void reset() {
    _timeSinceLastSpawn = 0;
    for (final powerUp in powerUps) {
      powerUp.removeFromParent();
    }
    powerUps.clear();
  }
}

class PowerUpComponent extends PositionComponent {
  static const double powerUpSize = 30;
  final PowerUpType type;
  final Paint _paint = Paint();

  PowerUpComponent({required Vector2 position, required this.type})
      : super(position: position, size: Vector2.all(powerUpSize)) {
    _paint.color = _getColorForType(type);
  }

  Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.miniBall:
        return Colors.green;
      case PowerUpType.slowMotion:
        return Colors.purple;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(powerUpSize / 2, powerUpSize / 2),
      powerUpSize / 2,
      _paint,
    );

    // Draw icon based on type
    final iconPath = Path();
    switch (type) {
      case PowerUpType.shield:
        _drawShieldIcon(canvas);
        break;
      case PowerUpType.miniBall:
        _drawMiniBallIcon(canvas);
        break;
      case PowerUpType.slowMotion:
        _drawSlowMotionIcon(canvas);
        break;
    }
  }

  void _drawShieldIcon(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(powerUpSize / 2, powerUpSize / 2), radius: powerUpSize / 3),
      -0.5,
      2.0,
      false,
      paint,
    );
  }

  void _drawMiniBallIcon(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(powerUpSize / 2, powerUpSize / 2),
      powerUpSize / 4,
      paint,
    );
  }

  void _drawSlowMotionIcon(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(powerUpSize / 2, powerUpSize / 2), radius: powerUpSize / 4),
      -1.0,
      5.0,
      false,
      paint,
    );
  }

  bool checkCollision(Vector2 position, double radius) {
    final center = this.position + Vector2.all(powerUpSize / 2);
    return position.distanceTo(center) <= radius + powerUpSize / 2;
  }
} 