import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../main.dart';

import 'messungen_page.dart';
import 'messungsdetails_page.dart';
import 'frag_ai_page.dart';
import '../widgets/sidebar.dart';

class AnalysePage extends StatefulWidget {
  final List<Measurement> measurements;

  const AnalysePage({
    super.key,
    required this.measurements,
  });

  @override
  State<AnalysePage> createState() => _AnalysePageState();
}

class _AnalysePageState extends State<AnalysePage> {
  static const double bezugL = 55.0;
  static const double bezugA = 0.0;
  static const double bezugB = 4.0;

  static const double toleranzL = 1.5;
  static const double toleranzA = 0.4;
  static const double toleranzB = 0.4;
  static const double toleranzDeltaE = 2.0;

  String selectedArtikel = 'Alle';
  String selectedBaNr = 'Alle';
  String selectedBenutzer = 'Alle';
  String selectedErgebnis = 'Alle';

  DateTime? startDate;
  DateTime? endDate;
  Measurement? selectedMeasurement;
  final Set<Measurement> selectedMeasurements = <Measurement>{};

  bool showL = true;
  bool showA = true;
  bool showB = true;
  bool showDeltaE = true;
  bool showDeltaL = false;
  bool showDeltaA = false;
  bool showDeltaB = false;

  // A análise começa vazia. Os resultados só aparecem depois de uma pesquisa.
  bool hasSearched = false;

  List<Measurement> get _measurements {
    return widget.measurements.where((m) => !_isReference(m)).toList();
  }

  List<String> get artikelOptions {
    final values = _measurements
        .map((m) => m.artikelnummer.toString())
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Alle', ...values];
  }

  List<String> get baNrOptions {
    final values = _measurements
        .map((m) => m.baNr.toString())
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Alle', ...values];
  }

