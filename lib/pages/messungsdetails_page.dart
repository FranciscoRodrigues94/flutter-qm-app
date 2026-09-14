import 'package:flutter/material.dart';

class MessungsdetailsPage extends StatelessWidget {
  final dynamic measurement;

  const MessungsdetailsPage({
    super.key,
    required this.measurement,
  });

  // ============================================================
  // BEZUG / REFERENZ
  // ============================================================

  static const double bezugL = 55.00;
  static const double bezugA = 0.00;
  static const double bezugB = 4.00;

  static const double toleranzL = 1.50;
  static const double toleranzA = 0.40;
  static const double toleranzB = 0.40;

  String formatDate(DateTime date) {
    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.day)}.'
        '${twoDigits(date.month)}.'
        '${date.year} '
        '${twoDigits(date.hour)}:'
        '${twoDigits(date.minute)}';
  }

  // ============================================================
  // TOLERANZPRÜFUNG
  // ============================================================

  bool isLWithinTolerance() {
    final double value = measurement.l.toDouble();

    return value >= bezugL - toleranzL &&
        value <= bezugL + toleranzL;
  }

  bool isAWithinTolerance() {
    final double value = measurement.a.toDouble();

    return value >= bezugA - toleranzA &&
        value <= bezugA + toleranzA;
  }

  bool isBWithinTolerance() {
    final double value = measurement.b.toDouble();

    return value >= bezugB - toleranzB &&
        value <= bezugB + toleranzB;
  }

  bool isMeasurementWithinTolerance() {
    return isLWithinTolerance() &&
        isAWithinTolerance() &&
        isBWithinTolerance();
  }

  // ============================================================
  // ALLGEMEINE DETAILZEILE
  // ============================================================

  Widget detailRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight
                    ? (value == 'Erfüllt'
                        ? const Color(0xFF166534)
                        : const Color(0xFF991B1B))
                    : const Color(0xFF0F172A),
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT BADGE
  // ============================================================

  Widget resultBadge() {
    final bool erfuellt = isMeasurementWithinTolerance();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: erfuellt
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        erfuellt ? 'Erfüllt' : 'Nicht erfüllt',
        style: TextStyle(
          color: erfuellt
              ? const Color(0xFF166534)
              : const Color(0xFF991B1B),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  // ============================================================
  // MESSWERTE
  // ============================================================

  Widget measurementValuesCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              8,
            ),
            child: Text(
              'Messwerte',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          detailRow(
            'L*',
            measurement.l.toStringAsFixed(2),
          ),
          detailRow(
            'a*',
            measurement.a.toStringAsFixed(2),
          ),
          detailRow(
            'b*',
            measurement.b.toStringAsFixed(2),
          ),
          detailRow(
            'ΔL*',
            measurement.deltaL.toStringAsFixed(2),
          ),
          detailRow(
            'Δa*',
            measurement.deltaA.toStringAsFixed(2),
          ),
          detailRow(
            'Δb*',
            measurement.deltaB.toStringAsFixed(2),
          ),
          detailRow(
            'ΔE*',
            measurement.deltaE.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BEZUG
  // ============================================================

  Widget referenceValuesCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              8,
            ),
            child: Text(
              'Bezug',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          detailRow(
            'L*',
            '${bezugL.toStringAsFixed(2)} ± '
                '${toleranzL.toStringAsFixed(2)}',
          ),
          detailRow(
            'a*',
            '${bezugA.toStringAsFixed(2)} ± '
                '${toleranzA.toStringAsFixed(2)}',
          ),
          detailRow(
            'b*',
            '${bezugB.toStringAsFixed(2)} ± '
                '${toleranzB.toStringAsFixed(2)}',
          ),
          detailRow(
            'L*-Bereich',
            '${(bezugL - toleranzL).toStringAsFixed(2)} – '
                '${(bezugL + toleranzL).toStringAsFixed(2)}',
          ),
          detailRow(
            'a*-Bereich',
            '${(bezugA - toleranzA).toStringAsFixed(2)} – '
                '${(bezugA + toleranzA).toStringAsFixed(2)}',
          ),
          detailRow(
            'b*-Bereich',
            '${(bezugB - toleranzB).toStringAsFixed(2)} – '
                '${(bezugB + toleranzB).toStringAsFixed(2)}',
          ),
          detailRow(
            'Lichtart',
            measurement.lichtart.toString(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CIELAB GRAFIK
  // ============================================================

  Widget labChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CIELAB Position',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'a* / b* und Helligkeit L* im Verhältnis zum Bezugsbereich',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: LabChartPainter(
                l: measurement.l.toDouble(),
                a: measurement.a.toDouble(),
                b: measurement.b.toDouble(),
                bezugL: bezugL,
                bezugA: bezugA,
                bezugB: bezugB,
                toleranzL: toleranzL,
                toleranzA: toleranzA,
                toleranzB: toleranzB,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAYOUT
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final DateTime datum = measurement.datum;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F172A),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Messungsdetails',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.science_outlined,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          measurement.artikelnummer.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          measurement.name.toString(),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  resultBadge(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ALLGEMEINE INFORMATIONEN
            // ==================================================

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      8,
                    ),
                    child: Text(
                      'Allgemeine Informationen',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  detailRow(
                    'Artikelnummer',
                    measurement.artikelnummer.toString(),
                  ),
                  detailRow(
                    'Name',
                    measurement.name.toString(),
                  ),
                  detailRow(
                    'Datum',
                    formatDate(datum),
                  ),
                  detailRow(
                    'Benutzer',
                    measurement.benutzer.toString(),
                  ),
                  detailRow(
                    'Lichtart',
                    measurement.lichtart.toString(),
                  ),
                  detailRow(
                    'BA-Nr.',
                    measurement.baNr.toString(),
                  ),
                  detailRow(
                    'Ergebnis',
                    isMeasurementWithinTolerance()
                        ? 'Erfüllt'
                        : 'Nicht erfüllt',
                    highlight: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // MESSWERTE + BEZUG + GRAFIK
            // ==================================================

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1100) {
                  return Column(
                    children: [
                      measurementValuesCard(),
                      const SizedBox(height: 20),
                      referenceValuesCard(),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 520,
                        child: labChartCard(),
                      ),
                    ],
                  );
                }

                return SizedBox(
                  height: 650,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: measurementValuesCard(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: referenceValuesCard(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: labChartCard(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CIELAB PAINTER
// ================================================================

class LabChartPainter extends CustomPainter {
  final double l;
  final double a;
  final double b;

  final double bezugL;
  final double bezugA;
  final double bezugB;

  final double toleranzL;
  final double toleranzA;
  final double toleranzB;

  LabChartPainter({
    required this.l,
    required this.a,
    required this.b,
    required this.bezugL,
    required this.bezugA,
    required this.bezugB,
    required this.toleranzL,
    required this.toleranzA,
    required this.toleranzB,
  });

  double mapValue(
    double value,
    double min,
    double max,
    double start,
    double end,
  ) {
    return start +
        ((value - min) / (max - min)) *
            (end - start);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    const double leftPadding = 60;
    const double rightPadding = 130;
    const double topPadding = 42;
    const double bottomPadding = 58;

    final double left = leftPadding;
    final double right = size.width - rightPadding;
    final double top = topPadding;
    final double bottom = size.height - bottomPadding;

    final double chartWidth = right - left;
    final double chartHeight = bottom - top;

    // ==========================================================
    // a* / b* BEREICH
    // ==========================================================

    final double xMin = bezugA - toleranzA * 2.5;
    final double xMax = bezugA + toleranzA * 2.5;

    final double yMin = bezugB - toleranzB * 2.5;
    final double yMax = bezugB + toleranzB * 2.5;

    // ==========================================================
    // PAINTS
    // ==========================================================

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFE2E8F0);

    final Paint gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFF1F5F9);

    final Paint axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF94A3B8);

    final Paint tolerancePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFDCFCE7);

    final Paint toleranceBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF86EFAC);

    // ==========================================================
    // SEPARATE PRÜFUNG
    // ==========================================================

    final bool lInside =
        l >= bezugL - toleranzL &&
        l <= bezugL + toleranzL;

    final bool aInside =
        a >= bezugA - toleranzA &&
        a <= bezugA + toleranzA;

    final bool bInside =
        b >= bezugB - toleranzB &&
        b <= bezugB + toleranzB;

    final bool abInside =
        aInside && bInside;

    final bool allInside =
        lInside && abInside;

    // Punkt im a*/b* Diagramm:
    //
    // a*/b* OK + L* OK    -> grün
    // a*/b* OK + L* n.i.O -> weiss
    // a*/b* n.i.O         -> rot

    final Color abPointColor;

    if (!abInside) {
      abPointColor = const Color(0xFFDC2626);
    } else if (!lInside) {
      abPointColor = Colors.white;
    } else {
      abPointColor = const Color(0xFF16A34A);
    }

    final Paint measurementPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = abPointColor;

    final Paint measurementBorderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = (!abInside || !lInside)
              ? const Color(0xFFDC2626)
              : Colors.white;

    final Paint referencePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF475569);

    final Paint referenceLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF475569);

    // ==========================================================
    // HINTERGRUND
    // ==========================================================

    final Paint backgroundPaint = Paint()
      ..color = const Color(0xFFFCFDFE);

    canvas.drawRect(
      Rect.fromLTRB(
        left,
        top,
        right,
        bottom,
      ),
      backgroundPaint,
    );

    canvas.drawRect(
      Rect.fromLTRB(
        left,
        top,
        right,
        bottom,
      ),
      borderPaint,
    );

    // ==========================================================
    // GRID
    // ==========================================================

    const int gridCount = 5;

    for (int i = 0; i <= gridCount; i++) {
      final double x =
          left + (chartWidth / gridCount) * i;

      final double y =
          top + (chartHeight / gridCount) * i;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        gridPaint,
      );

      canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        gridPaint,
      );
    }

    // ==========================================================
    // BEZUG POSITION
    // ==========================================================

    final double referenceX = mapValue(
      bezugA,
      xMin,
      xMax,
      left,
      right,
    );

    final double referenceY = mapValue(
      bezugB,
      yMin,
      yMax,
      bottom,
      top,
    );

    canvas.drawLine(
      Offset(referenceX, top),
      Offset(referenceX, bottom),
      axisPaint,
    );

    canvas.drawLine(
      Offset(left, referenceY),
      Offset(right, referenceY),
      axisPaint,
    );

    // ==========================================================
    // TOLERANZBEREICH a* / b*
    // ==========================================================

    final double toleranceLeft = mapValue(
      bezugA - toleranzA,
      xMin,
      xMax,
      left,
      right,
    );

    final double toleranceRight = mapValue(
      bezugA + toleranzA,
      xMin,
      xMax,
      left,
      right,
    );

    final double toleranceTop = mapValue(
      bezugB + toleranzB,
      yMin,
      yMax,
      bottom,
      top,
    );

    final double toleranceBottom = mapValue(
      bezugB - toleranzB,
      yMin,
      yMax,
      bottom,
      top,
    );

    final Rect toleranceRect = Rect.fromLTRB(
      toleranceLeft,
      toleranceTop,
      toleranceRight,
      toleranceBottom,
    );

    canvas.drawRect(
      toleranceRect,
      tolerancePaint,
    );

    canvas.drawRect(
      toleranceRect,
      toleranceBorderPaint,
    );

    // ==========================================================
    // BEZUG PUNKT
    // ==========================================================

    canvas.drawCircle(
      Offset(
        referenceX,
        referenceY,
      ),
      6,
      referencePaint,
    );

    canvas.drawLine(
      Offset(
        referenceX - 10,
        referenceY,
      ),
      Offset(
        referenceX + 10,
        referenceY,
      ),
      referenceLinePaint,
    );

    canvas.drawLine(
      Offset(
        referenceX,
        referenceY - 10,
      ),
      Offset(
        referenceX,
        referenceY + 10,
      ),
      referenceLinePaint,
    );

    // ==========================================================
    // MESSUNGSPUNKT a* / b*
    // ==========================================================

    final double measurementX = mapValue(
      a,
      xMin,
      xMax,
      left,
      right,
    );

    final double measurementY = mapValue(
      b,
      yMin,
      yMax,
      bottom,
      top,
    );

    canvas.drawCircle(
      Offset(
        measurementX,
        measurementY,
      ),
      10,
      measurementPaint,
    );

    canvas.drawCircle(
      Offset(
        measurementX,
        measurementY,
      ),
      10,
      measurementBorderPaint,
    );

    // ==========================================================
    // LABEL MESSUNG a* / b*
    // ==========================================================

    final String abLabelText;

    if (!abInside) {
      abLabelText = 'Messung ✕';
    } else if (!lInside) {
      abLabelText = 'Messung';
    } else {
      abLabelText = 'Messung ✓';
    }

    final Color abLabelColor;

    if (!abInside) {
      abLabelColor = const Color(0xFF991B1B);
    } else if (!lInside) {
      abLabelColor = const Color(0xFF475569);
    } else {
      abLabelColor = const Color(0xFF166534);
    }

    final TextPainter measurementLabel =
        TextPainter(
      text: TextSpan(
        text: abLabelText,
        style: TextStyle(
          color: abLabelColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double labelX = measurementX + 14;

    if (labelX + measurementLabel.width > right) {
      labelX =
          measurementX -
          measurementLabel.width -
          14;
    }

    double labelY =
        measurementY -
        measurementLabel.height -
        12;

    if (labelY < top) {
      labelY = measurementY + 12;
    }

    measurementLabel.paint(
      canvas,
      Offset(
        labelX,
        labelY,
      ),
    );

    // ==========================================================
    // LABEL BEZUG
    // ==========================================================

    final TextPainter bezugLabel =
        TextPainter(
      text: const TextSpan(
        text: 'Bezug',
        style: TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    bezugLabel.paint(
      canvas,
      Offset(
        referenceX + 10,
        referenceY + 10,
      ),
    );

    // ==========================================================
    // AXIS LABELS
    // ==========================================================

    const TextStyle axisTextStyle =
        TextStyle(
      color: Color(0xFF64748B),
      fontSize: 11,
    );

    final List<double> xLabels = [
      xMin,
      bezugA - toleranzA,
      bezugA,
      bezugA + toleranzA,
      xMax,
    ];

    final List<double> yLabels = [
      yMin,
      bezugB - toleranzB,
      bezugB,
      bezugB + toleranzB,
      yMax,
    ];

    for (final value in xLabels) {
      final double x = mapValue(
        value,
        xMin,
        xMax,
        left,
        right,
      );

      final TextPainter painter =
          TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(2),
          style: axisTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          x - painter.width / 2,
          bottom + 8,
        ),
      );
    }

    for (final value in yLabels) {
      final double y = mapValue(
        value,
        yMin,
        yMax,
        bottom,
        top,
      );

      final TextPainter painter =
          TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(2),
          style: axisTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(
          left - painter.width - 8,
          y - painter.height / 2,
        ),
      );
    }

    // ==========================================================
    // ACHSENTITEL a* / b*
    // ==========================================================

    final TextPainter aTitle =
        TextPainter(
      text: const TextSpan(
        text: 'a*',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    aTitle.paint(
      canvas,
      Offset(
        right - aTitle.width,
        bottom + 30,
      ),
    );

    final TextPainter bTitle =
        TextPainter(
      text: const TextSpan(
        text: 'b*',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    bTitle.paint(
      canvas,
      Offset(
        left - bTitle.width - 8,
        top - 22,
      ),
    );

    // ==========================================================
    // L* / HELLIGKEIT
    // ==========================================================

    final double gaugeLeft = right + 28;
    final double gaugeRight = gaugeLeft + 24;

    final double gaugeTop = top;
    final double gaugeBottom = bottom;

    final double lMin =
        bezugL - toleranzL * 2.5;

    final double lMax =
        bezugL + toleranzL * 2.5;

    final Paint gaugeBackgroundPaint = Paint()
      ..color = const Color(0xFFF1F5F9);

    final Paint gaugeBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFE2E8F0);

    final Paint gaugeTolerancePaint = Paint()
      ..color = const Color(0xFFDCFCE7);

    final Paint gaugeToleranceBorderPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF86EFAC);

    final Paint gaugeReferencePaint = Paint()
      ..color = const Color(0xFF475569);

    final Paint gaugeMeasurementPaint = Paint()
      ..color = lInside
          ? const Color(0xFF16A34A)
          : const Color(0xFFDC2626);

    final Rect gaugeRect = Rect.fromLTRB(
      gaugeLeft,
      gaugeTop,
      gaugeRight,
      gaugeBottom,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        gaugeRect,
        const Radius.circular(12),
      ),
      gaugeBackgroundPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        gaugeRect,
        const Radius.circular(12),
      ),
      gaugeBorderPaint,
    );

    // ==========================================================
    // L* TOLERANZ
    // ==========================================================

    final double toleranceLTop =
        mapValue(
      bezugL + toleranzL,
      lMin,
      lMax,
      gaugeBottom,
      gaugeTop,
    );

    final double toleranceLBottom =
        mapValue(
      bezugL - toleranzL,
      lMin,
      lMax,
      gaugeBottom,
      gaugeTop,
    );

    final Rect lToleranceRect =
        Rect.fromLTRB(
      gaugeLeft + 2,
      toleranceLTop,
      gaugeRight - 2,
      toleranceLBottom,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        lToleranceRect,
        const Radius.circular(8),
      ),
      gaugeTolerancePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        lToleranceRect,
        const Radius.circular(8),
      ),
      gaugeToleranceBorderPaint,
    );

    // ==========================================================
    // BEZUG L*
    // ==========================================================

    final double referenceLPosition =
        mapValue(
      bezugL,
      lMin,
      lMax,
      gaugeBottom,
      gaugeTop,
    );

    canvas.drawLine(
      Offset(
        gaugeLeft - 6,
        referenceLPosition,
      ),
      Offset(
        gaugeRight + 6,
        referenceLPosition,
      ),
      gaugeReferencePaint,
    );

    // ==========================================================
    // MESSUNG L*
    // ==========================================================

    final double measurementLPosition =
        mapValue(
      l.clamp(lMin, lMax),
      lMin,
      lMax,
      gaugeBottom,
      gaugeTop,
    );

    final Offset measurementLOffset = Offset(
      gaugeLeft +
          ((gaugeRight - gaugeLeft) / 2),
      measurementLPosition,
    );

    canvas.drawCircle(
      measurementLOffset,
      8,
      gaugeMeasurementPaint,
    );

    canvas.drawCircle(
      measurementLOffset,
      8,
      measurementBorderPaint,
    );

    // ==========================================================
    // L* TITEL + HELLIGKEIT
    // ==========================================================

    final TextPainter lTitle =
        TextPainter(
      text: const TextSpan(
        text: 'L*',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lTitle.paint(
      canvas,
      Offset(
        gaugeLeft,
        top - 24,
      ),
    );

    final TextPainter helligkeitTitle =
        TextPainter(
      text: const TextSpan(
        text: 'Helligkeit',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    helligkeitTitle.paint(
      canvas,
      Offset(
        gaugeLeft + lTitle.width + 6,
        top - 24,
      ),
    );

    // ==========================================================
    // L* SKALA
    // ==========================================================

    final TextPainter lMaxLabel =
        TextPainter(
      text: TextSpan(
        text: lMax.toStringAsFixed(2),
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lMaxLabel.paint(
      canvas,
      Offset(
        gaugeRight + 10,
        gaugeTop - 6,
      ),
    );

    final TextPainter lToleranceTopLabel =
        TextPainter(
      text: TextSpan(
        text:
            (bezugL + toleranzL).toStringAsFixed(2),
        style: const TextStyle(
          color: Color(0xFF166534),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lToleranceTopLabel.paint(
      canvas,
      Offset(
        gaugeRight + 10,
        toleranceLTop - 7,
      ),
    );

    final TextPainter lReferenceLabel =
        TextPainter(
      text: TextSpan(
        text: bezugL.toStringAsFixed(2),
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lReferenceLabel.paint(
      canvas,
      Offset(
        gaugeRight + 10,
        referenceLPosition - 7,
      ),
    );

    final TextPainter lToleranceBottomLabel =
        TextPainter(
      text: TextSpan(
        text:
            (bezugL - toleranzL).toStringAsFixed(2),
        style: const TextStyle(
          color: Color(0xFF166534),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lToleranceBottomLabel.paint(
      canvas,
      Offset(
        gaugeRight + 10,
        toleranceLBottom - 7,
      ),
    );

    final TextPainter lMinLabel =
        TextPainter(
      text: TextSpan(
        text: lMin.toStringAsFixed(2),
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lMinLabel.paint(
      canvas,
      Offset(
        gaugeRight + 10,
        gaugeBottom - 7,
      ),
    );

    // ==========================================================
    // LEGEND
    // ==========================================================

    final double legendY =
        size.height - 18;

    final Paint greenLegend =
        Paint()
          ..color = const Color(0xFF16A34A);

    final Paint redLegend =
        Paint()
          ..color = const Color(0xFFDC2626);

    final Paint greyLegend =
        Paint()
          ..color = const Color(0xFF475569);

    final Paint whiteLegend =
        Paint()
          ..color = Colors.white;

    final Paint whiteLegendBorder =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFDC2626);

    canvas.drawCircle(
      Offset(
        left + 6,
        legendY,
      ),
      5,
      greenLegend,
    );

    final TextPainter measurementLegend =
        TextPainter(
      text: TextSpan(
        text: 'Messung i.O.',
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    measurementLegend.paint(
      canvas,
      Offset(
        left + 16,
        legendY - 7,
      ),
    );

    canvas.drawCircle(
      Offset(
        left + 116,
        legendY,
      ),
      5,
      redLegend,
    );

    final TextPainter notOkLegend =
        TextPainter(
      text: TextSpan(
        text: 'Messung n.i.O.',
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    notOkLegend.paint(
      canvas,
      Offset(
        left + 126,
        legendY - 7,
      ),
    );

    canvas.drawCircle(
      Offset(
        left + 230,
        legendY,
      ),
      5,
      whiteLegend,
    );

    canvas.drawCircle(
      Offset(
        left + 230,
        legendY,
      ),
      5,
      whiteLegendBorder,
    );

    final TextPainter whiteLegendText =
        TextPainter(
      text: TextSpan(
        text: 'a*/b* i.O., L* n.i.O.',
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    whiteLegendText.paint(
      canvas,
      Offset(
        left + 240,
        legendY - 7,
      ),
    );

    canvas.drawCircle(
      Offset(
        left + 390,
        legendY,
      ),
      5,
      greyLegend,
    );

    final TextPainter referenceLegend =
        TextPainter(
      text: TextSpan(
        text: 'Bezug',
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    referenceLegend.paint(
      canvas,
      Offset(
        left + 400,
        legendY - 7,
      ),
    );
  }

  @override
  bool shouldRepaint(
    covariant LabChartPainter oldDelegate,
  ) {
    return oldDelegate.l != l ||
        oldDelegate.a != a ||
        oldDelegate.b != b;
  }
}