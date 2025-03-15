import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent {
  final Paint _paint;
  final double _rotationSpeed;
  double _currentRotation = 0;
  static final Random _random = Random();

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    Color baseColor = const Color(0xFFFF5722),
  }) : _paint = Paint()
    ..color = HSLColor.fromColor(baseColor)
        .withLightness(_random.nextDouble() * 0.3 + 0.3)
        .withSaturation(_random.nextDouble() * 0.3 + 0.7)
        .toColor()
    ..style = PaintingStyle.fill
    ..strokeWidth = 3,
    _rotationSpeed = (_random.nextDouble() - 0.5) * 2,
    super(
      position: position,
      size: size,
    );

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_currentRotation);
    canvas.translate(-size.x / 2, -size.y / 2);

    final path = Path()
      ..moveTo(0, size.y / 2)
      ..lineTo(size.x / 2, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x / 2, size.y)
      ..close();

    // Draw glow effect
    final glowPaint = Paint()
      ..color = _paint.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawPath(path, glowPaint);

    // Draw main shape
    canvas.drawPath(path, _paint);

    // Draw outline
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _currentRotation += _rotationSpeed * dt;
  }

  bool checkCollision(Vector2 position, double radius) {
    final rect = toRect();
    final circle = Rect.fromCircle(
      center: Offset(position.x, position.y),
      radius: radius,
    );
    return rect.overlaps(circle);
  }
}

class ObstacleManager extends Component with HasGameRef {
  double gameSpeed;
  final double initialGameSpeed;
  final String stageType;
  final Random _random = Random();
  final List<ObstacleComponent> obstacles = [];
  double _timeSinceLastSpawn = 0;
  static const double minSpawnTime = 0.8;
  static const double maxSpawnTime = 1.5;
  double _nextSpawnTime = 1.0;

  ObstacleManager({
    required this.initialGameSpeed,
    required this.stageType,
  }) : gameSpeed = initialGameSpeed;

  @override
  void update(double dt) {
    _timeSinceLastSpawn += dt;
    
    // Spawn new obstacle
    if (_timeSinceLastSpawn >= _nextSpawnTime) {
      _spawnObstacle();
      _timeSinceLastSpawn = 0;
      _nextSpawnTime = minSpawnTime + _random.nextDouble() * (maxSpawnTime - minSpawnTime);
    }
    
    // Update and remove obstacles
    for (final obstacle in obstacles.toList()) {
      obstacle.position.x -= gameSpeed * dt; // Move obstacles from right to left
      if (obstacle.position.x < -obstacleWidth) {
        obstacle.removeFromParent();
        obstacles.remove(obstacle);
      }
    }
  }

  void updateGameSpeed(double newSpeed) {
    gameSpeed = newSpeed;
  }

  bool checkCollision(Vector2 position, double radius) {
    for (final obstacle in obstacles) {
      if (obstacle.checkCollision(position, radius)) {
        return true;
      }
    }
    return false;
  }

  void _spawnObstacle() {
    final screenWidth = gameRef.size.x;
    final screenHeight = gameRef.size.y;
    
    // Reduced number of simultaneous obstacles for mobile
    final numObstacles = _random.nextInt(2) + 1;
    
    // Increased spacing between obstacles
    for (var i = 0; i < numObstacles; i++) {
      final obstacle = ObstacleComponent(
        stageType: stageType,
        position: Vector2(
          screenWidth + (i * obstacleWidth * 3), // Increased horizontal spacing
          _random.nextDouble() * (screenHeight - obstacleHeight * 2) + obstacleHeight, // Better vertical spacing
        ),
        size: Vector2(obstacleWidth, obstacleHeight),
        obstacleVariant: _random.nextInt(2),
      );
      
      obstacles.add(obstacle);
      gameRef.add(obstacle);
    }
  }

  void reset() {
    _timeSinceLastSpawn = 0;
    _nextSpawnTime = 1.0;
    gameSpeed = initialGameSpeed;
    for (final obstacle in obstacles) {
      obstacle.removeFromParent();
    }
    obstacles.clear();
  }

  static const double obstacleWidth = 55; // Slightly larger obstacles
  static const double obstacleHeight = 55;
}

class ObstacleComponent extends PositionComponent with HasGameRef {
  static const double obstacleWidth = 55;
  static const double obstacleHeight = 55;
  static final Random _staticRandom = Random();
  final String stageType;
  final int obstacleVariant;
  final Random _random = Random();
  final Paint _paint = Paint();
  double _rotationAngle = 0;
  final double _rotationSpeed;