  List<String> get benutzerOptions {
    final values = _measurements
        .map((m) => m.benutzer.toString())
        .where((v) => v.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Alle', ...values];
  }

  DateTime get dataMinDate {
    if (_measurements.isEmpty) {
      return DateTime(2025, 1, 1);
    }
    return _measurements
        .map((m) => m.datum as DateTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime get dataMaxDate {
    if (_measurements.isEmpty) {
      return DateTime(2026, 9, 8);
    }
    return _measurements
        .map((m) => m.datum as DateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  void initState() {
    super.initState();
    startDate = dataMinDate;
    endDate = dataMaxDate;
    if (_measurements.isNotEmpty) {
      selectedMeasurement = _measurements.first;
    }
  }

  bool _isReference(dynamic m) {
    final artikel = m.artikelnummer.toString().trim();
    final bezug = m.bezug.toString().trim();
    final baNr = m.baNr.toString().trim();
    final benutzer = m.benutzer.toString().trim();

    if (artikel == 'Schwarz RR' && baNr.isEmpty && benutzer.isEmpty) {
      return true;
    }

    return artikel.isNotEmpty &&
        artikel == bezug &&
        baNr.isEmpty &&
        benutzer.isEmpty;
  }

  List<Measurement> get displayedMeasurements {
    if (!hasSearched) {
      return const <Measurement>[];
    }
    return filteredMeasurements;
  }

  List<Measurement> get filteredMeasurements {
    final result = _measurements.where((m) {
      final artikel = m.artikelnummer.toString();
      final baNr = m.baNr.toString();
      final benutzer = m.benutzer.toString();
      final status = m.status.toString().trim().toLowerCase();
      final date = m.datum as DateTime;

      final artikelMatch =
          selectedArtikel == 'Alle' || artikel == selectedArtikel;
      final baNrMatch = selectedBaNr == 'Alle' || baNr == selectedBaNr;
      final benutzerMatch =
          selectedBenutzer == 'Alle' || benutzer == selectedBenutzer;
      final ergebnisMatch =
          selectedErgebnis == 'Alle' || status == selectedErgebnis;
      final startMatch =
          startDate == null || !date.isBefore(_dateOnly(startDate!));
      final endMatch =
          endDate == null || !date.isAfter(_endOfDay(endDate!));

      return artikelMatch &&
          baNrMatch &&
          benutzerMatch &&
          ergebnisMatch &&
          startMatch &&
          endMatch;
    }).toList();

    result.sort((a, b) => (b.datum as DateTime).compareTo(a.datum as DateTime));
    return result;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  String formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}';
  }

  String formatDateTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  String number(double value) => value.toStringAsFixed(1).replaceAll('.', ',');

  void resetFilters() {
    setState(() {
      selectedArtikel = 'Alle';
      selectedBaNr = 'Alle';
      selectedBenutzer = 'Alle';
      selectedErgebnis = 'Alle';
      startDate = dataMinDate;
      endDate = dataMaxDate;
      selectedMeasurement = null;
      selectedMeasurements.clear();
      hasSearched = false;
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? dataMinDate,
      firstDate: dataMinDate,
      lastDate: dataMaxDate,
      locale: const Locale('de', 'DE'),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = picked;
        }
        hasSearched = false;
        selectedMeasurements.clear();
        selectedMeasurement = null;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? dataMaxDate,
      firstDate: dataMinDate,
      lastDate: dataMaxDate,
      locale: const Locale('de', 'DE'),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
        if (startDate != null && startDate!.isAfter(picked)) {
          startDate = picked;
        }
        hasSearched = false;
        selectedMeasurements.clear();
        selectedMeasurement = null;
      });
    }
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              size: 19,
              color: Color(0xFF64748B),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          child: Text(
            value == null ? '-' : formatDate(value),
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle({
    required String label,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: (_) => onTap(),
              visualDensity: VisualDensity.compact,
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
      ),
    );
  }

  Widget _statistics(List<Measurement> data) {
    if (data.isEmpty) return const SizedBox();

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

    final ok = data
        .where((m) => m.status.toString().trim().toLowerCase() == 'erfüllt')
        .length;
    final notOk = data.length - ok;

    return Row(
      children: [
        _statCard('Messungen', '${data.length}'),
        const SizedBox(width: 10),
        _statCard('i.O.', '$ok'),
        const SizedBox(width: 10),
        _statCard('n.i.O.', '$notOk'),
        const SizedBox(width: 10),
        _statCard('Ø L*', number(avgL)),
        const SizedBox(width: 10),
        _statCard('Ø a*', number(avgA)),
        const SizedBox(width: 10),
        _statCard('Ø b*', number(avgB)),
        const SizedBox(width: 10),
        _statCard('Ø ΔE*', number(avgDeltaE)),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem({
    required String label,
    required Color color,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: (_) => onTap(),
            visualDensity: VisualDensity.compact,
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toleranceLegend(String label, {required bool checked}) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: (_) {},
          visualDensity: VisualDensity.compact,
        ),
        Container(
          width: 17,
          height: 2,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color(0xFFB45309),
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _spots(List<Measurement> data, double Function(dynamic) value) {
    // Keep the chart responsive with large datasets.
    // For large selections we sample the data while preserving the first/last point.
    if (data.length <= 120) {
      return List.generate(
        data.length,
        (index) => FlSpot(index.toDouble(), value(data[index])),
      );
    }

    const maxPoints = 120;
    final step = (data.length - 1) / (maxPoints - 1);

    return List.generate(maxPoints, (index) {
      final sourceIndex = (index * step).round();
      return FlSpot(
        sourceIndex.toDouble(),
        value(data[sourceIndex]),
      );
    });
  }

  Widget _chart(List<Measurement> data) {
    if (data.isEmpty) {
      return _emptyBox(
        hasSearched
            ? 'Keine Messungen für diese Auswahl gefunden.'
            : 'Filter auswählen und „Daten aktualisieren“ ausführen.',
      );
    }

    // Wenn mehrere Messungen in der Tabelle ausgewählt sind,
    // zeigt das Diagramm nur diese Auswahl. Ohne Auswahl werden
    // weiterhin alle gefilterten Messungen dargestellt.
    final chartData = selectedMeasurements.isEmpty
        ? data
        : data.where((m) => selectedMeasurements.contains(m)).toList();

    final bars = <LineChartBarData>[];
    final showDots = chartData.length <= 80;
    final useCurve = chartData.length <= 80;

    void addSeries({
      required bool visible,
      required Color color,
      required double Function(dynamic) value,
    }) {
      if (!visible) return;
      bars.add(
        LineChartBarData(
          spots: _spots(chartData, value),
          isCurved: true,
          barWidth: 2.2,
          color: color,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    addSeries(
      visible: showL,
      color: const Color(0xFF2563EB),
      value: (m) => m.l.toDouble(),
    );
    addSeries(
      visible: showA,
      color: const Color(0xFFDC2626),
      value: (m) => m.a.toDouble(),
    );
    addSeries(
      visible: showB,
      color: const Color(0xFF0F766E),
      value: (m) => m.b.toDouble(),
    );
    addSeries(
      visible: showDeltaE,
      color: const Color(0xFF334155),
      value: (m) => m.deltaE.toDouble(),
    );

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final m in chartData) {
      final values = <double>[];
      if (showL) values.add(m.l.toDouble());
      if (showA) values.add(m.a.toDouble());
      if (showB) values.add(m.b.toDouble());
      if (showDeltaE) values.add(m.deltaE.toDouble());

      if (values.isEmpty) continue;
      final localMin = values.reduce((a, b) => a < b ? a : b);
      final localMax = values.reduce((a, b) => a > b ? a : b);
      if (localMin < minY) minY = localMin;
      if (localMax > maxY) maxY = localMax;
    }

    if (!minY.isFinite || !maxY.isFinite) {
      minY = 0;
      maxY = 10;
    }

    var range = maxY - minY;
    if (range < 1) range = 1;

    minY -= range * .12;
    maxY += range * .12;

    final maxX = chartData.length > 1 ? (chartData.length - 1).toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: bars,
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    if (showL)
                      HorizontalRangeAnnotation(
                        y1: bezugL - toleranzL,
                        y2: bezugL + toleranzL,
                        color: const Color(0xFF22C55E).withOpacity(.09),
                      ),
                    if (showDeltaE)
                      HorizontalRangeAnnotation(
                        y1: 0,
                        y2: toleranzDeltaE,
                        color: const Color(0xFF22C55E).withOpacity(.06),
                      ),
                  ],
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (showL)
                      HorizontalLine(
                        y: bezugL,
                        color: const Color(0xFF2563EB),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    if (showL)
                      HorizontalLine(
                        y: bezugL + toleranzL,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    if (showL)
                      HorizontalLine(
                        y: bezugL - toleranzL,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    if (showA)
                      HorizontalLine(
                        y: bezugA,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                    if (showA)
                      HorizontalLine(
                        y: bezugA + toleranzA,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                    if (showA)
                      HorizontalLine(
                        y: bezugA - toleranzA,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                    if (showB)
                      HorizontalLine(
                        y: bezugB,
                        color: const Color(0xFF0F766E),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                    if (showB)
                      HorizontalLine(
                        y: bezugB + toleranzB,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                    if (showB)
                      HorizontalLine(
                        y: bezugB - toleranzB,
                        color: const Color(0xFFDC2626),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                    if (showDeltaE)
                      HorizontalLine(
                        y: toleranzDeltaE,
                        color: const Color(0xFF64748B),
                        strokeWidth: 1,
                        dashArray: [4, 5],
                      ),
                  ],
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval: chartData.length > 12
                      ? (chartData.length / 6).ceilToDouble()
                      : 1,
                  horizontalInterval: range / 5,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Color(0xFFCBD5E1)),
                    bottom: BorderSide(color: Color(0xFFCBD5E1)),
                    top: BorderSide.none,
                    right: BorderSide.none,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text(
                      'Wert',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: range / 5,
                      getTitlesWidget: (value, meta) {
                        // Bei kleinen Wertebereichen (z. B. a* und b*)
                        // eine Nachkommastelle anzeigen, damit die Skala
                        // nicht mehrfach nur als 0 erscheint.
                        final useDecimal = range < 10;
                        final text = useDecimal
                            ? value.toStringAsFixed(1).replaceAll('.', ',')
                            : value.toStringAsFixed(0);

                        return Text(
                          text,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text(
                      'Datum',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: chartData.length > 8
                          ? (chartData.length / 6).ceilToDouble()
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= chartData.length) {
                          return const SizedBox();
                        }
                        final date = chartData[index].datum as DateTime;
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.round();
                        if (index < 0 || index >= chartData.length) return null;

                        final m = chartData[index];
                        final labels = <String>[];
                        if (showL) labels.add('L*: ${number(m.l.toDouble())}');
                        if (showA) labels.add('a*: ${number(m.a.toDouble())}');
                        if (showB) labels.add('b*: ${number(m.b.toDouble())}');
                        if (showDeltaE) {
                          labels.add(
                            'ΔE*: ${number(m.deltaE.toDouble())}',
                          );
                        }

                        return LineTooltipItem(
                          '${formatDateTime(m.datum as DateTime)}\n'
                          '${m.artikelnummer}\n'
                          'BA-Nr.: ${m.baNr}\n'
                          '${labels.join('\n')}\n'
                          'Ergebnis: ${m.status}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).whereType<LineTooltipItem>().toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _legendPanel(),
        ],
      ),
    );
  }

  Widget _legendPanel() {
    return SizedBox(
      width: 150,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            _legendItem(
              label: 'L*',
              color: const Color(0xFF2563EB),
              checked: showL,
              onTap: () => setState(() => showL = !showL),
            ),
            _legendItem(
              label: 'a*',
              color: const Color(0xFFDC2626),
              checked: showA,
              onTap: () => setState(() => showA = !showA),
            ),
            _legendItem(
              label: 'b*',
              color: const Color(0xFF0F766E),
              checked: showB,
              onTap: () => setState(() => showB = !showB),
            ),
            _legendItem(
              label: 'ΔE*',
              color: const Color(0xFF334155),
              checked: showDeltaE,
              onTap: () => setState(() => showDeltaE = !showDeltaE),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toleranzlinien',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            _toleranceLegend('L* Toleranz', checked: showL),
            _toleranceLegend('a* Toleranz', checked: showA),
            _toleranceLegend('b* Toleranz', checked: showB),
            _toleranceLegend('ΔE* Toleranz', checked: showDeltaE),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Grün = Toleranzbereich\nRot = außerhalb',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _measurementTable(List<Measurement> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 13, 14, 8),
            child: Text(
              'Messungen (gefiltert)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          if (selectedMeasurements.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${selectedMeasurements.length} ausgewählt – Diagramm zeigt nur diese Messungen',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF155AA8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedMeasurements.clear();
                        selectedMeasurement =
                            data.isNotEmpty ? data.first : null;
                      });
                    },
                    child: const Text('Auswahl aufheben'),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 300,
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      'Keine Messungen für diese Filter gefunden.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 42),
                            SizedBox(
                              width: 92,
                              child: Text(
                                'Datum',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'BA-Nr.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 65,
                              child: Text(
                                'L*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 65,
                              child: Text(
                                'a*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 65,
                              child: Text(
                                'b*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 75,
                              child: Text(
                                'ΔE*',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 65,
                              child: Text(
                                'Glanz',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Benutzer',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final m = data[index];
                              final selected =
                                  selectedMeasurements.contains(m);

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      selectedMeasurements.remove(m);
                                    } else {
                                      selectedMeasurements.add(m);
                                    }
                                    selectedMeasurement = m;
                                  });
                                },
                                child: Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFEFF6FF)
                                        : index.isEven
                                            ? Colors.white
                                            : const Color(0xFFFAFBFC),
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFF1F5F9),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 42,
                                        child: Checkbox(
                                          value: selected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedMeasurements.add(m);
                                              } else {
                                                selectedMeasurements.remove(m);
                                              }
                                              selectedMeasurement = m;
                                            });
                                          },
                                          visualDensity:
                                              VisualDensity.compact,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 92,
                                        child: Text(
                                          formatDate(m.datum as DateTime),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          m.baNr.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 65,
                                        child: Text(
                                          number(m.l.toDouble()),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 65,
                                        child: Text(
                                          number(m.a.toDouble()),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 65,
                                        child: Text(
                                          number(m.b.toDouble()),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: Text(
                                          number(m.deltaE.toDouble()),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 65,
                                        child: Text(
                                          '-',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Text(
                                          m.benutzer.toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Text(
              hasSearched
                  ? '${data.length} Messungen'
                  : 'Keine Messungen angezeigt – Suche ausführen',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsPanel(dynamic m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details der ausgewählten Messung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${selectedMeasurements.length} Messung(en) ausgewählt',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow('Datum', formatDateTime(m.datum as DateTime)),
          _detailRow('Bauteil', m.artikelnummer.toString()),
          _detailRow('BA-Nr.', m.baNr.toString()),
          _detailRow('L*', number(m.l.toDouble())),
          _detailRow('a*', number(m.a.toDouble())),
          _detailRow('b*', number(m.b.toDouble())),
          _detailRow('ΔE*', number(m.deltaE.toDouble())),
          _detailRow(
            'Glanz',
            '-',
          ),
          _detailRow('Benutzer', m.benutzer.toString()),
          _detailRow('Ergebnis', m.status.toString()),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MessungsdetailsPage(
                      measurement: m,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 17),
              label: const Text('Details anzeigen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDCE8F7),
                foregroundColor: const Color(0xFF164E80),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _header(List<Measurement> data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trends analysieren',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Entwicklung einer Farbeigenschaft über die Zeit',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _filterDropdown(
                  label: 'Bauteil',
                  value: selectedArtikel,
                  items: artikelOptions,
                  onChanged: (v) {
                    setState(() {
                      selectedArtikel = v ?? 'Alle';
                      hasSearched = false;
                      selectedMeasurements.clear();
                      selectedMeasurement = null;
                    });
                  },
                ),
                _filterDropdown(
                  label: 'BA-Nr.',
                  value: selectedBaNr,
                  items: baNrOptions,
                  onChanged: (v) {
                    setState(() {
                      selectedBaNr = v ?? 'Alle';
                      hasSearched = false;
                      selectedMeasurements.clear();
                      selectedMeasurement = null;
                    });
                  },
                ),
                _dateField('Von', startDate, _pickStartDate),
                _dateField('Bis', endDate, _pickEndDate),
                ElevatedButton.icon(
                  onPressed: () {
                    final results = filteredMeasurements;
                    setState(() {
                      hasSearched = true;
                      selectedMeasurements.clear();
                      selectedMeasurement =
                          results.isNotEmpty ? results.first : null;
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Suchen / aktualisieren'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF155AA8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: resetFilters,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Zurücksetzen'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _filterDropdown(
                label: 'Benutzer',
                value: selectedBenutzer,
                items: benutzerOptions,
                onChanged: (v) {
                  setState(() {
                    selectedBenutzer = v ?? 'Alle';
                    hasSearched = false;
                    selectedMeasurements.clear();
                    selectedMeasurement = null;
                  });
                },
              ),
              _filterDropdown(
                label: 'Ergebnis',
                value: selectedErgebnis,
                items: const ['Alle', 'erfüllt', 'nicht erfüllt'],
                onChanged: (v) {
                  setState(() {
                    selectedErgebnis = v ?? 'Alle';
                    hasSearched = false;
                    selectedMeasurements.clear();
                    selectedMeasurement = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasSearched
                ? '${data.length} Messungen'
                : 'Keine Suche ausgeführt',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = displayedMeasurements;

    final validSelectedMeasurements = selectedMeasurements
        .where((m) => data.contains(m))
        .toSet();

    final currentMeasurement =
        data.contains(selectedMeasurement)
            ? selectedMeasurement
            : (validSelectedMeasurements.isNotEmpty
                ? validSelectedMeasurements.last
                : (data.isNotEmpty ? data.first : null));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                  builder: (_) => MessungenPage(
                    measurements: widget.measurements,
                  ),
                ),
              );
            },
            onFragAI: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FragAIPage(
                    measurements: widget.measurements,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Column(
              children: [
                _header(data),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Farbwerte im Zeitverlauf',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 450,
                          child: _chart(data),
                        ),
                        const SizedBox(height: 16),
                        _statistics(data),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 1050;

                            if (narrow) {
                              return Column(
                                children: [
                                  _measurementTable(data),
                                  const SizedBox(height: 14),
                                  selectedMeasurement == null
                                      ? _emptyBox(
                                          'Messung auswählen, um Details zu sehen.',
                                        )
                                      : _detailsPanel(selectedMeasurement),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _measurementTable(data),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 3,
                                  child: selectedMeasurement == null
                                      ? _emptyBox(
                                          'Messung auswählen, um Details zu sehen.',
                                        )
                                      : _detailsPanel(selectedMeasurement),
                                ),
                              ],
                            );
                          },
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
}
