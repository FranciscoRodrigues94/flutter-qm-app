import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/messungen_page.dart';
import 'pages/analyse_page.dart';
import 'pages/frag_ai_page.dart';
import 'widgets/sidebar.dart';

void main() {
  runApp(const QSApp());
}

class QSApp extends StatelessWidget {
  const QSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QS Farbanalyse',

      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('de', 'DE'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF172554),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class Measurement {
  final String bezug;
  final String artikelnummer;
  final String name;
  final DateTime datum;
  final String status;
  final String benutzer;
  final String lichtart;
  final String baNr;

  final double l;
  final double a;
  final double b;

  final double deltaL;
  final double deltaA;
  final double deltaB;
  final double deltaE;

  Measurement({
    required this.bezug,
    required this.artikelnummer,
    required this.name,
    required this.datum,
    required this.status,
    required this.benutzer,
    required this.lichtart,
    required this.baNr,
    required this.l,
    required this.a,
    required this.b,
    required this.deltaL,
    required this.deltaA,
    required this.deltaB,
    required this.deltaE,
  });
}

class MonthlyCount {
  final DateTime month;
  final int count;

  MonthlyCount({
    required this.month,
    required this.count,
  });
}

class ArticleFailure {
  final String artikelnummer;
  final String name;
  final int count;

  ArticleFailure({
    required this.artikelnummer,
    required this.name,
    required this.count,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Measurement> measurements = [];

  bool loading = true;
  String? error;

  DateTime? selectedMonth;

  @override
  void initState() {
    super.initState();
    loadCsv();
  }

  List<String> parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();

    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString().trim());

    return result;
  }

  List<List<String>> parseCsv(String content) {
    final lines = content
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return lines.map(parseCsvLine).toList();
  }

  DateTime parseGermanDate(String value) {
    final parts = value.trim().split(' ');
    final dateParts = parts[0].split('.');

    if (dateParts.length != 3) {
      throw FormatException('Ungültiges Datum: $value');
    }

    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    int hour = 0;
    int minute = 0;

    if (parts.length > 1) {
      final timeParts = parts[1].split(':');

      hour = int.tryParse(timeParts[0]) ?? 0;

      if (timeParts.length > 1) {
        minute = int.tryParse(timeParts[1]) ?? 0;
      }
    }

    return DateTime(year, month, day, hour, minute);
  }

  double parseGermanNumber(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return 0;
    }

    return double.tryParse(text.replaceAll(',', '.')) ?? 0;
  }

