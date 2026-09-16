import '../main.dart';

class QSAnalysisResult {
  final String answer;

  const QSAnalysisResult(this.answer);
}

class _QSIntent {
  final String type;
  final String? dimension;
  final List<String> baNrs;
  final String? artikelnummer;
  final int? year;

  const _QSIntent(
    this.type, {
    this.dimension,
    this.baNrs = const [],
    this.artikelnummer,
    this.year,
  });
}

class QSAnalyzer {
  final List<Measurement> measurements;

  QSAnalyzer(this.measurements);

  QSAnalysisResult analyze(String question) {
    final q = _normalize(question);

    if (q.isEmpty) {
      return const QSAnalysisResult(
        'Bitte gib eine Frage ein.',
      );
    }

    final intent = _detectIntent(q);

    switch (intent.type) {
      case 'explore':
        return _explorativeAnalyse(intent.year);

      case 'ba_compare':
        return _baVergleich(
          intent.baNrs,
          intent.dimension,
          intent.year,
        );

      case 'ba_development':
        return _baEntwicklung(
          intent.baNrs.first,
          intent.dimension,
          intent.year,
        );

      case 'ba_dimension':
        return _baDimensionAnalyse(
          intent.baNrs.first,
          intent.dimension!,
          intent.year,
        );

      case 'ba_status':
        return _baStatusAnalyse(
          intent.baNrs.first,
          intent.year,
        );

      case 'ba_general':
        return _baStatusAnalyse(
          intent.baNrs.first,
          intent.year,
        );

      case 'article_dimension':
        return _artikelNachMessgroesse(
          intent.dimension!,
          intent.year,
        );

      case 'article_rate':
        return _artikelMitHoechsterFehlerquote(
          intent.year,
        );

      case 'article_deviations':
        return _artikelMitMeistenAbweichungen(
          intent.year,
        );

      case 'dimension_most':
        return _messgroesseMitMeistenAbweichungen(
          intent.year,
        );

      case 'tolerance':
        return _messungenAusserhalbToleranz(
          intent.year,
        );

      case 'general':
        return _allgemeineStatistik(
          intent.year,
        );

      default:
        return const QSAnalysisResult(
          'Ich konnte die Frage noch nicht eindeutig verstehen.\n\n'
          'Zum Beispiel:\n'
          '• Wie hoch ist die Fehlerquote insgesamt?\n'
          '• Was ist bei BA 1001 nicht in Ordnung?\n'
          '• Welche Messgröße hat die meisten Abweichungen?\n'
          '• Vergleiche BA 1001 mit BA 1002.\n'
          '• Wie hat sich BA 1001 entwickelt?\n'
          '• Was fällt dir in den Messdaten auf?',
        );
    }
  }

  // ================================================================
  // INTENTION
  // ================================================================