  ObstacleComponent({
    required this.stageType,
    required Vector2 position,
    required Vector2 size,
    required this.obstacleVariant,
  }) : _rotationSpeed = (_staticRandom.nextDouble() - 0.5) * 2,
       super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    _rotationAngle += _rotationSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotationAngle);
    canvas.translate(-size.x / 2, -size.y / 2);

    final paint = _getObstaclePaint();
    final path = _getObstaclePath();
    
    // Draw main obstacle
    canvas.drawPath(path, paint);
    
    // Add special effects based on stage type
    _addSpecialEffects(canvas, path);

    canvas.restore();
  }

  void _addSpecialEffects(Canvas canvas, Path path) {
    switch (stageType) {
      case 'space':
        // Add space glow effect
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.blue.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
        );
        // Add energy field
        if (obstacleVariant == 1) {
          canvas.drawPath(
            path,
            Paint()
              ..shader = RadialGradient(
                colors: [Colors.blue[300]!, Colors.transparent],
              ).createShader(
                Rect.fromCircle(
                  center: Offset(size.x / 2, size.y / 2),
                  radius: size.x / 2,
                ),
              ),
          );
        }
        break;

      case 'cyber':
        // Add neon glow
        canvas.drawPath(
          path,
          Paint()
            ..color = (obstacleVariant == 0 ? Colors.cyan : Colors.purple).withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6),
        );
        // Add data stream effect
        canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.transparent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
        );
        break;

      case 'forest':
        // Add nature glow
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.green[300]!.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4),
        );
        break;

      case 'volcano':
        // Add lava glow
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.orange.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
        );
        // Add magma core
        canvas.drawPath(
          path,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.yellow.withOpacity(0.4),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.x / 2, size.y / 2),
                radius: size.x / 2,
              ),
            ),
        );
        break;

      case 'ice':
        // Add frost glow
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5),
        );
        // Add crystalline shine
        if (obstacleVariant == 1) {
          canvas.drawPath(
            path,
            Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.transparent,
                ],
              ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
          );
        }
        break;
    }
  }

  Paint _getObstaclePaint() {
    final paint = Paint()..style = PaintingStyle.fill;
    switch (stageType) {
      case 'space':
        paint.shader = RadialGradient(
          colors: obstacleVariant == 0 
            ? [Colors.purple[400]!, Colors.blue[900]!]  // Energy field
            : [Colors.grey[400]!, Colors.grey[800]!],   // Asteroid
          stops: const [0.2, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.x / 2, size.y / 2),
            radius: size.x / 2,
          ),
        );
        break;
      case 'cyber':
        paint.color = obstacleVariant == 0 
          ? Colors.cyan  // Data barrier
          : Colors.purple[400]!;  // Security node
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 3;
        break;
      case 'forest':
        paint.color = obstacleVariant == 0 
          ? Colors.green[700]!  // Thorny vine
          : Colors.brown[600]!; // Ancient trunk
        break;
      case 'volcano':
        paint.shader = RadialGradient(
          colors: obstacleVariant == 0 
            ? [Colors.orange[600]!, Colors.red[900]!]  // Magma rock
            : [Colors.red[400]!, Colors.grey[800]!],   // Volcanic bomb
          stops: const [0.2, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.x / 2, size.y / 2),
            radius: size.x / 2,
          ),
        );
        break;
      case 'ice':
        paint.color = obstacleVariant == 0 
          ? Colors.lightBlue[100]!.withOpacity(0.7)  // Ice crystal
          : Colors.blue[200]!.withOpacity(0.8);      // Frost spike
        break;
      default:
        paint.color = Colors.white;
    }
    return paint;
  }

  Path _getObstaclePath() {
    final path = Path();
    switch (stageType) {
      case 'space':
        if (obstacleVariant == 0) {
          // Energy field - hexagonal shape
          for (var i = 0; i < 6; i++) {
            final angle = i * pi / 3;
            final x = size.x / 2 + cos(angle) * size.x / 2;
            final y = size.y / 2 + sin(angle) * size.y / 2;
            i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
          }
        } else {
          // Asteroid - irregular shape
          final points = <Offset>[];
          final segments = 8;
          for (var i = 0; i < segments; i++) {
            final angle = i * 2 * pi / segments;
            final radius = size.x * (0.4 + _random.nextDouble() * 0.2);
            points.add(Offset(
              size.x / 2 + cos(angle) * radius,
              size.y / 2 + sin(angle) * radius,
            ));
          }
          path.addPolygon(points, true);
        }
        break;

      case 'cyber':
        if (obstacleVariant == 0) {
          // Data barrier - rectangular with cutouts
          path.moveTo(0, size.y * 0.2);
          path.lineTo(size.x * 0.3, size.y * 0.2);
          path.lineTo(size.x * 0.4, 0);
          path.lineTo(size.x * 0.6, 0);
          path.lineTo(size.x * 0.7, size.y * 0.2);
          path.lineTo(size.x, size.y * 0.2);
          path.lineTo(size.x, size.y * 0.8);
          path.lineTo(size.x * 0.7, size.y * 0.8);
          path.lineTo(size.x * 0.6, size.y);
          path.lineTo(size.x * 0.4, size.y);
          path.lineTo(size.x * 0.3, size.y * 0.8);
          path.lineTo(0, size.y * 0.8);
        } else {
          // Security node - octagonal shape
          for (var i = 0; i < 8; i++) {
            final angle = i * pi / 4;
            final x = size.x / 2 + cos(angle) * size.x / 2;
            final y = size.y / 2 + sin(angle) * size.y / 2;
            i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
          }
        }
        path.close();
        break;

      case 'forest':
        if (obstacleVariant == 0) {
          // Thorny vine - curved shape with spikes
          path.moveTo(size.x * 0.2, 0);
          path.quadraticBezierTo(
            size.x * 0.8, size.y * 0.3,
            size.x * 0.2, size.y,
          );
          // Add thorns
          for (var i = 0; i < 3; i++) {
            final t = i / 2;
            final x = size.x * (0.2 + 0.6 * t);
            final y = size.y * t;
            path.lineTo(x + size.x * 0.1, y + size.y * 0.1);
            path.lineTo(x, y + size.y * 0.2);
          }
        } else {
          // Ancient trunk - gnarled tree shape
          path.moveTo(size.x * 0.3, 0);
          path.lineTo(size.x * 0.7, 0);
          path.lineTo(size.x, size.y * 0.3);
          path.quadraticBezierTo(
            size.x * 0.8, size.y * 0.7,
            size.x * 0.6, size.y,
          );
          path.lineTo(size.x * 0.4, size.y);
          path.quadraticBezierTo(
            size.x * 0.2, size.y * 0.7,
            0, size.y * 0.3,
          );
        }
        path.close();
        break;

      case 'volcano':
        if (obstacleVariant == 0) {
          // Magma rock - jagged shape
          final points = <Offset>[];
          final segments = 12;
          for (var i = 0; i < segments; i++) {
            final angle = i * 2 * pi / segments;
            final radius = size.x * (0.4 + _random.nextDouble() * 0.2);
            points.add(Offset(
              size.x / 2 + cos(angle) * radius,
              size.y / 2 + sin(angle) * radius,
            ));
          }
          path.addPolygon(points, true);
        } else {
          // Volcanic bomb - teardrop shape
          path.moveTo(size.x / 2, 0);
          path.quadraticBezierTo(
            size.x, size.y * 0.4,
            size.x * 0.5, size.y,
          );
          path.quadraticBezierTo(
            0, size.y * 0.4,
            size.x / 2, 0,
          );
        }
        break;

      case 'ice':
        if (obstacleVariant == 0) {
          // Ice crystal - diamond shape
          path.moveTo(size.x * 0.5, 0);
          path.lineTo(size.x, size.y * 0.4);
          path.lineTo(size.x * 0.5, size.y);
          path.lineTo(0, size.y * 0.4);
        } else {
          // Frost spike - sharp triangular shape
          path.moveTo(size.x * 0.5, 0);
          path.lineTo(size.x, size.y);
          path.lineTo(0, size.y);
        }
        path.close();
        break;

      default:
        path.addRect(Rect.fromLTWH(0, 0, size.x, size.y));
    }
    return path;
  }

  bool checkCollision(Vector2 position, double radius) {
    // Get the obstacle's path for precise collision detection
    final path = _getObstaclePath();
    
    // Transform the path based on the obstacle's position and rotation
    final matrix = Matrix4.identity()
      ..translate(this.position.x + size.x / 2, this.position.y + size.y / 2)
      ..rotateZ(_rotationAngle)
      ..translate(-size.x / 2, -size.y / 2);
    
    final transformedPath = path.transform(matrix.storage);
    
    // Check if any point of the player's circle collides
    final playerPos = Offset(position.x, position.y);
    
    // Check center point
    if (transformedPath.contains(playerPos)) {
      return true;
    }
    
    // Check points around the circle
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final point = Offset(
        position.x + cos(angle) * radius,
        position.y + sin(angle) * radius,
      );
      if (transformedPath.contains(point)) {
        return true;
      }
    }
    
    return false;
  }
} 