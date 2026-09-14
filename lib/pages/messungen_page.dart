import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'messungsdetails_page.dart';
import 'analyse_page.dart';

class MessungenPage extends StatefulWidget {
  final List<dynamic> measurements;

  const MessungenPage({
    super.key,
    required this.measurements,
  });

  @override
  State<MessungenPage> createState() => _MessungenPageState();
}

class _MessungenPageState extends State<MessungenPage> {
  final TextEditingController baNrController =
      TextEditingController();

  final TextEditingController datumController =
      TextEditingController();

  final TextEditingController benutzerController =
      TextEditingController();

  final TextEditingController artikelController =
      TextEditingController();

  String selectedErgebnis = 'Alle';

  @override
  void dispose() {
    baNrController.dispose();
    datumController.dispose();
    benutzerController.dispose();
    artikelController.dispose();

    super.dispose();
  }

  // ============================================================
  // ERKENNT DIE BEZUG-ZEILE
  // ============================================================

  bool isReference(dynamic m) {
    final String artikel =
        m.artikelnummer.toString().trim();

    final String bezug =
        m.bezug.toString().trim();

    final String baNr =
        m.baNr.toString().trim();

    final String benutzer =
        m.benutzer.toString().trim();

    if (artikel.isNotEmpty &&
        artikel == bezug &&
        baNr.isEmpty &&
        benutzer.isEmpty) {
      return true;
    }

    if (artikel == 'Schwarz RR' &&
        baNr.isEmpty &&
        benutzer.isEmpty) {
      return true;
    }

    return false;
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<dynamic> get filteredMeasurements {
    return widget.measurements.where((m) {
      final baNr = m.baNr.toString();
      final datum = m.datum.toString();
      final benutzer = m.benutzer.toString();
      final artikelnummer = m.artikelnummer.toString();

      final bool reference = isReference(m);

      final baNrMatch =
          baNrController.text.trim().isEmpty ||
          baNr.toLowerCase().contains(
                baNrController.text.trim().toLowerCase(),
              );

      final datumMatch =
          datumController.text.trim().isEmpty ||
          datum.toLowerCase().contains(
                datumController.text.trim().toLowerCase(),
              );

      final benutzerMatch =
          benutzerController.text.trim().isEmpty ||
          benutzer.toLowerCase().contains(
                benutzerController.text.trim().toLowerCase(),
              );

      final artikelMatch =
          artikelController.text.trim().isEmpty ||
          artikelnummer.toLowerCase().contains(
                artikelController.text.trim().toLowerCase(),
              );

      bool ergebnisMatch = true;

      if (!reference) {
        if (selectedErgebnis == 'Erfüllt') {
          ergebnisMatch = m.status == 'erfüllt';
        }

        if (selectedErgebnis == 'Nicht erfüllt') {
          ergebnisMatch =
              m.status == 'nicht erfüllt';
        }
      }

      return baNrMatch &&
          datumMatch &&
          benutzerMatch &&
          artikelMatch &&
          ergebnisMatch;
    }).toList();
  }

  // ============================================================
  // FILTER ZURÜCKSETZEN
  // ============================================================

  void clearFilters() {
    setState(() {
      baNrController.clear();
      datumController.clear();
      benutzerController.clear();
      artikelController.clear();
      selectedErgebnis = 'Alle';
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filtered = filteredMeasurements;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          AppSidebar(
            selectedPage: 'Messungen',

            onDashboard: () {
              Navigator.pop(context);
            },

            // ==================================================
            // NAVEGAÇÃO PARA ANALYSE
            // ==================================================

            onAnalyse: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalysePage(
                    measurements: widget.measurements,
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Messungen',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '${filtered.length} Ergebnisse',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        _buildFilterCard(),

                        const SizedBox(height: 20),

                        Expanded(
                          child: _buildTable(filtered),
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
  // FILTER CARD
  // ============================================================

  Widget _buildFilterCard() {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _filterField(
                  controller: baNrController,
                  label: 'BA-Nr.',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _filterField(
                  controller: datumController,
                  label: 'Datum',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _filterField(
                  controller: benutzerController,
                  label: 'Benutzer',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _filterField(
                  controller: artikelController,
                  label: 'Artikelnummer',
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedErgebnis,
                  decoration: InputDecoration(
                    labelText: 'Ergebnis',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Alle',
                      child: Text('Alle'),
                    ),
                    DropdownMenuItem(
                      value: 'Erfüllt',
                      child: Text('Erfüllt'),
                    ),
                    DropdownMenuItem(
                      value: 'Nicht erfüllt',
                      child: Text('Nicht erfüllt'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedErgebnis =
                          value ?? 'Alle';
                    });
                  },
                ),
              ),

              const SizedBox(width: 14),

              OutlinedButton(
                onPressed: clearFilters,
                style:
                    OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  side: const BorderSide(
                    color: Color(0xFFCBD5E1),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Zurücksetzen',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER FIELD
  // ============================================================

  Widget _filterField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }

  // ============================================================
  // TABLE
  // ============================================================

  Widget _buildTable(List<dynamic> data) {
    if (data.isEmpty) {
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
        child: const Text(
          'Keine Messungen gefunden.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(14),
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              color: const Color(0xFFF8FAFC),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Datum',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      'Artikelnummer',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      'BA-Nr.',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      'Benutzer',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      'Ergebnis',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // ROWS
            // ==================================================

            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder:
                    (context, index) {
                  final m = data[index];

                  final bool reference =
                      isReference(m);

                  final bool erfuellt =
                      !reference &&
                      m.status == 'erfüllt';

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration:
                        const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color:
                              Color(0xFFF1F5F9),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            m.datum.toString(),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            m.artikelnummer
                                .toString(),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            m.baNr.toString(),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            m.benutzer.toString(),
                          ),
                        ),

                        // ==================================================
                        // ERGEBNIS
                        // ==================================================

                        Expanded(
                          flex: 2,
                          child: reference
                              ? const SizedBox()
                              : Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: erfuellt
                                            ? const Color(
                                                0xFFDCFCE7,
                                              )
                                            : const Color(
                                                0xFFFEE2E2,
                                              ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        erfuellt
                                            ? 'Erfüllt'
                                            : 'Nicht erfüllt',
                                        style:
                                            TextStyle(
                                          color: erfuellt
                                              ? const Color(
                                                  0xFF166534,
                                                )
                                              : const Color(
                                                  0xFF991B1B,
                                                ),
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        // ==================================================
                        // DETAILS
                        // ==================================================

                        Expanded(
                          flex: 1,
                          child: IconButton(
                            tooltip:
                                'Details anzeigen',
                            icon: const Icon(
                              Icons.open_in_new,
                              size: 20,
                              color:
                                  Color(0xFF475569),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MessungsdetailsPage(
                                    measurement: m,
                                  ),
                                ),
                              );
                            },
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
      ),
    );
  }
}