  _QSIntent _detectIntent(String q) {
    final baNrs = _extractMultipleBaNrs(q);
    final dimension = _detectDimension(q);
    final year = _detectYear(q);
    final artikelnummer = _extractArtikelnummer(q);

    final asksCount = _hasAny(q, [
      'wie viele',
      'wieviel',
      'wieviele',
      'anzahl',
      'zahl',
      'count',
      'wie oft',
    ]);

    final asksStatus = _hasAny(q, [
      'nio',
      'n.i.o',
      'nicht ok',
      'nicht okay',
      'nicht in ordnung',
      'nicht erfuellt',
      'nicht erfüllt',
      'fehler',
      'fehlerhaft',
      'schlecht',
      'abweich',
      'problem',
      'probleme',
      'auffaellig',
      'auffällig',
      'kritisch',
      'ausserhalb',
      'außerhalb',
    ]);

    final asksComparison = _hasAny(q, [
      'vergleich',
      'vergleiche',
      'gegenueber',
      'gegenüber',
      'unterschied',
      'unterschiede',
      'besser',
      'schlechter',
    ]);

    final asksDevelopment = _hasAny(q, [
      'entwicklung',
      'entwicklungen',
      'entwickelt',
      'verlauf',
      'trend',
      'trends',
      'zeit',
      'zeitraum',
      'monate',
      'monatlich',
    ]);

    final isArticle = _hasAny(q, [
      'artikel',
      'produkt',
      'produkte',
      'teil',
      'teile',
      'bauteil',
      'bauteile',
    ]);

    final asksForRate = _hasAny(q, [
      'fehlerquote',
      'fehler rate',
      'fehleranteil',
      'fehler prozent',
      'fehlerprozentsatz',
      'prozent fehler',
      'anteil fehler',
      'rate',
      'quote',
    ]);

    final asksForMost = _hasAny(q, [
      'meisten',
      'meiste',
      'am meisten',
      'höchste',
      'hoechste',
      'stärkste',
      'staerkste',
      'häufigste',
      'haeufigste',
      'häufigsten',
      'haeufigsten',
      'auffälligste',
      'auffaelligste',
      'schlimmste',
      'schlechteste',
      'größten',
      'groessten',
    ]);

    final asksTolerance = _hasAny(q, [
      'toleranz',
      'toleranzen',
      'grenzwert',
      'grenzwerte',
      'ausserhalb',
      'außerhalb',
      'nicht innerhalb',
    ]);

    final asksMeasurements = _hasAny(q, [
      'messung',
      'messungen',
      'messwert',
      'messwerte',
      'ergebnis',
      'ergebnisse',
      'prüfung',
      'pruefung',
      'werte',
      'wert',
    ]);

    // Fragen wie "Was fällt dir auf?" sind explorativ.
    final isExplorative = _hasAny(q, [
      'was faellt dir auf',
      'was faellt dir in den messdaten auf',
      'was fällt dir auf',
      'was fällt dir in den messdaten auf',
      'was wuerdest du dir ansehen',
      'was wuerdest du dir genauer ansehen',
      'was würdest du dir ansehen',
      'was würdest du dir genauer ansehen',
      'worauf sollte ich achten',
      'worauf muss ich achten',
      'etwas auffaellig',
      'etwas auffällig',
      'groessten probleme',
      'größten probleme',
      'wo liegen die probleme',
      'was ist kritisch',
      'welcher bereich sieht am kritischsten aus',
      'genauer untersuchen',
    ]);

    if (isExplorative && baNrs.isEmpty && artikelnummer == null) {
      return _QSIntent(
        'explore',
        year: year,
      );
    }

    // Vergleich mehrerer BAs.
    // Neben "BA 1001 und BA 1002" werden auch natürliche Formen
    // wie "1001 oder 1002" erkannt.
    final comparisonBaNrs = _extractComparisonBaNrs(q);

    if (comparisonBaNrs.length >= 2 &&
        (asksComparison || asksDevelopment)) {
      return _QSIntent(
        'ba_compare',
        baNrs: comparisonBaNrs,
        dimension: dimension,
        year: year,
      );
    }

    // Einzelne BA + Entwicklung/Verlauf.
    if (baNrs.length == 1 && asksDevelopment) {
      return _QSIntent(
        'ba_development',
        baNrs: baNrs,
        dimension: dimension,
        year: year,
      );
    }

    // Einzelne BA + konkrete Messgröße.
    if (baNrs.length == 1 && dimension != null) {
      return _QSIntent(
        'ba_dimension',
        baNrs: baNrs,
        dimension: dimension,
        year: year,
      );
    }

    // Einzelne BA.
    if (baNrs.length == 1) {
      if (asksStatus ||
          asksCount ||
          asksTolerance ||
          asksMeasurements ||
          asksForRate ||
          asksDevelopment) {
        return _QSIntent(
          'ba_status',
          baNrs: baNrs,
          year: year,
        );
      }

      return _QSIntent(
        'ba_general',
        baNrs: baNrs,
        year: year,
      );
    }

    if (isArticle && dimension != null) {
      return _QSIntent(
        'article_dimension',
        dimension: dimension,
        year: year,
      );
    }

    if (isArticle && asksForRate) {
      return _QSIntent(
        'article_rate',
        year: year,
      );
    }

    if (isArticle &&
        (asksForMost || asksStatus)) {
      return _QSIntent(
        'article_deviations',
        year: year,
      );
    }

    // Sem dimensão: "Welche Messgröße hat die meisten Abweichungen?"
    if (dimension == null &&
        (asksForMost || asksStatus) &&
        _hasAny(q, [
          'messgroesse',
          'messgröße',
          'messgroessen',
          'messgrößen',
          'messwert',
          'messwerte',
          'parameter',
        ])) {
      return _QSIntent(
        'dimension_most',
        year: year,
      );
    }

    // "Welche Toleranz wird am häufigsten überschritten?"
    // oder "Wo haben wir die größten Toleranzprobleme?"
    if (dimension == null &&
        asksTolerance &&
        (asksForMost || asksStatus)) {
      return _QSIntent(
        'tolerance',
        year: year,
      );
    }

    // Com dimensão, mas sem artigo/BA:
    // "Wo gibt es Probleme bei L*?"
    if (dimension != null &&
        (asksStatus ||
            asksForMost ||
            asksTolerance)) {
      return _QSIntent(
        'article_dimension',
        dimension: dimension,
        year: year,
      );
    }

    if (asksMeasurements && asksTolerance) {
      return _QSIntent(
        'tolerance',
        year: year,
      );
    }

    if (asksForRate &&
        _hasAny(q, [
          'insgesamt',
          'gesamt',
          'gesamt',
          'overall',
          'allgemein',
        ])) {
      return _QSIntent(
        'general',
        year: year,
      );
    }

    if (_isGeneralStatisticsQuestion(q)) {
      return _QSIntent(
        'general',
        year: year,
      );
    }

    // "Wie hoch ist die Fehlerquote?"
    if (asksForRate && baNrs.isEmpty && !isArticle) {
      return _QSIntent(
        'general',
        year: year,
      );
    }

    return const _QSIntent('unknown');
  }

  // ================================================================
  // ENTITY / FILTER
  // ================================================================

  List<String> _extractComparisonBaNrs(String q) {
    final result = <String>[];

    // Primeiro: todas as BA-Nr explicitamente escritas.
    result.addAll(_extractMultipleBaNrs(q));

    // Depois: procura uma segunda BA escrita apenas como número.
    // Exemplos:
    // "BA 1001 oder 1002"
    // "1001 oder 1002"
    // "BA 1001 und 1002"
    final connectorPattern = RegExp(
      r'(?:und|oder|vs\.?|versus|mit|gegen)\s*'
      r'(?:ba[\s\-]*(?:nr\.?|nummer)?[\s:#\-]*)?'
      r'([0-9]{3,})\b',
    );

    for (final match in connectorPattern.allMatches(q)) {
      final value = match.group(1);

      if (value != null && !result.contains(value)) {
        result.add(value);
      }
    }

    // Fallback específico para perguntas de comparação que mencionam
    // dois números antes/depois de "oder", "und", "vs." etc.
    if (result.length < 2) {
      final fallback = RegExp(
        r'\b([0-9]{3,})\b\s*'
        r'(?:und|oder|vs\.?|versus|gegen|mit)\s*'
        r'(?:ba[\s\-]*)?'
        r'\b([0-9]{3,})\b',
      ).firstMatch(q);

      if (fallback != null) {
        final first = fallback.group(1);
        final second = fallback.group(2);

        if (first != null && !result.contains(first)) {
          result.add(first);
        }

        if (second != null && !result.contains(second)) {
          result.add(second);
        }
      }
    }

    return result;
  }

  List<String> _extractMultipleBaNrs(String q) {
    final result = <String>[];

    final patterns = [
      RegExp(r'ba[\s\-]*nr\.?[\s:#\-]*([0-9]+)'),
      RegExp(r'ba[\s\-]*nummer[\s:#\-]*([0-9]+)'),
      RegExp(r'\bba[\s:#\-]+([0-9]{3,})\b'),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(q)) {
        final value = match.group(1);

        if (value != null && !result.contains(value)) {
          result.add(value);
        }
      }
    }

