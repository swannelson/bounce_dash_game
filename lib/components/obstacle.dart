import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent {
  static const double spikeWidth = 30;
  static const double spikeHeight = 50;
  final Paint _paint = Paint()..color = Colors.white;
  double speed = -200; // Will be controlled by ObstacleManager

  Obstacle() : super(size: Vector2(spikeWidth, spikeHeight));

  @override
  void render(Canvas canvas) {
    final path = Path();
    
    // Draw a triangle (spike)
    path.moveTo(0, spikeHeight);  // Bottom-left
    path.lineTo(spikeWidth / 2, 0);  // Top-middle
    path.lineTo(spikeWidth, spikeHeight);  // Bottom-right
    path.close();
    
    canvas.drawPath(path, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
  }

  bool checkCollision(Vector2 point) {
    return point.x >= position.x &&
           point.x <= position.x + width &&
           point.y >= position.y &&
           point.y <= position.y + height;
  }
} 