import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundComponent extends Component with HasGameRef {
  final Paint _paint = Paint();
  final Random _random = Random();
  final String stageType;
  double _time = 0;
  final List<_Star> _stars = [];
  final List<_FloatingObject> _objects = [];

  BackgroundComponent({required this.stageType});

  @override
  Future<void> onLoad() async {
    // Create initial stars for space theme
    if (stageType == 'space') {
      for (int i = 0; i < 100; i++) {
        _stars.add(_Star(
          x: _random.nextDouble() * gameRef.size.x,
          y: _random.nextDouble() * gameRef.size.y,
          size: _random.nextDouble() * 2 + 1,
          speed: _random.nextDouble() * 30 + 20,
        ));
      }
    }

    // Create floating objects based on stage type
    for (int i = 0; i < 20; i++) {
      _objects.add(_FloatingObject(
        x: _random.nextDouble() * gameRef.size.x,
        y: _random.nextDouble() * gameRef.size.y,
        size: _random.nextDouble() * 30 + 20,
        speed: _random.nextDouble() * 20 + 10,
        type: stageType,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw base background gradient
    final Rect rect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    canvas.drawRect(
      rect,
      Paint()..shader = _getBackgroundGradient(rect),
    );

    // Draw stars for space theme
    if (stageType == 'space') {
      for (final star in _stars) {
        final brightness = (sin(_time * 2 + star.x) + 1) / 2;
        canvas.drawCircle(
          Offset(star.x, star.y),
          star.size,
          Paint()
            ..color = Colors.white.withOpacity(0.3 + brightness * 0.7)
            ..blendMode = BlendMode.plus,
        );
      }
    }

    // Draw theme-specific floating objects
    for (final object in _objects) {
      object.render(canvas, _time);
    }
  }

  @override
  void update(double dt) {
    _time += dt;

    // Update star positions for space theme
    if (stageType == 'space') {
      for (final star in _stars) {
        star.y += star.speed * dt;
        if (star.y > gameRef.size.y) {
          star.y = 0;
          star.x = _random.nextDouble() * gameRef.size.x;
        }
      }
    }

    // Update floating objects
    for (final object in _objects) {
      object.update(dt, gameRef.size);
    }
  }

  Shader _getBackgroundGradient(Rect rect) {
    switch (stageType) {
      case 'space':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B1026),
            Colors.purple[900]!,
          ],
        ).createShader(rect);
      case 'cyber':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.purple[700]!,
            Colors.blue[900]!,
          ],
        ).createShader(rect);
      case 'forest':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue[300]!,
            Colors.green[700]!,
          ],
        ).createShader(rect);
      case 'volcano':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red[900]!,
            Colors.orange[900]!,
            Colors.red[900]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);
      case 'ice':
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.lightBlue[200]!,
          ],
        ).createShader(rect);
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[900]!,
            Colors.purple[900]!,
          ],
        ).createShader(rect);
    }
  }
}

class _Star {
  double x;
  double y;
  final double size;
  final double speed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _FloatingObject {
  double x;
  double y;
  final double size;
  final double speed;
  final String type;
  double _angle = 0;

  _FloatingObject({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.type,
  });

  void update(double dt, Vector2 screenSize) {
    _angle += dt;
    y += speed * dt;
    if (y > screenSize.y + size) {
      y = -size;
      x = Random().nextDouble() * screenSize.x;
    }
  }

  void render(Canvas canvas, double time) {
    final paint = Paint();
    final path = Path();
    
    switch (type) {
      case 'space':
        // Draw asteroids
        paint.color = Colors.grey[700]!;
        canvas.drawCircle(Offset(x, y), size * 0.5, paint);
        break;
        
      case 'cyber':
        // Draw neon shapes
        paint
          ..color = Colors.cyan.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        path.addPolygon([
          Offset(x, y - size * 0.5),
          Offset(x + size * 0.4, y + size * 0.3),
          Offset(x - size * 0.4, y + size * 0.3),
        ], true);
        canvas.drawPath(path, paint);
        break;
        
      case 'forest':
        // Draw leaves
        paint.color = Colors.green[300]!.withOpacity(0.6);
        path.moveTo(x, y - size * 0.5);
        path.quadraticBezierTo(x + size * 0.5, y, x, y + size * 0.5);
        path.quadraticBezierTo(x - size * 0.5, y, x, y - size * 0.5);
        canvas.drawPath(path, paint);
        break;
        
      case 'volcano':
        // Draw lava particles
        final particleColor = HSLColor.fromColor(Colors.orange)
          .withLightness(0.5 + sin(time * 3 + x) * 0.2)
          .toColor();
        paint.color = particleColor.withOpacity(0.6);
        
        // Draw ember effect
        canvas.drawCircle(
          Offset(
            x + sin(time * 2 + y) * 5,
            y + cos(time * 2 + x) * 5,
          ),
          size * 0.3,
          paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
        
        // Draw glowing core
        canvas.drawCircle(
          Offset(x, y),
          size * 0.15,
          paint..color = Colors.white.withOpacity(0.8),
        );
        break;
        
      case 'ice':
        // Draw snowflakes
        paint.color = Colors.white.withOpacity(0.6);
        for (var i = 0; i < 6; i++) {
          final angle = i * pi / 3;
          canvas.drawLine(
            Offset(x, y),
            Offset(x + cos(angle) * size * 0.5, y + sin(angle) * size * 0.5),
            paint,
          );
        }
        break;
    }
  }
} 