    // Unterstützt auch:
    // "BA 1001 und 1002"
    // "BA 1001 vs 1002"
    if (result.length == 1) {
      final first = result.first;

      final afterFirst = q.substring(
        q.indexOf(first) + first.length,
      );

      final secondMatch = RegExp(
        r'(?:und|oder|vs\.?|versus|mit|gegen)\s*'
        r'(?:ba[\s\-]*)?([0-9]{3,})',
      ).firstMatch(afterFirst);

      if (secondMatch != null) {
        final second = secondMatch.group(1);

        if (second != null && !result.contains(second)) {
          result.add(second);
        }
      }
    }

    return result;
  }

  String? _extractArtikelnummer(String q) {
    final patterns = [
      RegExp(
        r'artikel(?:nummer|nr)?[\s:#\-]*([a-z0-9][a-z0-9\-_/]*)',
      ),
      RegExp(
        r'produkt(?:nummer|nr)?[\s:#\-]*([a-z0-9][a-z0-9\-_/]*)',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(q);

      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  int? _detectYear(String q) {
    if (_hasAny(q, [
      'letztes jahr',
      'letzten jahr',
      'voriges jahr',
      'vorjahr',
    ])) {
      return DateTime.now().year - 1;
    }

    if (_hasAny(q, [
      'dieses jahr',
      'diesjahr',
      'heuer',
      'aktuelles jahr',
    ])) {
      return DateTime.now().year;
    }

    final match = RegExp(r'\b(20\d{2})\b').firstMatch(q);

    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    return null;
  }

  String? _detectDimension(String q) {
    if (_hasAny(q, [
      'delta e',
      'deltae',
      'delta-e',
      'de*',
      'δe',
    ])) {
      return 'ΔE*';
    }

    if (_hasAny(q, [
      'l*',
      'l wert',
      'l-wert',
      'lwert',
      'helligkeit',
      'helligkeitswert',
    ])) {
      return 'L*';
    }

    if (_hasAny(q, [
      'a*',
      'a wert',
      'a-wert',
      'awert',
    ])) {
      return 'a*';
    }

    if (_hasAny(q, [
      'b*',
      'b wert',
      'b-wert',
      'bwert',
    ])) {
      return 'b*';
    }

    return null;
  }

  bool _isGeneralStatisticsQuestion(String q) {
    return q.contains('wie viele messungen') ||
        q.contains('wieviel messungen') ||
        q.contains('anzahl messungen') ||
        q.contains('messungen insgesamt') ||
        q.contains('gesamtzahl') ||
        q.contains('wie viele sind erfuellt') ||
        q.contains('wie viele sind nicht erfuellt') ||
        q.contains('wie viele messungen sind erfuellt') ||
        q.contains('wie viele messungen sind nicht erfuellt') ||
        q.contains('aktueller stand') ||
        q.contains('aktuellen stand');
  }

  bool _hasAny(String text, List<String> words) {
    for (final word in words) {
      if (text.contains(word)) {
        return true;
      }
    }

    return false;
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ================================================================
  // EXPLORATIVE ANALYSE
  // ================================================================

  QSAnalysisResult _explorativeAnalyse(int? year) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return QSAnalysisResult(
        'Ich habe keine passenden Messdaten gefunden'
        '${year != null ? ' ($year)' : ''}.',
      );
    }

    final total = data.length;
    final nichtErfuellt = data
        .where(
          (m) => _normalize(m.status) == 'nicht erfuellt',
        )
        .length;

    final fehlerquote =
        nichtErfuellt / total * 100;

    int l = 0;
    int a = 0;
    int b = 0;

    for (final m in data) {
      if (m.deltaL.abs() > 1.50) l++;
      if (m.deltaA.abs() > 0.40) a++;
      if (m.deltaB.abs() > 0.40) b++;
    }

    final dimensions = <String, int>{
      'L*': l,
      'a*': a,
      'b*': b,
    };

    final sortedDimensions = dimensions.entries.toList()
      ..sort(
        (x, y) => y.value.compareTo(x.value),
      );

    final artikelFehler = <String, int>{};
    final artikelTotal = <String, int>{};

    for (final m in data) {
      artikelTotal[m.artikelnummer] =
          (artikelTotal[m.artikelnummer] ?? 0) + 1;

      if (_normalize(m.status) == 'nicht erfuellt') {
        artikelFehler[m.artikelnummer] =
            (artikelFehler[m.artikelnummer] ?? 0) + 1;
      }
    }

    final artikel = artikelTotal.keys.toList()
      ..sort(
        (x, y) =>
            (artikelFehler[y] ?? 0).compareTo(
              artikelFehler[x] ?? 0,
            ),
      );

    final auffaelligsterArtikel =
        artikel.isNotEmpty ? artikel.first : null;

    final buffer = StringBuffer();

    buffer.writeln('Analyse der Messdaten');

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln(
      'Ich habe $total Messungen ausgewertet.',
    );
    buffer.writeln(
      'Davon sind $nichtErfuellt n.i.O. '
      '(${fehlerquote.toStringAsFixed(1)} %).',
    );

    buffer.writeln();
    buffer.writeln('Was auffällt:');

    if (sortedDimensions.first.value > 0) {
      buffer.writeln(
        '• ${sortedDimensions.first.key} verursacht mit '
        '${sortedDimensions.first.value} '
        'Toleranzüberschreitungen die meisten Auffälligkeiten.',
      );
    } else {
      buffer.writeln(
        '• Bei L*, a* und b* wurden keine '
        'Toleranzüberschreitungen festgestellt.',
      );
    }

    if (auffaelligsterArtikel != null) {
      final articleErrors =
          artikelFehler[auffaelligsterArtikel] ?? 0;
      final articleTotal =
          artikelTotal[auffaelligsterArtikel] ?? 0;

      final articleRate = articleTotal > 0
          ? articleErrors / articleTotal * 100
          : 0.0;

      buffer.writeln(
        '• Am meisten n.i.O.-Messungen entfallen auf '
        'Artikel $auffaelligsterArtikel: '
        '$articleErrors von $articleTotal '
        '(${articleRate.toStringAsFixed(1)} %).',
      );
    }

    buffer.writeln();
    buffer.writeln(
      'Die wichtigsten Punkte für eine weitere Prüfung '
      'sind daher ${sortedDimensions.first.key}'
      '${auffaelligsterArtikel != null ? ' und Artikel $auffaelligsterArtikel' : ''}.',
    );

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // BA + DIMENSION
  // ================================================================

  QSAnalysisResult _baDimensionAnalyse(
    String baNr,
    String dimension,
    int? year,
  ) {
    final data = _filterByYear(year)
        .where(
          (m) => _baNrMatches(m.baNr, baNr),
        )
        .toList();

    if (data.isEmpty) {
      return QSAnalysisResult(
        'Für BA-Nr $baNr wurden keine Messungen gefunden'
        '${year != null ? ' ($year)' : ''}.',
      );
    }

    int violations = 0;
    double sumAbsDeviation = 0;
    double maxAbsDeviation = 0;

    for (final m in data) {
      double deviation = 0;
      bool outside = false;

      if (dimension == 'L*') {
        deviation = m.deltaL;
        outside = deviation.abs() > 1.50;
      } else if (dimension == 'a*') {
        deviation = m.deltaA;
        outside = deviation.abs() > 0.40;
      } else if (dimension == 'b*') {
        deviation = m.deltaB;
        outside = deviation.abs() > 0.40;
      } else if (dimension == 'ΔE*') {
        deviation = m.deltaE;
        outside = false;
      }

      sumAbsDeviation += deviation.abs();

      if (deviation.abs() > maxAbsDeviation) {
        maxAbsDeviation = deviation.abs();
      }

      if (outside) {
        violations++;
      }
    }

    final violationRate =
        violations / data.length * 100;

    final averageDeviation =
        sumAbsDeviation / data.length;

    final buffer = StringBuffer();

    buffer.writeln(
      'Analyse $dimension für BA-Nr $baNr',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln(
      'Messungen: ${data.length}',
    );

    if (dimension == 'ΔE*') {
      buffer.writeln(
        'Durchschnittliche absolute Abweichung: '
        '${_formatNumber(averageDeviation)}',
      );
      buffer.writeln(
        'Größte ΔE*: ${_formatNumber(maxAbsDeviation)}',
      );
      buffer.writeln();
      buffer.write(
        'Für ΔE* ist im aktuellen Datenmodell keine '
        'eigene Toleranzgrenze hinterlegt. Deshalb '
        'bewerte ich hier die tatsächliche Abweichungsgröße.',
      );
    } else {
      buffer.writeln(
        'Außerhalb der Toleranz: $violations '
        '(${violationRate.toStringAsFixed(1)} %)',
      );
      buffer.writeln(
        'Durchschnittliche absolute Abweichung: '
        '${_formatNumber(averageDeviation)}',
      );
      buffer.writeln(
        'Größte Abweichung: '
        '${_formatNumber(maxAbsDeviation)}',
      );

      buffer.writeln();

      if (violations == 0) {
        buffer.write(
          'Bei $dimension gibt es bei dieser BA '
          'keine Toleranzüberschreitungen.',
        );
      } else {
        buffer.write(
          '$dimension ist bei dieser BA auffällig: '
          '$violations von ${data.length} Messungen '
          'liegen außerhalb der Toleranz.',
        );
      }
    }

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // BA VERGLEICH
  // ================================================================

  QSAnalysisResult _baVergleich(
    List<String> baNrs,
    String? dimension,
    int? year,
  ) {
    if (baNrs.length < 2) {
      return const QSAnalysisResult(
        'Für einen Vergleich werden mindestens zwei BA-Nummern benötigt.',
      );
    }

    final comparison = <String, List<Measurement>>{};

    for (final baNr in baNrs) {
      comparison[baNr] = _filterByYear(year)
          .where(
            (m) => _baNrMatches(m.baNr, baNr),
          )
          .toList();
    }

    final missing = baNrs
        .where(
          (baNr) => comparison[baNr]!.isEmpty,
        )
        .toList();

    if (missing.isNotEmpty) {
      return QSAnalysisResult(
        'Für ${missing.map((e) => 'BA-$e').join(' und ')} '
        'wurden keine Messungen gefunden'
        '${year != null ? ' ($year)' : ''}.',
      );
    }

    final buffer = StringBuffer();

    if (dimension == null) {
      buffer.writeln(
        'Vergleich der BA-Nummern',
      );
    } else {
      buffer.writeln(
        'Vergleich $dimension: ${baNrs.map((e) => 'BA-$e').join(' vs. ')}',
      );
    }

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();

    final rates = <String, double>{};

    for (final baNr in baNrs) {
      final data = comparison[baNr]!;

      final errors = data
          .where(
            (m) => _normalize(m.status) == 'nicht erfuellt',
          )
          .length;

      final rate =
          errors / data.length * 100;

      rates[baNr] = rate;

      if (dimension == null) {
        buffer.writeln(
          'BA-$baNr: $errors von ${data.length} '
          'Messungen nicht erfüllt '
          '(${rate.toStringAsFixed(1)} %)',
        );
      } else {
        final metric = _dimensionMetrics(
          data,
          dimension,
        );

        buffer.writeln(
          'BA-$baNr: ${metric.summary}',
        );
      }
    }

    buffer.writeln();

    if (dimension == null) {
      final sorted = rates.entries.toList()
        ..sort(
          (a, b) => a.value.compareTo(b.value),
        );

      final best = sorted.first;
      final worst = sorted.last;
      final difference =
          worst.value - best.value;

      if (best.key == worst.key) {
        buffer.write(
          'Die Fehlerquoten der verglichenen BAs sind identisch.',
        );
      } else {
        buffer.writeln(
          'Auffälliger ist BA-${worst.key} mit '
          '${worst.value.toStringAsFixed(1)} % Fehlerquote.',
        );
        buffer.write(
          'BA-${best.key} liegt bei '
          '${best.value.toStringAsFixed(1)} %. '
          'Unterschied: '
          '${difference.toStringAsFixed(1)} Prozentpunkte.',
        );
      }
    } else {
      final metrics = <String, _DimensionMetric>{};

      for (final baNr in baNrs) {
        metrics[baNr] = _dimensionMetrics(
          comparison[baNr]!,
          dimension,
        );
      }

      final sorted = metrics.entries.toList()
        ..sort(
          (a, b) =>
              b.value.score.compareTo(a.value.score),
        );

      final most = sorted.first;

      buffer.write(
        'Bei $dimension ist BA-${most.key} '
        'auffälliger nach dem Vergleichswert '
        '(${most.value.score.toStringAsFixed(1)}).',
      );
    }

    if (dimension == null) {
      buffer.writeln();
      buffer.writeln();
      buffer.writeln('Entwicklung über die Zeit:');

      final months = <String>{};

      for (final baNr in baNrs) {
        for (final m in comparison[baNr]!) {
          months.add(
            '${m.datum.year}-'
            '${m.datum.month.toString().padLeft(2, '0')}',
          );
        }
      }

      final sortedMonths = months.toList()..sort();

      for (final month in sortedMonths) {
        final parts = <String>[];

        for (final baNr in baNrs) {
          final data = comparison[baNr]!
              .where(
                (m) =>
                    '${m.datum.year}-'
                    '${m.datum.month.toString().padLeft(2, '0')}' ==
                    month,
              )
              .toList();

          if (data.isEmpty) {
            parts.add('BA-$baNr: keine Daten');
            continue;
          }

          final errors = data
              .where(
                (m) => _normalize(m.status) == 'nicht erfuellt',
              )
              .length;

          final rate =
              errors / data.length * 100;

          parts.add(
            'BA-$baNr: ${rate.toStringAsFixed(1)} %',
          );
        }

        buffer.writeln(
          '${_formatMonth(month)} | ${parts.join(' | ')}',
        );
      }
    }

    return QSAnalysisResult(buffer.toString());
  }

  _DimensionMetric _dimensionMetrics(
    List<Measurement> data,
    String dimension,
  ) {
    int violations = 0;
    double sumAbs = 0;
    double maxAbs = 0;

    for (final m in data) {
      double value = 0;
      bool outside = false;

      if (dimension == 'L*') {
        value = m.deltaL;
        outside = value.abs() > 1.50;
      } else if (dimension == 'a*') {
        value = m.deltaA;
        outside = value.abs() > 0.40;
      } else if (dimension == 'b*') {
        value = m.deltaB;
        outside = value.abs() > 0.40;
      } else if (dimension == 'ΔE*') {
        value = m.deltaE;
        outside = false;
      }

      sumAbs += value.abs();

      if (value.abs() > maxAbs) {
        maxAbs = value.abs();
      }

      if (outside) {
        violations++;
      }
    }

    final average =
        data.isEmpty ? 0.0 : sumAbs / data.length;

    if (dimension == 'ΔE*') {
      return _DimensionMetric(
        score: average,
        summary:
            'Ø |ΔE*| ${_formatNumber(average)}, '
            'Maximum ${_formatNumber(maxAbs)}',
      );
    }

    final rate =
        data.isEmpty ? 0.0 : violations / data.length * 100;

    return _DimensionMetric(
      score: rate,
      summary:
          '$violations von ${data.length} außerhalb '
          '(${rate.toStringAsFixed(1)} %)',
    );
  }

  // ================================================================
  // BA ENTWICKLUNG / TREND
  // ================================================================

  QSAnalysisResult _baEntwicklung(
    String baNr,
    String? dimension,
    int? year,
  ) {
    final data = _filterByYear(year)
        .where(
          (m) => _baNrMatches(m.baNr, baNr),
        )
        .toList()
      ..sort(
        (a, b) => a.datum.compareTo(b.datum),
      );

    if (data.isEmpty) {
      return QSAnalysisResult(
        'Für BA-Nr $baNr wurden keine Messungen gefunden'
        '${year != null ? ' ($year)' : ''}.',
      );
    }

    // Bei einer expliziten Messgröße wird deren Toleranzverlauf
    // analysiert. Ohne Messgröße wird die Fehlerquote betrachtet.
    if (dimension != null) {
      return _baDimensionEntwicklung(
        baNr,
        data,
        dimension,
        year,
      );
    }

    final monthly = <String, List<Measurement>>{};

    for (final m in data) {
      final key =
          '${m.datum.year}-'
          '${m.datum.month.toString().padLeft(2, '0')}';

      monthly.putIfAbsent(key, () => []).add(m);
    }

    final months = monthly.keys.toList()..sort();

    if (months.length < 2) {
      return QSAnalysisResult(
        'Für BA-Nr $baNr gibt es zu wenige Zeitpunkte '
        'für eine aussagekräftige Entwicklung. '
        'Gefunden wurden ${data.length} Messungen.',
      );
    }

    final rates = <String, double>{};

    for (final month in months) {
      final monthData = monthly[month]!;

      final errors = monthData
          .where(
            (m) => _normalize(m.status) == 'nicht erfuellt',
          )
          .length;

      rates[month] =
          errors / monthData.length * 100;
    }

    final first = rates[months.first]!;
    final last = rates[months.last]!;
    final difference = last - first;

    // Durchschnitt der ersten/letzten drei Monate, falls genügend
    // Daten vorhanden sind. Das macht den Trend weniger abhängig
    // von einem einzelnen Monat.
    final firstWindow = months.take(3).toList();
    final lastWindow = months.reversed.take(3).toList();

    final firstAverage = firstWindow
            .map((m) => rates[m]!)
            .fold<double>(0, (sum, value) => sum + value) /
        firstWindow.length;

    final lastAverage = lastWindow
            .map((m) => rates[m]!)
            .fold<double>(0, (sum, value) => sum + value) /
        lastWindow.length;

    final trendDifference = lastAverage - firstAverage;

    String trendText;

    if (trendDifference <= -2.0) {
      trendText = 'verbessert';
    } else if (trendDifference >= 2.0) {
      trendText = 'verschlechtert';
    } else {
      trendText = 'weitgehend stabil';
    }

    final buffer = StringBuffer();

    buffer.writeln(
      'Entwicklung von BA-Nr $baNr',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    } else {
      buffer.writeln(
        'Zeitraum: ${_formatDate(data.first.datum)} '
        'bis ${_formatDate(data.last.datum)}',
      );
    }

    buffer.writeln();
    buffer.writeln(
      'Gesamt: ${data.length} Messungen',
    );
    buffer.writeln(
      'Erste Monatsquote: ${first.toStringAsFixed(1)} % n.i.O.',
    );
    buffer.writeln(
      'Letzte Monatsquote: ${last.toStringAsFixed(1)} % n.i.O.',
    );

    buffer.writeln();
    buffer.writeln(
      'Trend: Die Situation hat sich $trendText.',
    );

    if (trendDifference.abs() >= 0.1) {
      final direction =
          trendDifference < 0 ? 'gesunken' : 'gestiegen';

      buffer.writeln(
        'Die durchschnittliche Fehlerquote der ersten '
        'drei Monate liegt bei '
        '${firstAverage.toStringAsFixed(1)} %, '
        'die der letzten drei Monate bei '
        '${lastAverage.toStringAsFixed(1)} %. '
        'Damit ist sie um '
        '${trendDifference.abs().toStringAsFixed(1)} '
        'Prozentpunkte $direction.',
      );
    }

    buffer.writeln();
    buffer.writeln('Monatliche Entwicklung:');

    for (final month in months) {
      buffer.writeln(
        '${_formatMonth(month)}: '
        '${rates[month]!.toStringAsFixed(1)} % n.i.O.',
      );
    }

    return QSAnalysisResult(buffer.toString());
  }

  QSAnalysisResult _baDimensionEntwicklung(
    String baNr,
    List<Measurement> data,
    String dimension,
    int? year,
  ) {
    final monthly = <String, List<Measurement>>{};

    for (final m in data) {
      final key =
          '${m.datum.year}-'
          '${m.datum.month.toString().padLeft(2, '0')}';

      monthly.putIfAbsent(key, () => []).add(m);
    }

    final months = monthly.keys.toList()..sort();

    if (months.isEmpty) {
      return const QSAnalysisResult(
        'Keine Zeitdaten für die Analyse verfügbar.',
      );
    }

    final scores = <String, double>{};

    for (final month in months) {
      final metric = _dimensionMetrics(
        monthly[month]!,
        dimension,
      );

      scores[month] = metric.score;
    }

    final first = scores[months.first]!;
    final last = scores[months.last]!;
    final difference = last - first;

    String trend;

    if (dimension == 'ΔE*') {
      if (difference <= -0.10) {
        trend = 'verbessert';
      } else if (difference >= 0.10) {
        trend = 'verschlechtert';
      } else {
        trend = 'weitgehend stabil';
      }
    } else {
      if (difference <= -2.0) {
        trend = 'verbessert';
      } else if (difference >= 2.0) {
        trend = 'verschlechtert';
      } else {
        trend = 'weitgehend stabil';
      }
    }

    final buffer = StringBuffer();

    buffer.writeln(
      'Entwicklung $dimension für BA-Nr $baNr',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln(
      'Trend: $trend.',
    );

    buffer.writeln(
      'Erster Zeitraum: ${_formatMetricScore(first, dimension)}',
    );
    buffer.writeln(
      'Letzter Zeitraum: ${_formatMetricScore(last, dimension)}',
    );

    buffer.writeln();
    buffer.writeln('Monatliche Entwicklung:');

    for (final month in months) {
      buffer.writeln(
        '${_formatMonth(month)}: '
        '${_formatMetricScore(scores[month]!, dimension)}',
      );
    }

    return QSAnalysisResult(buffer.toString());
  }

  String _formatMetricScore(
    double value,
    String dimension,
  ) {
    if (dimension == 'ΔE*') {
      return 'Ø |ΔE*| ${_formatNumber(value)}';
    }

    return '${value.toStringAsFixed(1)} % außerhalb';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  // ================================================================
  // BA STATUS
  // ================================================================

  QSAnalysisResult _baStatusAnalyse(
    String baNr,
    int? year,
  ) {
    final data = _filterByYear(year)
        .where(
          (m) => _baNrMatches(m.baNr, baNr),
        )
        .toList();

    if (data.isEmpty) {
      return QSAnalysisResult(
        'Für BA-Nr $baNr wurden keine Messungen gefunden'
        '${year != null ? ' ($year)' : ''}.',
      );
    }

    final gesamt = data.length;

    final nichtErfuellt = data
        .where(
          (m) => _normalize(m.status) == 'nicht erfuellt',
        )
        .length;

    final erfuellt = gesamt - nichtErfuellt;
    final fehlerquote =
        nichtErfuellt / gesamt * 100;

    int l = 0;
    int a = 0;
    int b = 0;

    for (final m in data) {
      if (m.deltaL.abs() > 1.50) l++;
      if (m.deltaA.abs() > 0.40) a++;
      if (m.deltaB.abs() > 0.40) b++;
    }

    final dimensions = <String, int>{
      'L*': l,
      'a*': a,
      'b*': b,
    };

    final sortedDimensions = dimensions.entries.toList()
      ..sort(
        (x, y) => y.value.compareTo(x.value),
      );

    final allData = _filterByYear(year);

    final allErrors = allData
        .where(
          (m) => _normalize(m.status) == 'nicht erfuellt',
        )
        .length;

    final overallRate = allData.isEmpty
        ? 0.0
        : allErrors / allData.length * 100;

    final buffer = StringBuffer();

    buffer.writeln('BA-Nr $baNr');

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln(
      'Gesamt: $gesamt Messungen',
    );
    buffer.writeln(
      'Erfüllt: $erfuellt '
      '(${(erfuellt / gesamt * 100).toStringAsFixed(1)} %)',
    );
    buffer.writeln(
      'Nicht erfüllt: $nichtErfuellt '
      '(${fehlerquote.toStringAsFixed(1)} %)',
    );

    buffer.writeln();
    buffer.writeln('Was fällt auf?');

    if (nichtErfuellt == 0) {
      buffer.writeln(
        '• Keine n.i.O.-Messungen.',
      );
    } else {
      buffer.writeln(
        '• ${sortedDimensions.first.key} weist mit '
        '${sortedDimensions.first.value} '
        'Toleranzüberschreitungen die meisten '
        'Abweichungen auf.',
      );
    }

    if (fehlerquote > overallRate) {
      buffer.writeln(
        '• Die Fehlerquote liegt über dem '
        'Vergleichswert von '
        '${overallRate.toStringAsFixed(1)} %.',
      );
    } else if (fehlerquote < overallRate) {
      buffer.writeln(
        '• Die Fehlerquote liegt unter dem '
        'Vergleichswert von '
        '${overallRate.toStringAsFixed(1)} %.',
      );
    } else {
      buffer.writeln(
        '• Die Fehlerquote entspricht dem '
        'Vergleichswert von '
        '${overallRate.toStringAsFixed(1)} %.',
      );
    }

    buffer.writeln();
    buffer.write(
      'Damit ist ${sortedDimensions.first.key} '
      'der erste Bereich, den ich genauer untersuchen würde.',
    );

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // ALLGEMEIN
  // ================================================================

  QSAnalysisResult _allgemeineStatistik(int? year) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return QSAnalysisResult(
        'Es sind keine Messdaten verfügbar'
        '${year != null ? ' ($year)' : ''}.',
      );
    }

    final gesamt = data.length;

    final erfuellt = data
        .where(
          (m) => _normalize(m.status) == 'erfuellt',
        )
        .length;

    final nichtErfuellt = data
        .where(
          (m) => _normalize(m.status) == 'nicht erfuellt',
        )
        .length;

    final erfuelltQuote =
        erfuellt / gesamt * 100;

    final fehlerquote =
        nichtErfuellt / gesamt * 100;

    final buffer = StringBuffer();

    buffer.writeln('QS-Messstatistik');

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln(
      'Gesamt: $gesamt Messungen',
    );
    buffer.writeln(
      'Erfüllt: $erfuellt '
      '(${erfuelltQuote.toStringAsFixed(1)} %)',
    );
    buffer.write(
      'Nicht erfüllt: $nichtErfuellt '
      '(${fehlerquote.toStringAsFixed(1)} %)',
    );

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // TOLERANZ
  // ================================================================

  QSAnalysisResult _messungenAusserhalbToleranz(int? year) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return const QSAnalysisResult(
        'Es sind keine Messdaten verfügbar.',
      );
    }

    final ausserhalb = data
        .where(
          (m) => _normalize(m.status) == 'nicht erfuellt',
        )
        .toList();

    if (ausserhalb.isEmpty) {
      return const QSAnalysisResult(
        'Es wurden keine Messungen außerhalb der Toleranz gefunden.',
      );
    }

    int l = 0;
    int a = 0;
    int b = 0;

    for (final m in ausserhalb) {
      if (m.deltaL.abs() > 1.50) l++;
      if (m.deltaA.abs() > 0.40) a++;
      if (m.deltaB.abs() > 0.40) b++;
    }

    final values = <String, int>{
      'L*': l,
      'a*': a,
      'b*': b,
    };

    final sorted = values.entries.toList()
      ..sort(
        (x, y) => y.value.compareTo(x.value),
      );

    final buffer = StringBuffer();

    buffer.writeln(
      '${ausserhalb.length} Messungen sind nicht erfüllt.',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln('Überschrittene Toleranzen:');

    for (final entry in sorted) {
      buffer.writeln(
        '${entry.key}: ${entry.value}',
      );
    }

    buffer.writeln();
    buffer.write(
      '${sorted.first.key} ist dabei die häufigste '
      'Toleranzüberschreitung.',
    );

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // MESSGRÖSSE OHNE VORGEGEBENE DIMENSION
  // ================================================================

  QSAnalysisResult _messgroesseMitMeistenAbweichungen(
    int? year,
  ) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return const QSAnalysisResult(
        'Es sind keine Messdaten verfügbar.',
      );
    }

    int l = 0;
    int a = 0;
    int b = 0;

    for (final m in data) {
      if (m.deltaL.abs() > 1.50) l++;
      if (m.deltaA.abs() > 0.40) a++;
      if (m.deltaB.abs() > 0.40) b++;
    }

    final values = <String, int>{
      'L*': l,
      'a*': a,
      'b*': b,
    };

    final sorted = values.entries.toList()
      ..sort(
        (x, y) => y.value.compareTo(x.value),
      );

    final buffer = StringBuffer();

    buffer.writeln(
      'Welche Messgröße ist am auffälligsten?',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();
    buffer.writeln(
      'Am häufigsten außerhalb der Toleranz: '
      '${sorted.first.key} '
      '(${sorted.first.value} Fälle).',
    );
    buffer.writeln();
    buffer.writeln('Aufschlüsselung:');

    for (final entry in sorted) {
      buffer.writeln(
        '${entry.key}: ${entry.value}',
      );
    }

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // ARTIKEL + DIMENSION
  // ================================================================

  QSAnalysisResult _artikelNachMessgroesse(
    String dimension,
    int? year,
  ) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return const QSAnalysisResult(
        'Es sind keine Messdaten verfügbar.',
      );
    }

    final total = <String, int>{};
    final errors = <String, int>{};

    for (final m in data) {
      final artikel = m.artikelnummer;

      total[artikel] =
          (total[artikel] ?? 0) + 1;

      bool outside = false;

      if (dimension == 'L*') {
        outside = m.deltaL.abs() > 1.50;
      } else if (dimension == 'a*') {
        outside = m.deltaA.abs() > 0.40;
      } else if (dimension == 'b*') {
        outside = m.deltaB.abs() > 0.40;
      } else if (dimension == 'ΔE*') {
        // Es gibt aktuell keine eigene ΔE*-Toleranz.
        outside =
            _normalize(m.status) == 'nicht erfuellt';
      }

      if (outside) {
        errors[artikel] =
            (errors[artikel] ?? 0) + 1;
      }
    }

    final artikel = total.keys.toList()
      ..sort(
        (a, b) =>
            (errors[b] ?? 0).compareTo(
              errors[a] ?? 0,
            ),
      );

    final top = artikel.take(5).toList();

    final buffer = StringBuffer();

    buffer.writeln(
      'Artikel mit den meisten $dimension-Auffälligkeiten:',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();

    for (var i = 0; i < top.length; i++) {
      final name = top[i];
      final error = errors[name] ?? 0;
      final count = total[name] ?? 0;
      final quote =
          count > 0 ? error / count * 100 : 0.0;

      buffer.writeln(
        '${i + 1}. $name: '
        '$error von $count Messungen '
        '(${quote.toStringAsFixed(1)} %)',
      );
    }

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // ARTIKEL MIT MEISTEN ABWEICHUNGEN
  // ================================================================

  QSAnalysisResult _artikelMitMeistenAbweichungen(
    int? year,
  ) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return const QSAnalysisResult(
        'Es sind keine Messdaten verfügbar.',
      );
    }

    final total = <String, int>{};
    final errors = <String, int>{};

    for (final m in data) {
      final artikel = m.artikelnummer;

      total[artikel] =
          (total[artikel] ?? 0) + 1;

      if (_normalize(m.status) == 'nicht erfuellt') {
        errors[artikel] =
            (errors[artikel] ?? 0) + 1;
      }
    }

    final artikel = total.keys.toList()
      ..sort(
        (a, b) =>
            (errors[b] ?? 0).compareTo(
              errors[a] ?? 0,
            ),
      );

    final top = artikel.take(5).toList();

    final buffer = StringBuffer();

    buffer.writeln(
      'Artikel mit den meisten Abweichungen:',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();

    for (var i = 0; i < top.length; i++) {
      final name = top[i];
      final error = errors[name] ?? 0;
      final count = total[name] ?? 0;
      final quote =
          count > 0 ? error / count * 100 : 0.0;

      buffer.writeln(
        '${i + 1}. $name: '
        '$error von $count Messungen nicht erfüllt '
        '(${quote.toStringAsFixed(1)} %)',
      );
    }

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // HÖCHSTE FEHLERQUOTE
  // ================================================================

  QSAnalysisResult _artikelMitHoechsterFehlerquote(
    int? year,
  ) {
    final data = _filterByYear(year);

    if (data.isEmpty) {
      return const QSAnalysisResult(
        'Es sind keine Messdaten verfügbar.',
      );
    }

    final total = <String, int>{};
    final errors = <String, int>{};

    for (final m in data) {
      final artikel = m.artikelnummer;

      total[artikel] =
          (total[artikel] ?? 0) + 1;

      if (_normalize(m.status) == 'nicht erfuellt') {
        errors[artikel] =
            (errors[artikel] ?? 0) + 1;
      }
    }

    final artikel = total.keys.toList()
      ..sort(
        (a, b) {
          final qa =
              (errors[a] ?? 0) / (total[a] ?? 1);
          final qb =
              (errors[b] ?? 0) / (total[b] ?? 1);

          return qb.compareTo(qa);
        },
      );

    final top = artikel.take(5).toList();

    final buffer = StringBuffer();

    buffer.writeln(
      'Artikel mit der höchsten Fehlerquote:',
    );

    if (year != null) {
      buffer.writeln('Zeitraum: $year');
    }

    buffer.writeln();

    for (var i = 0; i < top.length; i++) {
      final name = top[i];
      final count = total[name] ?? 0;
      final error = errors[name] ?? 0;
      final quote =
          count > 0 ? error / count * 100 : 0.0;

      buffer.writeln(
        '${i + 1}. $name: '
        '${quote.toStringAsFixed(1)} % '
        '($error von $count Messungen nicht erfüllt)',
      );
    }

    return QSAnalysisResult(buffer.toString());
  }

  // ================================================================
  // HELPERS
  // ================================================================

  List<Measurement> _filterByYear(int? year) {
    if (year == null) {
      return measurements;
    }

    return measurements
        .where(
          (m) => m.datum.year == year,
        )
        .toList();
  }

  bool _baNrMatches(
    String value,
    String requested,
  ) {
    final valueKey =
        value.replaceAll(RegExp(r'[^0-9]'), '');

    final requestedKey =
        requested.replaceAll(RegExp(r'[^0-9]'), '');

    return valueKey.isNotEmpty &&
        requestedKey.isNotEmpty &&
        valueKey == requestedKey;
  }

  String _formatMonth(String value) {
    final parts = value.split('-');

    if (parts.length != 2) {
      return value;
    }

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

    final month = int.tryParse(parts[1]);

    if (month == null ||
        month < 1 ||
        month > 12) {
      return value;
    }

    return '${months[month - 1]} ${parts[0]}';
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAll('.', ',');
  }
}

class _DimensionMetric {
  final double score;
  final String summary;

  const _DimensionMetric({
    required this.score,
    required this.summary,
  });
}
