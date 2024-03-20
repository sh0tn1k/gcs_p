import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../plane_data.dart';


double _rad(double deg) => deg * math.pi / 180.0;
double _deg(double rad) => rad * 180.0 / math.pi;

const kATT_SIZE = 351.0;
const kROLL_LIM = 45.0;
const kDISP_PITCH_LIM = 30;

late Rect _altRect;


class AttitudeIndicatorRus extends StatelessWidget {
  final double width;
  final double height;
  const AttitudeIndicatorRus({this.width = kATT_SIZE, this.height = kATT_SIZE, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
              constraints: BoxConstraints(minWidth: width, minHeight: height),
              child:
                GestureDetector(
                    onTapDown: (details) {
                      final box = context.findRenderObject()as RenderBox; 
                      // find the coordinate
                      final localOffset = box.globalToLocal(details.globalPosition); 
                      if(_altRect.contains(localOffset)) {
                        print("Altitude indicator pressed");
                      }
                    },
                    child: CustomPaint(painter: AttitudeRusPainter()),
                  ), 
    );
  }
}


class AttitudeRusPainter extends CustomPainter {

  double roll = 0;
  double pitch = 0;
  int asp = 0;
  int alt = 0;
  int vs = 0;


  void _drawAirplane(Offset c, Canvas canvas, Color color) {
    //
    // roll in radians!
    //

    final paint = Paint();

    paint.style = PaintingStyle.stroke;
    paint.color = color;
    paint.strokeWidth = 4;

    canvas.save();
    canvas.rotate(roll);
    canvas.drawCircle(c, 10, paint);
    canvas.drawLine(Offset(c.dx,      c.dy - 10), Offset(c.dx,      c.dy - 30), paint);
    canvas.drawLine(Offset(c.dx,      c.dy + 10), Offset(c.dx + 40, c.dy),      paint);
    canvas.drawLine(Offset(c.dx + 40, c.dy),      Offset(c.dx + 80, c.dy),      paint);
    canvas.drawLine(Offset(c.dx + 40, c.dy),      Offset(c.dx + 40, c.dy + 10), paint);
    canvas.drawLine(Offset(c.dx,      c.dy + 10), Offset(c.dx - 40, c.dy),      paint);
    canvas.drawLine(Offset(c.dx - 40, c.dy),      Offset(c.dx - 80, c.dy),      paint);
    canvas.drawLine(Offset(c.dx - 40, c.dy),      Offset(c.dx - 40, c.dy + 10), paint);
    canvas.restore();
  }


  void _drawDashedLine(
              {required Canvas canvas,
              required Offset p1,
              required Offset p2,
              required int dashWidth,
              required int dashSpace,
              required Paint paint}) {
    // Get normalized distance vector from p1 to p2
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    final magnitude = math.sqrt(dx * dx + dy * dy);
    dx = dx / magnitude;
    dy = dy / magnitude;

    // Compute number of dash segments
    final steps = magnitude ~/ (dashWidth + dashSpace);

    var startX = p1.dx;
    var startY = p1.dy;

    for (int i = 0; i < steps; i++) {
      final endX = startX + dx * dashWidth;
      final endY = startY + dy * dashWidth;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
    }
  }


  void _drawText(
            {required Canvas canvas,
              required String text,
              required Offset p,
              required double maxWidth,
              required Color color,
              required Paint paint,
              int dirx = 0, int diry = 0 }) {

    final textStyle = TextStyle(
      color: color,
      fontSize: 14,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: maxWidth,
    );
    //print("asp.w = ${textPainter.width}");
    double dx = p.dx;
    if(dirx < 0) {
      dx -= textPainter.width - (-dirx);
    }
    else if(dirx > 0) {
      dx += dirx;
    }

    double dy;
    if(diry < 0) {
      dy = p.dy - textPainter.height - (-diry);
    }
    else if(diry > 0) {
      dy = p.dy + diry;
    }
    else {
      dy = p.dy - textPainter.height / 2;
    }

    var offsett = Offset(dx, dy);

    textPainter.paint(canvas, offsett);
  }


