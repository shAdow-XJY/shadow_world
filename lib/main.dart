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
      home: const BallPage(),
    );
  }
}

class BallPage extends StatefulWidget {
  const BallPage({super.key});

  @override
  State<BallPage> createState() => _BallPageState();
}

class _BallPageState extends State<BallPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _position = Offset(100, 100); // 初始位置
  final double _speed = 200.0; // 每秒移动的像素数

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // 初始持续时间
    );

    _animation = Tween<Offset>(
      begin: _position,
      end: _position,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  void _moveBall(TapUpDetails details) {
    final targetPos = details.localPosition;
    final currentPos = _animation.value; // 获取当前动画的实际位置
    final distance = (targetPos - currentPos).distance;

    if (distance > 0) {
      final durationInSeconds = distance / _speed;
      _controller.duration = Duration(milliseconds: (durationInSeconds * 1000).round());

      _animation = Tween<Offset>(
        begin: currentPos,
        end: targetPos,
      ).animate(_controller)
        ..addListener(() {
          setState(() {});
        });

      _controller
        ..reset()
        ..forward();
    }

    _position = targetPos;
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
        title: Text('Shadow World'),
      ),
      body: GestureDetector(
        onTapUp: _moveBall,
        child: CustomPaint(
          painter: BallPainter(_animation.value),
          child: Container(),
        ),
      ),
    );
  }
}

class BallPainter extends CustomPainter {
  final Offset position;

  BallPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.blue;
    canvas.drawCircle(position, 20, paint); // 小球大小为20
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}