  String monthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];

    return months[date.month - 1];
  }

  bool sameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  Future<void> loadCsv() async {
    try {
      final csvString = await rootBundle.loadString(
        'assets/QS_FakeDaten_mit_Bezug.csv',
      );

      final rows = parseCsv(csvString);

      if (rows.isEmpty) {
        throw Exception('CSV ist leer.');
      }

      final headers = rows.first;

      final columnIndex = <String, int>{};

      for (int i = 0; i < headers.length; i++) {
        columnIndex[headers[i].trim()] = i;
      }

      String value(List<String> row, String column) {
        final index = columnIndex[column];

        if (index == null || index >= row.length) {
          return '';
        }

        return row[index].trim();
      }

      final loadedMeasurements = <Measurement>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.isEmpty) {
          continue;
        }

        final bezugValue = value(row, 'Bezug');
        final datumValue = value(row, 'Datum');

        if (bezugValue == 'Bezug') {
          continue;
        }

        if (datumValue.isEmpty) {
          continue;
        }

        loadedMeasurements.add(
          Measurement(
            bezug: bezugValue,
            artikelnummer: value(row, 'Artikelnummer'),
            name: value(row, 'Name_Suche'),
            datum: parseGermanDate(datumValue),
            status: value(row, 'erfüllt'),
            benutzer: value(row, 'Benutzer'),
            lichtart: value(row, 'Lichtart'),
            baNr: value(row, 'BA-Nr.'),
            l: parseGermanNumber(value(row, 'L*')),
            a: parseGermanNumber(value(row, 'a*')),
            b: parseGermanNumber(value(row, 'b*')),
            deltaL: parseGermanNumber(value(row, 'ΔL* ±1,5')),
            deltaA: parseGermanNumber(value(row, 'Δa* ±0,40')),
            deltaB: parseGermanNumber(value(row, 'Δb* ±0,40')),
            deltaE: parseGermanNumber(value(row, 'ΔE*')),
          ),
        );
      }

      setState(() {
        measurements = loadedMeasurements;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  List<Measurement> get filteredMeasurements {
    if (selectedMonth == null) {
      return measurements;
    }

    return measurements
        .where((m) => sameMonth(m.datum, selectedMonth!))
        .toList();
  }

  List<MonthlyCount> get monthlyData {
    final Map<String, int> counts = {};

    for (final measurement in measurements) {
      final key =
          '${measurement.datum.year}-${measurement.datum.month.toString().padLeft(2, '0')}';

      counts[key] = (counts[key] ?? 0) + 1;
    }

    final months = counts.keys.toList()..sort();

    return months.map((key) {
      final parts = key.split('-');

      return MonthlyCount(
        month: DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
        ),
        count: counts[key]!,
      );
    }).toList();
  }

  List<ArticleFailure> get top5Failures {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final measurement in filteredMeasurements) {
      if (measurement.status.trim().toLowerCase() !=
          'nicht erfüllt') {
        continue;
      }

      final number = measurement.artikelnummer;

      if (!grouped.containsKey(number)) {
        grouped[number] = {
          'name': measurement.name,
          'count': 0,
        };
      }

      grouped[number]!['count'] =
          (grouped[number]!['count'] as int) + 1;
    }

    final result = grouped.entries.map((entry) {
      return ArticleFailure(
        artikelnummer: entry.key,
        name: entry.value['name'] as String,
        count: entry.value['count'] as int,
      );
    }).toList();

    result.sort((a, b) => b.count.compareTo(a.count));

    return result.take(5).toList();
  }

  int get totalCount => filteredMeasurements.length;

  int get passedCount => filteredMeasurements
      .where((m) => m.status.trim().toLowerCase() == 'erfüllt')
      .length;

  int get failedCount => filteredMeasurements
      .where((m) =>
          m.status.trim().toLowerCase() == 'nicht erfüllt')
      .length;

  Widget buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBackground,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF172554),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard() {
    final total = filteredMeasurements.length;

    final passedPercent =
        total == 0 ? 0.0 : (passedCount / total) * 100;

    final failedPercent =
        total == 0 ? 0.0 : (failedCount / total) * 100;

    return Container(
      height: 145,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ergebnisverteilung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: resultItem(
                  label: 'Erfüllt',
                  value: passedPercent,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: resultItem(
                  label: 'Nicht erfüllt',
                  value: failedPercent,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget resultItem({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget buildChartCard() {
    final data = monthlyData;

    int maxCount = 1;

    for (final item in data) {
      if (item.count > maxCount) {
        maxCount = item.count;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Messungen nach Monat',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Klicke auf einen Monat, um den Dashboard-Filter zu setzen.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: data.length * 62.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((item) {
                    final isSelected =
                        selectedMonth != null &&
                        sameMonth(item.month, selectedMonth!);

                    final height =
                        110 * item.count / maxCount;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMonth =
                              isSelected ? null : item.month;
                        });
                      },
                      child: SizedBox(
                        width: 62,
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            Text(
                              '${item.count}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 5),
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              width: 28,
                              height: height,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF172554)
                                    : const Color(0xFF4F46E5),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              monthName(item.month),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF172554)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '${item.month.year}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (selectedMonth != null)
            Row(
              children: [
                const Icon(
                  Icons.filter_alt,
                  size: 15,
                  color: Color(0xFF172554),
                ),
                const SizedBox(width: 6),
                Text(
                  'Filter: ${monthName(selectedMonth!)} ${selectedMonth!.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172554),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedMonth = null;
                    });
                  },
                  child: const Text('Filter löschen'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildTop5Card() {
    final top5 = top5Failures;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Top 5 – nicht erfüllt',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Artikel mit den meisten nicht erfüllten Messungen',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: top5.isEmpty
                ? const Center(
                    child: Text(
                      'Keine nicht erfüllten Messungen.',
                    ),
                  )
                : ListView.separated(
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: top5.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = top5[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: index == 0
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Artikelnummer: ${item.artikelnummer}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.count}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB91C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem({
    required IconData icon,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final item = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF315A8A)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return item;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Fehler beim Laden der Daten:\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final uniqueArticles = measurements
        .map((m) => m.artikelnummer)
        .where((value) => value.isNotEmpty)
        .toSet()
        .length;

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedPage: 'Dashboard',
            onMessungen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MessungenPage(
                    measurements: measurements,
                  ),
                ),
              );
            },
            onAnalyse: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalysePage(
                    measurements: measurements,
                  ),
                ),
              );
            },
            onFragAI: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FragAIPage(
                    measurements: measurements,
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qualitätsanalyse',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Übersicht der wichtigsten Messungen und Abweichungen.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 17,
                              ),
                              SizedBox(width: 8),
                              Text('Alle Daten'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        buildKpiCard(
                          title: 'Gesamt Messungen',
                          value: '$totalCount',
                          icon: Icons.receipt_long_outlined,
                          iconBackground:
                              const Color(0xFFE0F2FE),
                        ),
                        const SizedBox(width: 14),
                        buildKpiCard(
                          title: 'Erfüllt',
                          value: '$passedCount',
                          icon: Icons.check_circle_outline,
                          iconBackground:
                              const Color(0xFFDCFCE7),
                        ),
                        const SizedBox(width: 14),
                        buildKpiCard(
                          title: 'Nicht erfüllt',
                          value: '$failedCount',
                          icon: Icons.warning_amber_outlined,
                          iconBackground:
                              const Color(0xFFFEE2E2),
                        ),
                        const SizedBox(width: 14),
                        buildKpiCard(
                          title: 'Artikel',
                          value: '$uniqueArticles',
                          icon: Icons.inventory_2_outlined,
                          iconBackground:
                              const Color(0xFFEDE9FE),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Expanded(
                                  child: buildChartCard(),
                                ),
                                const SizedBox(height: 20),
                                buildResultCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: buildTop5Card(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}