import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'scalebar_utils.dart';

class FlutterMapScaleLayer extends StatelessWidget {
  static const scale = <int>[
    25000000,
    15000000,
    8000000,
    4000000,
    2000000,
    1000000,
    500000,
    250000,
    100000,
    50000,
    25000,
    15000,
    8000,
    4000,
    2000,
    1000,
    500,
    250,
    100,
    50,
    25,
    10,
    5
  ];
  final TextStyle? textStyle;
  final Color lineColor;
  final double lineWidth;
  final EdgeInsets padding;

  const FlutterMapScaleLayer({
    super.key,
    this.textStyle,
    this.lineColor = Colors.white,
    this.lineWidth = 2,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final distance = scale[max(0, min(20, camera.zoom.round() + 2))].toDouble();
    final center = camera.center;
    final start = camera.project(center);
    final targetPoint = calculateEndingGlobalCoordinates(center, 90, distance);
    final end = camera.project(targetPoint);
    final displayDistance = distance > 999
        ? '${(distance / 1000).toStringAsFixed(0)} km'
        : '${distance.toStringAsFixed(0)} m';
    final width = end.x - start.x;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = EdgeInsets.fromLTRB(
                      padding.left,
                      constraints.maxHeight - padding.top - 100,
                      padding.right,
                      padding.bottom);
        return CustomPaint(
          painter: ScalePainter(
            width,
            displayDistance,
            lineColor: lineColor,
            lineWidth: lineWidth,
            padding: pad,
            textStyle: textStyle,
          ),
        );
      },
    );
  }
}

class ScalePainter extends CustomPainter {
  ScalePainter(
    this.width,
    this.text, {
    this.padding = const EdgeInsets.all(10),
    this.textStyle,
    required this.lineWidth,
    required this.lineColor,
  });

  final double width;
  final EdgeInsets padding;
  final String text;
  final double lineWidth;
  final Color lineColor;
  TextStyle? textStyle;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.square
      ..strokeWidth = lineWidth;

    const sizeForStartEnd = 4;
    final paddingLeft = padding.left + sizeForStartEnd / 2;
    var paddingTop = padding.top;

    final textSpan = TextSpan(style: textStyle, text: text);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas,
        Offset(width / 2 - textPainter.width / 2 + paddingLeft, paddingTop));
    paddingTop += textPainter.height;
    final p1 = Offset(paddingLeft, sizeForStartEnd + paddingTop);
    final p2 = Offset(paddingLeft + width, sizeForStartEnd + paddingTop);
    // draw start line
    canvas.drawLine(Offset(paddingLeft, paddingTop),
        Offset(paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw middle line
    final middleX = width / 2 + paddingLeft - lineWidth / 2;
    canvas.drawLine(Offset(middleX, paddingTop + sizeForStartEnd / 2),
        Offset(middleX, sizeForStartEnd + paddingTop), paint);
    // draw end line
    canvas.drawLine(Offset(width + paddingLeft, paddingTop),
        Offset(width + paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw bottom line
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