  @override
  void paint(Canvas canvas, Size size) {

    if(planeData.ahrs2 != null) {
      roll = planeData.ahrs2!.roll;
      pitch = planeData.ahrs2!.pitch;
      alt = planeData.ahrs2!.altitude.round();
      asp = (planeData.vfrHud!.airspeed * 3.6).round();
    } else {
      roll = 0;
      pitch = 0;
      asp = 0;
      alt = 0;
      vs = 0;
    }


    final c = Offset(size.width / 2, size.height / 2);

    final skyHeight = c.dy * 180 / kDISP_PITCH_LIM;
    var dy = c.dy + (c.dy * _deg(pitch)) / kDISP_PITCH_LIM;
    final hor = Offset(size.width / 2, dy);

    canvas.clipRRect(RRect.fromRectAndCorners(
                                Rect.fromLTWH(0, 0, size.width, size.height),
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft: const Radius.circular(10),
                                bottomRight: const Radius.circular(10)));

    Paint paint = Paint();

    //
    // Sky
    //
    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue.shade800;
    canvas.drawRect(Rect.fromLTWH(0, hor.dy - skyHeight, size.width, skyHeight), paint);
    dy = (c.dy * 15) / kDISP_PITCH_LIM;
    paint.shader = ui.Gradient.linear(
                        Offset(0, hor.dy - dy),
                        Offset(0, hor.dy),
                        [Colors.blue.shade800, Colors.blue.shade300]);
    canvas.drawRect(Rect.fromLTWH(0, hor.dy - dy, size.width, dy), paint);
    paint.shader = null;

    //
    // Ground
    //
    paint.style = PaintingStyle.fill;
    paint.color = Colors.brown.shade700;
    canvas.drawRect(Rect.fromLTWH(0, hor.dy, size.width, skyHeight), paint);
    paint.shader = ui.Gradient.linear(
                        Offset(0, hor.dy),
                        Offset(0, hor.dy + dy),
                        [Colors.brown.shade300, Colors.brown.shade700]);
    canvas.drawRect(Rect.fromLTWH(0, hor.dy, size.width, dy), paint);
    paint.shader = null;

    //
    // Pitch marks
    //
    const pitchStep = 5;
    const pitchLine10 = 60.0;
    const pitchLine5 = 30.0;
    
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.blue.shade200;

    dy = hor.dy;
    for(var a = 0; a <= 90; a += pitchStep) {
      if(a != 0 && dy > 15) {
        var pp = (a % 10 == 0) ? pitchLine10 : pitchLine5;
        canvas.drawLine(Offset(c.dx - pp, dy), Offset(c.dx + pp, dy), paint);
      }
      dy -= (c.dy * pitchStep) / kDISP_PITCH_LIM;
    }

    paint.color = Colors.brown.shade200;
    dy = hor.dy;
    for(var a = 0; a <= 90; a += pitchStep) {
      if(a != 0 && dy > 15) {
        var pp = (a % 10 == 0) ? pitchLine10 : pitchLine5;
        _drawDashedLine(
            canvas: canvas,
            p1: Offset(c.dx - pp, dy),
            p2: Offset(c.dx + pp, dy),
            dashWidth: 6,
            dashSpace: 6,
            paint: paint);
      }
      dy += (c.dy * pitchStep) / kDISP_PITCH_LIM;
    }



    canvas.translate(c.dx, c.dy);

    //
    // Draw roll arc
    //
    final rl = _rad(kROLL_LIM);

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    canvas.drawArc(
              //Rect.fromLTWH(-c.dx + 10, -c.dy + 10, size.width - 20, size.height - 20),
              Rect.fromLTWH(-c.dy + 10, -c.dy + 10, size.height - 20, size.height - 20),
              _rad(270 - kROLL_LIM),
              rl * 2,
              false,
              paint);
    canvas.save();
    canvas.rotate(-rl);
    for(var i = 0; i <= kROLL_LIM * 2; i += 15) {
      canvas.drawLine(Offset(0, -c.dy + 10), Offset(0, -c.dy + 10 + 6), paint);
      canvas.rotate(_rad(15));
    }
    canvas.restore();

    //
    // Draw roll pointer
    //
    canvas.save();
    if(roll >= -rl && roll <= rl)
    {
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white;
      paint.strokeWidth = 1;
      var path = Path();
      path.moveTo(0, -c.dy + 10);
      path.relativeLineTo(5, 16);
      path.relativeLineTo(-10, 0);
      path.relativeLineTo(5, -16);
      path.close();
      canvas.rotate(roll);
      canvas.drawPath(path, paint);
    }
    canvas.restore();

    //
    // Airplane
    //
    _drawAirplane(Offset(1, 1), canvas, Colors.black);  // TODO drawShadow
    _drawAirplane(Offset.zero, canvas, Colors.yellow);  // TODO Draw airplane with the drawPath
    

    canvas.translate(-c.dx, -c.dy);

    //
    // Text Indicators (air speed, altitude etc)
    //
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: 'Meslo'
    );

