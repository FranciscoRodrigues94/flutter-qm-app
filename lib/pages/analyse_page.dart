import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'messungen_page.dart';
import '../widgets/sidebar.dart';

class AnalysePage extends StatefulWidget {
  final List<dynamic> measurements;

  const AnalysePage({
    super.key,
    required this.measurements,
  });

  @override
  State<AnalysePage> createState() => _AnalysePageState();
}

class _AnalysePageState extends State<AnalysePage> {
  String selectedArtikel = 'Alle';
  String selectedBaNr = 'Alle';
  String selectedBenutzer = 'Alle';
  String selectedErgebnis = 'Alle';

  bool showL = true;
  bool showA = true;
  bool showB = true;

  // ============================================================
  // BEZUG / TOLERANZEN
  // ============================================================

  static const double bezugL = 55.00;
  static const double bezugA = 0.00;
  static const double bezugB = 4.00;

  static const double toleranzL = 1.50;
  static const double toleranzA = 0.40;
  static const double toleranzB = 0.40;

  // ============================================================
  // FILTER OPTIONS
  // ============================================================

  List<String> get artikelOptions {
    final values = widget.measurements
        .where((m) => !_isReference(m))
        .map((m) => m.artikelnummer.toString())
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['Alle', ...values];
  }

  List<String> get baNrOptions {
    final values = widget.measurements
        .where((m) => !_isReference(m))
        .map((m) => m.baNr.toString())
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['Alle', ...values];
  }

  List<String> get benutzerOptions {
    final values = widget.measurements
        .where((m) => !_isReference(m))
        .map((m) => m.benutzer.toString())
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['Alle', ...values];
  }

  // ============================================================
  // ERKENNT DIE BEZUG-ZEILE
  // ============================================================

