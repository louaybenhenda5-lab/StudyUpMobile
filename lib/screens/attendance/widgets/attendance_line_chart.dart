import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/attendance_ui_models.dart';

/// "Attendance Over Time" line chart drawn with CustomPainter
/// (no new chart dependency).
class AttendanceLineChart extends StatelessWidget {
  final List<AttendancePoint> points;

  const AttendanceLineChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (points.isEmpty) {
      return Container(
        height: 170,
        alignment: Alignment.center,
        child: Text(
          'Not enough history yet',
          style: TextStyle(fontSize: 13, color: colors.subtitleText),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(
            painter: _LineChartPainter(
              values: points.map((p) => p.value.clamp(0.0, 100.0)).toList(),
              lineColor: const Color(0xFF2E7CF6),
              gridColor: colors.dividerColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final p in points)
              Expanded(
                child: Text(
                  p.label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, color: colors.subtitleText),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values; // 0..100
  final Color lineColor;
  final Color gridColor;

  _LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padLeft = 4.0;
    const padRight = 8.0;
    const padTop = 10.0;
    const padBottom = 10.0;

    final w = size.width - padLeft - padRight;
    final h = size.height - padTop - padBottom;

    // Grid: 4 horizontal lines (0/33/66/100).
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = padTop + h * i / 3;
      canvas.drawLine(
        Offset(padLeft, y),
        Offset(padLeft + w, y),
        gridPaint,
      );
    }

    if (values.isEmpty) return;

    double xAt(int i) {
      if (values.length == 1) return padLeft + w / 2;
      return padLeft + w * i / (values.length - 1);
    }

    double yAt(double v) => padTop + h * (1 - v / 100);

    // Area fill.
    final areaPath = Path();
    areaPath.moveTo(xAt(0), yAt(values[0]));
    for (var i = 1; i < values.length; i++) {
      areaPath.lineTo(xAt(i), yAt(values[i]));
    }
    if (values.length > 1) {
      areaPath.lineTo(xAt(values.length - 1), padTop + h);
      areaPath.lineTo(xAt(0), padTop + h);
      areaPath.close();
      canvas.drawPath(
        areaPath,
        Paint()..color = lineColor.withValues(alpha: 0.12),
      );
    }

    // Line.
    final linePath = Path();
    linePath.moveTo(xAt(0), yAt(values[0]));
    for (var i = 1; i < values.length; i++) {
      linePath.lineTo(xAt(i), yAt(values[i]));
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots.
    for (var i = 0; i < values.length; i++) {
      final c = Offset(xAt(i), yAt(values[i]));
      canvas.drawCircle(c, 6, Paint()..color = lineColor.withValues(alpha: 0.18));
      canvas.drawCircle(c, 3.5, Paint()..color = lineColor);
      canvas.drawCircle(c, 3.5, Paint()..color = lineColor);
      canvas.drawCircle(
          c, 1.6, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor;
}