    //
    // Air speed
    //
    const kASP_MARGIN = 10.0;
    const kASP_WIDTH = 36.0 + 10 + 10;
    const kASP_HEIGHT = 30.0;

    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue.shade900;
    canvas.drawRect(Rect.fromLTWH(kASP_MARGIN, c.dy - kASP_HEIGHT / 2, kASP_WIDTH, kASP_HEIGHT), paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(kASP_MARGIN, c.dy - kASP_HEIGHT / 2, kASP_WIDTH, kASP_HEIGHT), paint);

    {
      final textSpan = TextSpan(
        text: asp.toString().padRight(3, ' '),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      //print("asp.w = ${textPainter.width}");
      var offset = Offset(kASP_MARGIN + 10, c.dy - textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }
    _drawText(
          canvas: canvas,
          text: "ВС",
          p: Offset(kASP_MARGIN + 5, c.dy - kASP_HEIGHT / 2 - 10),
          maxWidth: kASP_WIDTH,
          color: Colors.white70,
          paint: paint);
    _drawText(
          canvas: canvas,
          text: "км/ч",
          p: Offset(kASP_MARGIN + 5, c.dy + kASP_HEIGHT / 2 + 10),
          maxWidth: kASP_WIDTH,
          color: Colors.white70,
          paint: paint);


    //
    // Altitude
    //
    const kALT_MARGIN = 20.0;
    const kALT_WIDTH = 48.0 + 10 + 10;
    const kALT_HEIGHT = 30.0;

    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue.shade900;
    final r = Rect.fromLTWH(size.width - kALT_WIDTH - kALT_MARGIN, c.dy - kALT_HEIGHT / 2, kALT_WIDTH, kALT_HEIGHT);
    canvas.drawRect(r, paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    canvas.drawRect(r, paint);
    _altRect = r; // TODO To check the tap coordinates

    {
      final textSpan = TextSpan(
        text: alt.toInt().toString().padLeft(4, ' '),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      //print("alt.w = ${textPainter.width}");
      var offset = Offset(size.width - kALT_WIDTH - kALT_MARGIN + 10, c.dy - textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }
    _drawText(
          canvas: canvas,
          text: "Выс",
          p: Offset(size.width - kALT_MARGIN - 5, c.dy - kALT_HEIGHT / 2 - 10),
          maxWidth: kASP_WIDTH,
          color: Colors.white70,
          dirx: -1,
          paint: paint);

    _drawText(
          canvas: canvas,
          text: "м",
          p: Offset(size.width - kALT_MARGIN - 5, c.dy + kALT_HEIGHT / 2 + 10),
          maxWidth: kASP_WIDTH,
          color: Colors.white70,
          dirx: -1,
          paint: paint);



    // paint.style = PaintingStyle.stroke;
    // paint.color = Colors.yellow;
    // paint.strokeWidth = 2;
    // canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    // canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final AttitudeRusPainter old = oldDelegate as AttitudeRusPainter;
    if(old.roll != roll || old.pitch != pitch || old.asp != asp || old.alt != alt || old.vs != vs) {
      return true;
    }
    return false;
  }
}