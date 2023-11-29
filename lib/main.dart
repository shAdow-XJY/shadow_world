import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shadow World',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const RolePage(),
    );
  }
}

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _position = const Offset(100, 100); // 初始位置
  final double _speed = 200.0; // 每秒移动的像素数
  AnimationState _animationState = AnimationState.stand; // 新增动画状态变量

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(begin: _position, end: _position).animate(_controller)
      ..addListener(() {
        var targetPos = _animation.value;
        var currentPos = _position;
        _updateAnimationState(targetPos, currentPos); // 更新动画状态
        setState(() {});
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animationState = AnimationState.stand;
        });
      }
    });
  }

  void _moveRole(TapUpDetails details) {
    final targetPos = details.localPosition;
    final currentPos = _animation.value; // 获取当前动画的实际位置
    final distance = (targetPos - currentPos).distance;

    if (distance > 0) {
      final durationInSeconds = distance / _speed;
      _controller.duration = Duration(milliseconds: (durationInSeconds * 1000).round());

      _animation = Tween<Offset>(begin: currentPos, end: targetPos).animate(_controller);
      _controller
        ..reset()
        ..forward();

      // 更新动画状态
      _updateAnimationState(targetPos, currentPos);
    }

    _position = targetPos;
  }

  void _updateAnimationState(Offset targetPos, Offset currentPos) {
    if (targetPos.dx < currentPos.dx) {
      _animationState = AnimationState.moveLeft;
    } else if (targetPos.dx > currentPos.dx) {
      _animationState = AnimationState.moveRight;
    } else {
      _animationState = AnimationState.stand;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shadow World'),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/background.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          GestureDetector(
            onTapUp: _moveRole,
            child: CustomPaint(
              painter: RolePainter(
                position: _animation.value,
                animationState: _animationState, progress: _controller.value, // 传递动画状态
              ),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

// 动画状态枚举
enum AnimationState {
  stand,
  moveLeft,
  moveRight
}

class RolePainter extends CustomPainter {
  final Offset position;
  final AnimationState animationState;
  final double progress;

  RolePainter({
    required this.position,
    this.animationState = AnimationState.stand,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (animationState) {
      case AnimationState.stand:
        _drawStandingRole(canvas);
        break;
      case AnimationState.moveLeft:
      case AnimationState.moveRight:
        _drawMovingRole(canvas);
        break;
    }
  }

  void _drawStandingRole(Canvas canvas) {
    // 绘制站立状态的火柴人
    var paint = Paint()..color = Colors.black;
    // 绘制火柴人
    paint.color = Colors.black; // 设置火柴人的颜色
    var headCenter = Offset(position.dx, position.dy - 30); // 头部位置稍微在小球上方
    var headRadius = 10.0; // 头部半径
    canvas.drawCircle(headCenter, headRadius, paint); // 绘制头部

    var bodyStart = Offset(headCenter.dx, headCenter.dy + headRadius);
    var bodyEnd = Offset(bodyStart.dx, bodyStart.dy + 20);
    canvas.drawLine(bodyStart, bodyEnd, paint); // 绘制身体

    // 绘制手臂
    var armStart = Offset(bodyStart.dx, bodyStart.dy + 5);
    canvas.drawLine(armStart, Offset(armStart.dx + 10, armStart.dy + 10), paint); // 绘制右手臂
    canvas.drawLine(Offset(armStart.dx - 10, armStart.dy + 10), armStart, paint); // 绘制左手臂

    // 绘制腿部（包括膝盖）
    var legStart = bodyEnd;
    var kneeRight = Offset(legStart.dx + 5, legStart.dy + 10); // 右膝盖
    var kneeLeft = Offset(legStart.dx - 5, legStart.dy + 10); // 左膝盖
    var footRight = Offset(kneeRight.dx, kneeRight.dy + 10); // 右脚
    var footLeft = Offset(kneeLeft.dx, kneeLeft.dy + 10); // 左脚
    canvas.drawLine(legStart, kneeRight, paint); // 右大腿
    canvas.drawLine(kneeRight, footRight, paint); // 右小腿
    canvas.drawLine(legStart, kneeLeft, paint); // 左大腿
    canvas.drawLine(kneeLeft, footLeft, paint); // 左小腿
  }

  void _drawMovingRole(Canvas canvas) {
    // 绘制移动状态的火柴人
    var paint = Paint()..color = Colors.black;
    // 绘制火柴人
    paint.color = Colors.black; // 设置火柴人的颜色
    var headCenter = Offset(position.dx, position.dy - 30); // 头部位置稍微在小球上方
    var headRadius = 10.0; // 头部半径
    canvas.drawCircle(headCenter, headRadius, paint); // 绘制头部

    var bodyStart = Offset(headCenter.dx, headCenter.dy + headRadius);
    var bodyEnd = Offset(bodyStart.dx, bodyStart.dy + 20);
    canvas.drawLine(bodyStart, bodyEnd, paint); // 绘制身体

    // 绘制手臂
    var armStart = Offset(bodyStart.dx, bodyStart.dy + 5);
    canvas.drawLine(armStart, Offset(armStart.dx + 10, armStart.dy + 10), paint); // 绘制右手臂
    canvas.drawLine(Offset(armStart.dx - 10, armStart.dy + 10), armStart, paint); // 绘制左手臂

    // 腿部
    var legsLength = 15.0;
    var legLeftStart = bodyEnd;
    var legRightStart = bodyEnd;
    var legMovement = sin(progress * 2 * pi) * 10; // 大腿左右移动的幅度

    // 大腿的动态位置
    var kneeLeft = legLeftStart.translate(legMovement, 0);
    var kneeRight = legRightStart.translate(-legMovement, 0);

    // 小腿保持竖直
    var legLeftEnd = kneeLeft.translate(0, legsLength);
    var legRightEnd = kneeRight.translate(0, legsLength);

    // 绘制腿部
    canvas.drawLine(legLeftStart, kneeLeft, paint); // 左大腿
    canvas.drawLine(kneeLeft, legLeftEnd, paint); // 左小腿
    canvas.drawLine(legRightStart, kneeRight, paint); // 右大腿
    canvas.drawLine(kneeRight, legRightEnd, paint); // 右小腿
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