  bool _isReference(dynamic m) {
    final artikel = m.artikelnummer.toString().trim();
    final bezug = m.bezug.toString().trim();
    final baNr = m.baNr.toString().trim();
    final benutzer = m.benutzer.toString().trim();

    if (artikel == 'Schwarz RR' &&
        baNr.isEmpty &&
        benutzer.isEmpty) {
      return true;
    }

    return artikel.isNotEmpty &&
        artikel == bezug &&
        baNr.isEmpty &&
        benutzer.isEmpty;
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<dynamic> get filteredMeasurements {
    final result = widget.measurements.where((m) {
      if (_isReference(m)) {
        return false;
      }

      final artikel = m.artikelnummer.toString();
      final baNr = m.baNr.toString();
      final benutzer = m.benutzer.toString();
      final status = m.status.toString().trim().toLowerCase();

      final artikelMatch =
          selectedArtikel == 'Alle' ||
          artikel == selectedArtikel;

      final baNrMatch =
          selectedBaNr == 'Alle' ||
          baNr == selectedBaNr;

      final benutzerMatch =
          selectedBenutzer == 'Alle' ||
          benutzer == selectedBenutzer;

      final ergebnisMatch =
          selectedErgebnis == 'Alle' ||
          status == selectedErgebnis;

      return artikelMatch &&
          baNrMatch &&
          benutzerMatch &&
          ergebnisMatch;
    }).toList();

    result.sort((a, b) => a.datum.compareTo(b.datum));

    return result;
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetFilters() {
    setState(() {
      selectedArtikel = 'Alle';
      selectedBaNr = 'Alle';
      selectedBenutzer = 'Alle';
      selectedErgebnis = 'Alle';

      showL = true;
      showA = true;
      showB = true;
    });
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String formatDate(DateTime date) {
    String twoDigits(int value) =>
        value.toString().padLeft(2, '0');

    return '${twoDigits(date.day)}.'
        '${twoDigits(date.month)}.'
        '${date.year} '
        '${twoDigits(date.hour)}:'
        '${twoDigits(date.minute)}';
  }

  // ============================================================
  // SPOTS
  // ============================================================

  List<FlSpot> _spots(
    List<dynamic> data,
    double Function(dynamic) value,
  ) {
    return List.generate(
      data.length,
      (index) => FlSpot(
        index.toDouble(),
        value(data[index]),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ============================================================
  // CHECKBOX
  // ============================================================

  Widget _measureToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
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
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _statistics(List<dynamic> data) {
    if (data.isEmpty) {
      return const SizedBox();
    }

    double avgL = 0;
    double avgA = 0;
    double avgB = 0;
    double avgDeltaE = 0;

    for (final m in data) {
      avgL += m.l.toDouble();
      avgA += m.a.toDouble();
      avgB += m.b.toDouble();
      avgDeltaE += m.deltaE.toDouble();
    }

    avgL /= data.length;
    avgA /= data.length;
    avgB /= data.length;
    avgDeltaE /= data.length;

    return Row(
      children: [
        _statCard(
          'Messungen',
          data.length.toString(),
        ),
        const SizedBox(width: 14),
        _statCard(
          'Ø L*',
          avgL.toStringAsFixed(2),
        ),
        const SizedBox(width: 14),
        _statCard(
          'Ø a*',
          avgA.toStringAsFixed(2),
        ),
        const SizedBox(width: 14),
        _statCard(
          'Ø b*',
          avgB.toStringAsFixed(2),
        ),
        const SizedBox(width: 14),
        _statCard(
          'Ø ΔE*',
          avgDeltaE.toStringAsFixed(2),
        ),
      ],
    );
  }

  // ============================================================
  // METRIC INFO
  // ============================================================

  String get _selectedMetric {
    if (showL && !showA && !showB) {
      return 'L*';
    }

    if (!showL && showA && !showB) {
      return 'a*';
    }

    if (!showL && !showA && showB) {
      return 'b*';
    }

    // Wenn mehrere Werte aktiv sind,
    // verwenden wir L* als Referenz für
    // den Toleranzbereich.
    return 'L*';
  }

  double get _referenceValue {
    switch (_selectedMetric) {
      case 'a*':
        return bezugA;
      case 'b*':
        return bezugB;
      default:
        return bezugL;
    }
  }

  double get _tolerance {
    switch (_selectedMetric) {
      case 'a*':
        return toleranzA;
      case 'b*':
        return toleranzB;
      default:
        return toleranzL;
    }
  }

  double get _lowerTolerance {
    return _referenceValue - _tolerance;
  }

  double get _upperTolerance {
    return _referenceValue + _tolerance;
  }

  double Function(dynamic) get _selectedValueFunction {
    switch (_selectedMetric) {
      case 'a*':
        return (m) => m.a.toDouble();
      case 'b*':
        return (m) => m.b.toDouble();
      default:
        return (m) => m.l.toDouble();
    }
  }

  bool _isInTolerance(dynamic m) {
    final value = _selectedValueFunction(m);

    return value >= _lowerTolerance &&
        value <= _upperTolerance;
  }

  // ============================================================
  // POINTS WITH STATUS COLORS
  // ============================================================

  List<FlSpot> _inToleranceSpots(
    List<dynamic> data,
    double Function(dynamic) value,
  ) {
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final m = data[i];

      if (_isInTolerance(m)) {
        spots.add(
          FlSpot(
            i.toDouble(),
            value(m),
          ),
        );
      }
    }

    return spots;
  }

  List<FlSpot> _outToleranceSpots(
    List<dynamic> data,
    double Function(dynamic) value,
  ) {
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final m = data[i];

      if (!_isInTolerance(m)) {
        spots.add(
          FlSpot(
            i.toDouble(),
            value(m),
          ),
        );
      }
    }

    return spots;
  }

  // ============================================================
  // LEGEND DOT
  // ============================================================

  Widget _legendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // LEGEND ROW
  // ============================================================

  Widget _legendRow({
    required Widget marker,
    required String label,
    String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Center(
              child: marker,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
              ),
            ),
          ),
          if (value != null)
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND / VALUES PANEL
  // ============================================================

  Widget _buildLegendPanel(List<dynamic> data) {
    final inTolerance = data
        .where(_isInTolerance)
        .length;

    final outTolerance =
        data.length - inTolerance;

    final inPercentage = data.isEmpty
        ? 0.0
        : inTolerance / data.length * 100;

    final outPercentage = data.isEmpty
        ? 0.0
        : outTolerance / data.length * 100;

    return Container(
      width: 290,
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Legende & Werte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 14),

          _legendRow(
            marker: _legendDot(
              const Color(0xFF2563EB),
            ),
            label: 'Messung i.O.',
            value:
                '$inTolerance (${inPercentage.toStringAsFixed(1)}%)',
          ),

          _legendRow(
            marker: _legendDot(
              const Color(0xFFEF4444),
            ),
            label: 'Messung n.i.O.',
            value:
                '$outTolerance (${outPercentage.toStringAsFixed(1)}%)',
          ),

          const SizedBox(height: 12),

          const Divider(
            color: Color(0xFFE2E8F0),
          ),

          const SizedBox(height: 8),

          const Text(
            'Messwerte',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 6),

          _legendRow(
            marker: _legendDot(
              const Color(0xFF2563EB),
            ),
            label: 'L*',
            value: bezugL.toStringAsFixed(2),
          ),

          _legendRow(
            marker: _legendDot(
              const Color(0xFF16A34A),
            ),
            label: 'a*',
            value: bezugA.toStringAsFixed(2),
          ),

          _legendRow(
            marker: _legendDot(
              const Color(0xFFEA580C),
            ),
            label: 'b*',
            value: bezugB.toStringAsFixed(2),
          ),

          const SizedBox(height: 10),

          const Divider(
            color: Color(0xFFE2E8F0),
          ),

          const SizedBox(height: 10),

          const Text(
            'Toleranz',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),

          const SizedBox(height: 6),

          _legendRow(
            marker: Container(
              width: 18,
              height: 3,
              color: const Color(0xFF16A34A),
            ),
            label: 'Untere Toleranz',
            value:
                _lowerTolerance.toStringAsFixed(2),
          ),

          _legendRow(
            marker: Container(
              width: 18,
              height: 3,
              color: const Color(0xFF16A34A),
            ),
            label: 'Obere Toleranz',
            value:
                _upperTolerance.toStringAsFixed(2),
          ),

          _legendRow(
            marker: Container(
              width: 18,
              height: 3,
              color: const Color(0xFF64748B),
            ),
            label: 'Bezug',
            value:
                _referenceValue.toStringAsFixed(2),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Text(
              'Grüner Bereich = innerhalb Toleranz',
              style: TextStyle(
                color: Color(0xFF166534),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Text(
              'Roter Bereich = außerhalb Toleranz',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRIC SELECTOR
  // ============================================================

  Widget _metricButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            borderRadius:
                BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHART
  // ============================================================

  Widget _chart(List<dynamic> data) {
    if (data.isEmpty) {
      return _emptyChart(
        'Keine Messungen für diese Auswahl gefunden.',
      );
    }

    if (!showL && !showA && !showB) {
      return _emptyChart(
        'Mindestens einen Messwert auswählen.',
      );
    }

    final bool onlyL = showL && !showA && !showB;
    final bool onlyA = !showL && showA && !showB;
    final bool onlyB = !showL && !showA && showB;

    final List<LineChartBarData> lines = [];

    // ==========================================================
    // L*
    // ==========================================================

    if (showL) {
      lines.add(
        LineChartBarData(
          spots: _spots(
            data,
            (m) => m.l.toDouble(),
          ),
          isCurved: false,
          barWidth: 1.5,
          color: const Color(0xFF2563EB),
          dotData: const FlDotData(
            show: false,
          ),
        ),
      );
    }

    // ==========================================================
    // a*
    // ==========================================================

    if (showA) {
      lines.add(
        LineChartBarData(
          spots: _spots(
            data,
            (m) => m.a.toDouble(),
          ),
          isCurved: false,
          barWidth: 1.5,
          color: const Color(0xFF16A34A),
          dotData: const FlDotData(
            show: false,
          ),
        ),
      );
    }

    // ==========================================================
    // b*
    // ==========================================================

    if (showB) {
      lines.add(
        LineChartBarData(
          spots: _spots(
            data,
            (m) => m.b.toDouble(),
          ),
          isCurved: false,
          barWidth: 1.5,
          color: const Color(0xFFEA580C),
          dotData: const FlDotData(
            show: false,
          ),
        ),
      );
    }

    // ==========================================================
    // Y SCALE
    // ==========================================================

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final m in data) {
      if (showL) {
        minY = _min(
          minY,
          m.l.toDouble(),
        );
        maxY = _max(
          maxY,
          m.l.toDouble(),
        );
      }

      if (showA) {
        minY = _min(
          minY,
          m.a.toDouble(),
        );
        maxY = _max(
          maxY,
          m.a.toDouble(),
        );
      }

      if (showB) {
        minY = _min(
          minY,
          m.b.toDouble(),
        );
        maxY = _max(
          maxY,
          m.b.toDouble(),
        );
      }
    }

    // Wenn nur eine Messgröße ausgewählt ist,
    // sorgen wir dafür, dass die Toleranzzone
    // immer sichtbar ist.
    if (onlyL || onlyA || onlyB) {
      minY = _min(
        minY,
        _lowerTolerance,
      );

      maxY = _max(
        maxY,
        _upperTolerance,
      );
    }

    if (minY == double.infinity ||
        maxY == double.negativeInfinity) {
      minY = 0;
      maxY = 1;
    }

    var range = maxY - minY;

    if (range == 0) {
      range = 1;
    }

    minY -= range * 0.10;
    maxY += range * 0.10;

    final double maxX =
        data.length > 1
            ? (data.length - 1).toDouble()
            : 1;

    // ==========================================================
    // TOLERANCE RANGES
    // ==========================================================

    final horizontalRanges =
        <HorizontalRangeAnnotation>[];

    if (onlyL || onlyA || onlyB) {
      // Grüner Bereich innerhalb der Toleranz.
      horizontalRanges.add(
        HorizontalRangeAnnotation(
          y1: _lowerTolerance,
          y2: _upperTolerance,
          color: const Color(
            0xFFDCFCE7,
          ).withOpacity(0.55),
        ),
      );

      // Roter Bereich unterhalb der Toleranz.
      horizontalRanges.add(
        HorizontalRangeAnnotation(
          y1: minY,
          y2: _lowerTolerance,
          color: const Color(
            0xFFFEE2E2,
          ).withOpacity(0.55),
        ),
      );

      // Roter Bereich oberhalb der Toleranz.
      horizontalRanges.add(
        HorizontalRangeAnnotation(
          y1: _upperTolerance,
          y2: maxY,
          color: const Color(
            0xFFFEE2E2,
          ).withOpacity(0.55),
        ),
      );
    }

    // ==========================================================
    // REFERENCE / TOLERANCE LINES
    // ==========================================================

    final extraLines =
        <HorizontalLine>[];

    if (onlyL || onlyA || onlyB) {
      extraLines.add(
        HorizontalLine(
          y: _referenceValue,
          color: const Color(0xFF64748B),
          strokeWidth: 1.5,
          dashArray: [8, 5],
        ),
      );

      extraLines.add(
        HorizontalLine(
          y: _lowerTolerance,
          color: const Color(0xFF16A34A),
          strokeWidth: 1.5,
          dashArray: [8, 5],
        ),
      );

      extraLines.add(
        HorizontalLine(
          y: _upperTolerance,
          color: const Color(0xFF16A34A),
          strokeWidth: 1.5,
          dashArray: [8, 5],
        ),
      );
    }

    // ==========================================================
    // POINT STATUS LAYERS
    // ==========================================================

    if (onlyL || onlyA || onlyB) {
      final valueFunction =
          _selectedValueFunction;

      final inSpots =
          _inToleranceSpots(
        data,
        valueFunction,
      );

      final outSpots =
          _outToleranceSpots(
        data,
        valueFunction,
      );

      lines.add(
        LineChartBarData(
          spots: inSpots,
          isCurved: false,
          barWidth: 0,
          color: Colors.transparent,
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3.8,
                color:
                    const Color(0xFF2563EB),
                strokeWidth: 0,
              );
            },
          ),
        ),
      );

      lines.add(
        LineChartBarData(
          spots: outSpots,
          isCurved: false,
          barWidth: 0,
          color: Colors.transparent,
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4.2,
                color:
                    const Color(0xFFEF4444),
                strokeWidth: 0,
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$_selectedMetric Verlauf',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Alle Messungen im ausgewählten Zeitraum',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,

                lineBarsData: lines,

                rangeAnnotations:
                    RangeAnnotations(
                  horizontalRangeAnnotations:
                      horizontalRanges,
                ),

                extraLinesData:
                    ExtraLinesData(
                  horizontalLines:
                      extraLines,
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval:
                      range / 5,
                  getDrawingHorizontalLine:
                      (value) {
                    return FlLine(
                      color: const Color(
                        0xFFD8E0E8,
                      ),
                      strokeWidth: 1,
                      dashArray: [7, 5],
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xFFCBD5E1),
                    ),
                    bottom: BorderSide(
                      color: Color(0xFFCBD5E1),
                    ),
                    top: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),

                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles: false,
                    ),
                  ),

                  rightTitles:
                      const AxisTitles(
                    sideTitles:
                        SideTitles(
                      showTitles: false,
                    ),
                  ),

                  leftTitles:
                      AxisTitles(
                    axisNameWidget: Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Text(
                        _selectedMetric,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                    axisNameSize: 28,
                    sideTitles:
                        SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval:
                          range / 5,
                      getTitlesWidget:
                          (value, meta) {
                        return Text(
                          value
                              .toStringAsFixed(
                            1,
                          ),
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF64748B,
                            ),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles:
                      AxisTitles(
                    axisNameWidget:
                        const Padding(
                      padding:
                          EdgeInsets.only(
                        top: 6,
                      ),
                      child: Text(
                        'Datum',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF64748B,
                          ),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                    axisNameSize: 25,
                    sideTitles:
                        SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval:
                          data.length > 10
                              ? (data.length /
                                      8)
                                  .ceilToDouble()
                              : 1,
                      getTitlesWidget:
                          (value, meta) {
                        final index =
                            value.round();

                        if (index < 0 ||
                            index >=
                                data.length) {
                          return const SizedBox();
                        }

                        final date =
                            data[index].datum
                                as DateTime;

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${date.day.toString().padLeft(2, '0')}.'
                            '${date.month.toString().padLeft(2, '0')}',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF64748B,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineTouchData:
                    LineTouchData(
                  enabled: true,
                  touchTooltipData:
                      LineTouchTooltipData(
                    getTooltipItems:
                        (spots) {
                      return spots
                          .map(
                            (spot) {
                          final index =
                              spot.x.round();

                          if (index < 0 ||
                              index >=
                                  data.length) {
                            return null;
                          }

                          final m =
                              data[index];

                          String prefix;

                          if (onlyL) {
                            prefix = 'L*';
                          } else if (onlyA) {
                            prefix = 'a*';
                          } else if (onlyB) {
                            prefix = 'b*';
                          } else {
                            if (spot.barIndex ==
                                0) {
                              prefix = 'L*';
                            } else if (spot.barIndex ==
                                1) {
                              prefix = 'a*';
                            } else {
                              prefix = 'b*';
                            }
                          }

                          return LineTooltipItem(
                            '${formatDate(m.datum as DateTime)}\n'
                            'Artikel: ${m.artikelnummer}\n'
                            'BA-Nr.: ${m.baNr}\n'
                            'Benutzer: ${m.benutzer}\n'
                            '$prefix: ${spot.y.toStringAsFixed(2)}\n'
                            'ΔE*: ${m.deltaE.toStringAsFixed(2)}\n'
                            'Ergebnis: ${m.status}',
                            const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          );
                        },
                      )
                          .whereType<
                              LineTooltipItem>()
                          .toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CHART
  // ============================================================

  Widget _emptyChart(String text) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final data = filteredMeasurements;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),
      body: Row(
        children: [
          AppSidebar(
            selectedPage: 'Analyse',

            onDashboard: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );
            },

            onMessungen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MessungenPage(
                    measurements:
                        widget.measurements,
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color:
                            Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Analyse',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF0F172A),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '${data.length} Messungen',
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(
                      28,
                    ),
                    child: Column(
                      children: [
                        // ==========================================
                        // FILTER
                        // ==========================================

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(
                            20,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFE2E8F0,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                'Analysefilter',
                                style:
                                    TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      Color(
                                    0xFF0F172A,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              Row(
                                children: [
                                  _dropdown(
                                    label:
                                        'Artikelnummer',
                                    value:
                                        selectedArtikel,
                                    items:
                                        artikelOptions,
                                    onChanged:
                                        (v) {
                                      setState(
                                        () {
                                          selectedArtikel =
                                              v ??
                                                  'Alle';
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  _dropdown(
                                    label:
                                        'BA-Nr.',
                                    value:
                                        selectedBaNr,
                                    items:
                                        baNrOptions,
                                    onChanged:
                                        (v) {
                                      setState(
                                        () {
                                          selectedBaNr =
                                              v ??
                                                  'Alle';
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  _dropdown(
                                    label:
                                        'Benutzer',
                                    value:
                                        selectedBenutzer,
                                    items:
                                        benutzerOptions,
                                    onChanged:
                                        (v) {
                                      setState(
                                        () {
                                          selectedBenutzer =
                                              v ??
                                                  'Alle';
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  _dropdown(
                                    label:
                                        'Ergebnis',
                                    value:
                                        selectedErgebnis,
                                    items:
                                        const [
                                      'Alle',
                                      'erfüllt',
                                      'nicht erfüllt',
                                    ],
                                    onChanged:
                                        (v) {
                                      setState(
                                        () {
                                          selectedErgebnis =
                                              v ??
                                                  'Alle';
                                        },
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                    width: 14,
                                  ),

                                  OutlinedButton(
                                    onPressed:
                                        resetFilters,
                                    style:
                                        OutlinedButton
                                            .styleFrom(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal:
                                            18,
                                        vertical:
                                            18,
                                      ),
                                      side:
                                          const BorderSide(
                                        color:
                                            Color(
                                          0xFFCBD5E1,
                                        ),
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          10,
                                        ),
                                      ),
                                    ),
                                    child:
                                        const Text(
                                      'Zurücksetzen',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              const Divider(
                                height: 1,
                                color:
                                    Color(
                                  0xFFE2E8F0,
                                ),
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              const Text(
                                'Messwerte',
                                style:
                                    TextStyle(
                                  fontSize:
                                      14,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color:
                                      Color(
                                    0xFF334155,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child:
                                        _measureToggle(
                                      label: 'L*',
                                      value:
                                          showL,
                                      onChanged:
                                          (v) {
                                        setState(
                                          () =>
                                              showL =
                                                  v,
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(
                                    width: 100,
                                    child:
                                        _measureToggle(
                                      label: 'a*',
                                      value:
                                          showA,
                                      onChanged:
                                          (v) {
                                        setState(
                                          () =>
                                              showA =
                                                  v,
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(
                                    width: 100,
                                    child:
                                        _measureToggle(
                                      label: 'b*',
                                      value:
                                          showB,
                                      onChanged:
                                          (v) {
                                        setState(
                                          () =>
                                              showB =
                                                  v,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // ==========================================
                        // STATISTICS
                        // ==========================================

                        _statistics(data),

                        const SizedBox(
                          height: 20,
                        ),

                        // ==========================================
                        // CHART + LEGEND
                        // ==========================================

                        SizedBox(
                          height: 600,
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .stretch,
                            children: [
                              Expanded(
                                child:
                                    _chart(data),
                              ),

                              const SizedBox(
                                width: 20,
                              ),

                              _buildLegendPanel(
                                data,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MIN / MAX
  // ============================================================

  double _min(double a, double b) =>
      a < b ? a : b;

  double _max(double a, double b) =>
      a > b ? a : b;
}