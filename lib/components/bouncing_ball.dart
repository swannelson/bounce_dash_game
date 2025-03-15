import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../managers/power_up_manager.dart';

class BouncingBall extends PositionComponent with HasGameRef {
  bool hasShield = false;
  bool hasJetpack = true;
  bool _isThrusting = false;
  double _currentSize = 50;
  double _velocity = 0;
  double _tailAngle = 0;
  double _tailSpeed = 2.0;
  double _blinkTimer = 0;
  bool _eyesClosed = false;
  
  static const double gravity = 800;
  static const double thrustForce = -1000;
  static const double maxVelocity = 800;
  static const double fallDamping = 0.985;
  
  // Cat colors - simplified palette
  final Color _mainColor = Color(0xFFFF9800);        // Bright orange
  final Color _darkColor = Color(0xFF4A4A4A);        // Dark grey for details
  final Color _eyeColor = Color(0xFFFFEB3B);         // Bright yellow for eyes
  
  BouncingBall()
      : super(
          size: Vector2(60, 60),  // Increased size for better visibility on mobile
          anchor: Anchor.center,
        );

  double get currentSize => _currentSize;

  void updateSize(double newSize) {
    _currentSize = newSize;
    size.setFrom(Vector2(newSize, newSize));
  }

  @override
  Future<void> onLoad() async {
    _currentSize = 60; // Increased default size
    await super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    
    // Draw jetpack if active
    if (hasJetpack) {
      final jetpack = Path()
        ..moveTo(center.dx - radius * 0.8, center.dy - radius * 0.3)
        ..lineTo(center.dx - radius * 0.8, center.dy + radius * 0.3)
        ..lineTo(center.dx - radius * 0.6, center.dy + radius * 0.3)
        ..lineTo(center.dx - radius * 0.6, center.dy - radius * 0.3)
        ..close();
      
      canvas.drawPath(
        jetpack,
        Paint()..color = Colors.grey[800]!,
      );
      
      if (_isThrusting) {
        final flame = Path()
          ..moveTo(center.dx - radius * 0.7, center.dy + radius * 0.3)
          ..lineTo(center.dx - radius * 0.8, center.dy + radius * 0.8)
          ..lineTo(center.dx - radius * 0.6, center.dy + radius * 0.8)
          ..close();
        
        canvas.drawPath(
          flame,
          Paint()..color = Colors.orange,
        );
      }
    }

    // Draw main body (circular)
    canvas.drawCircle(
      center,
      radius * 0.9,
      Paint()..color = _mainColor,
    );

    // Draw ears (triangular)
    final leftEar = Path()
      ..moveTo(center.dx - radius * 0.5, center.dy - radius * 0.5)
      ..lineTo(center.dx - radius * 0.7, center.dy - radius * 0.9)
      ..lineTo(center.dx - radius * 0.3, center.dy - radius * 0.5)
      ..close();

    final rightEar = Path()
      ..moveTo(center.dx + radius * 0.5, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 0.7, center.dy - radius * 0.9)
      ..lineTo(center.dx + radius * 0.3, center.dy - radius * 0.5)
      ..close();

    canvas.drawPath(leftEar, Paint()..color = _mainColor);
    canvas.drawPath(rightEar, Paint()..color = _mainColor);

    // Draw eyes
    if (!_eyesClosed) {
      // Large oval eyes
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.1),
          width: radius * 0.4,
          height: radius * 0.5,
        ),
        Paint()..color = _eyeColor,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.1),
          width: radius * 0.4,
          height: radius * 0.5,
        ),
        Paint()..color = _eyeColor,
      );

      // Pupils (react to velocity)
      final pupilSize = radius * (0.15 - _velocity.abs() / 10000);
      canvas.drawCircle(
        Offset(center.dx - radius * 0.25, center.dy - radius * 0.1),
        pupilSize,
        Paint()..color = _darkColor,
      );
      canvas.drawCircle(
        Offset(center.dx + radius * 0.25, center.dy - radius * 0.1),
        pupilSize,
        Paint()..color = _darkColor,
      );
    } else {
      // Closed eyes (simple curved lines)
      final eyePaint = Paint()
        ..color = _darkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.1),
          width: radius * 0.3,
          height: radius * 0.3,
        ),
        0,
        math.pi,
        false,
        eyePaint,
      );

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.1),
          width: radius * 0.3,
          height: radius * 0.3,
        ),
        0,
        math.pi,
        false,
        eyePaint,
      );
    }

    // Draw nose (small triangle)
    final nose = Path()
      ..moveTo(center.dx, center.dy + radius * 0.1)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.2)
      ..lineTo(center.dx + radius * 0.1, center.dy + radius * 0.2)
      ..close();

    canvas.drawPath(
      nose,
      Paint()..color = _darkColor,
    );

    // Draw mouth (simple curved line)
    final mouthPaint = Paint()
      ..color = _darkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.3),
        width: radius * 0.4,
        height: radius * 0.3,
      ),
      0,
      math.pi,
      false,
      mouthPaint,
    );

    // Draw whiskers
    final whiskerPaint = Paint()
      ..color = _darkColor
      ..strokeWidth = 2;

    // Left whiskers
    canvas.drawLine(
      Offset(center.dx - radius * 0.3, center.dy + radius * 0.2),
      Offset(center.dx - radius * 0.8, center.dy + radius * 0.1),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.3, center.dy + radius * 0.2),
      Offset(center.dx - radius * 0.8, center.dy + radius * 0.3),
      whiskerPaint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.2),
      Offset(center.dx + radius * 0.8, center.dy + radius * 0.1),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.2),
      Offset(center.dx + radius * 0.8, center.dy + radius * 0.3),
      whiskerPaint,
    );

    // Draw tail
    final tailStart = Offset(center.dx + radius * 0.7, center.dy + radius * 0.5);
    final tailEnd = Offset(
      tailStart.dx + radius * math.cos(_tailAngle) * 0.5,
      tailStart.dy + radius * math.sin(_tailAngle) * 0.5,
    );
    final tailControl = Offset(
      tailStart.dx + radius * 0.25,
      tailStart.dy - radius * 0.25,
    );

    final tail = Path()
      ..moveTo(tailStart.dx, tailStart.dy)
      ..quadraticBezierTo(
        tailControl.dx,
        tailControl.dy,
        tailEnd.dx,
        tailEnd.dy,
      );

    canvas.drawPath(
      tail,
      Paint()
        ..color = _mainColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.2,
    );
  }

  void onTapDown() {
    if (hasJetpack) {
      _isThrusting = true;
    }
  }

  void onTapUp() {
    _isThrusting = false;
  }

  @override
  void update(double dt) {
    // Apply gravity
    if (_isThrusting && hasJetpack) {
      _velocity = (_velocity + thrustForce * dt).clamp(-maxVelocity, maxVelocity);
    } else {
      _velocity = (_velocity + gravity * dt).clamp(-maxVelocity, maxVelocity);
      // Apply damping when falling for more natural movement
      if (_velocity > 0) {
        _velocity *= fallDamping;
      }
    }
    
    position.y += _velocity * dt;

    // Animate tail
    _tailAngle += _tailSpeed * dt;
    if (_tailAngle > 2 * math.pi) {
      _tailAngle -= 2 * math.pi;
    }
    
    // Blinking animation
    _blinkTimer += dt;
    if (_blinkTimer > 3.0) {
      _eyesClosed = true;
      if (_blinkTimer > 3.15) {
        _eyesClosed = false;
        _blinkTimer = 0;
      }
    }

    // Keep the ball within the screen bounds
    if (position.y < size.y / 2) {
      position.y = size.y / 2;
      _velocity = 0;
    }
    if (position.y > gameRef.size.y - size.y / 2) {
      position.y = gameRef.size.y - size.y / 2;
      _velocity = 0;
    }
  }

  void applyPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        hasShield = true;
        Future.delayed(const Duration(seconds: 5), () {
          hasShield = false;
        });
        break;
      case PowerUpType.miniBall:
        final originalSize = _currentSize;
        updateSize(_currentSize * 0.5);
        Future.delayed(const Duration(seconds: 5), () {
          updateSize(originalSize);
        });
        break;
      case PowerUpType.slowMotion:
        // Handled by game
        break;
    }
  }

  void reset() {
    _velocity = 0;
    _isThrusting = false;
    hasShield = false;
    hasJetpack = true;
    updateSize(60); // Reset to larger size
  }
} 