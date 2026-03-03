import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/user_profile.dart';

enum _Period {
  today('TODAY', Duration(hours: 24)),
  week('LAST 7 DAYS', Duration(days: 7)),
  month('LAST 30 DAYS', Duration(days: 30)),
  allTime('ALL TIME', Duration.zero);

  const _Period(this.label, this.duration);
  final String label;
  final Duration duration;
}

class SOSHistoryScreen extends StatefulWidget {
  final UserProfile userProfile;

  const SOSHistoryScreen({super.key, required this.userProfile});

  @override
  State<SOSHistoryScreen> createState() => _SOSHistoryScreenState();
}

class _SOSHistoryScreenState extends State<SOSHistoryScreen> {
  _Period _selectedPeriod = _Period.week;

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('sos_alert_history')
        .orderBy('timestamp', descending: true);

    if (_selectedPeriod != _Period.allTime) {
      final startDate = DateTime.now().subtract(_selectedPeriod.duration);
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    return query.snapshots();
  }

  List<Map<String, dynamic>> _applyDistrictFilter(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final data = docs.map((d) => d.data()).toList();
    if (widget.userProfile.isSuperAdmin ||
        widget.userProfile.assignedDistricts.isEmpty) {
      return data;
    }
    return data.where((d) {
      final district = d['district'] as String?;
      return district != null &&
          widget.userProfile.assignedDistricts.contains(district);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _buildStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading history: ${snapshot.error}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        final allDocs = (snapshot.data?.docs ?? [])
            .cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
        final records = _applyDistrictFilter(allDocs);

        final triggered =
            records.where((r) => r['event'] == 'triggered').toList();
        final stopped =
            records.where((r) => r['event'] == 'stopped').toList();
        final uniqueSenders =
            records.map((r) => r['sender_id'] as String? ?? '').toSet().length;

        // District breakdown
        final districtStats = <String, Map<String, int>>{};
        for (final r in records) {
          final raw = r['district'] as String?;
          final district =
              (raw != null && raw.isNotEmpty) ? raw.toUpperCase() : 'UNKNOWN';
          final event = r['event'] as String? ?? '';
          districtStats.putIfAbsent(
              district, () => {'triggered': 0, 'stopped': 0});
          if (event == 'triggered') {
            districtStats[district]!['triggered'] =
                (districtStats[district]!['triggered'] ?? 0) + 1;
          } else if (event == 'stopped') {
            districtStats[district]!['stopped'] =
                (districtStats[district]!['stopped'] ?? 0) + 1;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageHeader(),
              const SizedBox(height: 32),
              _buildPeriodFilter(),
              const SizedBox(height: 40),
              _buildStatCards(
                records.length,
                triggered.length,
                stopped.length,
                uniqueSenders,
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildDistrictBreakdown(districtStats),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildEventTypeSplit(
                        triggered.length, stopped.length),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildHistoryTable(records),
              const SizedBox(height: 40),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  // ─── Page header ───────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALERT STATISTICS',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SOS History',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            height: 1.2,
          ),
        ),
        if (!widget.userProfile.isSuperAdmin &&
            widget.userProfile.assignedDistricts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Showing data for: ${widget.userProfile.assignedDistricts.map((d) => d.toUpperCase()).join(", ")}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  // ─── Period filter pills ────────────────────────────────────────────────────

  Widget _buildPeriodFilter() {
    return Row(
      children: _Period.values.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                period.label,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Summary stat cards ─────────────────────────────────────────────────────

  Widget _buildStatCards(
      int total, int triggered, int stopped, int uniqueUsers) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'TOTAL EVENTS',
            '$total',
            Icons.history_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'TRIGGERED',
            '$triggered',
            Icons.warning_amber_rounded,
            valueColor: Colors.red.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'RESOLVED',
            '$stopped',
            Icons.check_circle_outline_rounded,
            valueColor: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'UNIQUE USERS',
            '$uniqueUsers',
            Icons.people_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: valueColor ?? Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // ─── District breakdown ─────────────────────────────────────────────────────

  Widget _buildDistrictBreakdown(Map<String, Map<String, int>> districtStats) {
    final sorted = districtStats.entries.toList()
      ..sort((a, b) {
        final aTotal =
            (a.value['triggered'] ?? 0) + (a.value['stopped'] ?? 0);
        final bTotal =
            (b.value['triggered'] ?? 0) + (b.value['stopped'] ?? 0);
        return bTotal.compareTo(aTotal);
      });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'BREAKDOWN BY DISTRICT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                'No data for this period.',
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: Colors.grey.shade50),
                  children: [
                    _thCell('DISTRICT'),
                    _thCell('TRIGGERED'),
                    _thCell('RESOLVED'),
                    _thCell('TOTAL'),
                  ],
                ),
                ...sorted.map((e) {
                  final trig = e.value['triggered'] ?? 0;
                  final stop = e.value['stopped'] ?? 0;
                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    children: [
                      _tdCell(
                        e.key.replaceAll('_', ' / '),
                        bold: true,
                      ),
                      _tdCell(
                        '$trig',
                        color: trig > 0 ? Colors.red.shade700 : null,
                      ),
                      _tdCell(
                        '$stop',
                        color: stop > 0 ? Colors.green.shade700 : null,
                      ),
                      _tdCell('${trig + stop}'),
                    ],
                  );
                }),
              ],
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Event type split ───────────────────────────────────────────────────────

  Widget _buildEventTypeSplit(int triggered, int stopped) {
    final total = triggered + stopped;
    final trigPct =
        total > 0 ? (triggered / total * 100).toStringAsFixed(1) : '0.0';
    final stopPct =
        total > 0 ? (stopped / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVENT TYPE SPLIT',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          if (total == 0)
            Text(
              'No data for this period.',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 14),
            )
          else ...[
            _buildBar(
              'TRIGGERED',
              triggered,
              total,
              Colors.red.shade700,
              trigPct,
            ),
            const SizedBox(height: 24),
            _buildBar(
              'RESOLVED',
              stopped,
              total,
              Colors.green.shade700,
              stopPct,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(
    String label,
    int value,
    int total,
    Color color,
    String pct,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$value  ($pct%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ─── History log table ──────────────────────────────────────────────────────

  Widget _buildHistoryTable(List<Map<String, dynamic>> records) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALERT HISTORY LOG',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${records.length} records',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                'No history records for this period.',
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1120),
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(180),
                    1: FixedColumnWidth(110),
                    2: FixedColumnWidth(160),
                    3: FixedColumnWidth(160),
                    4: FixedColumnWidth(160),
                    5: FixedColumnWidth(150),
                    6: FixedColumnWidth(200),
                  },
                  children: [
                    TableRow(
                      decoration:
                          BoxDecoration(color: Colors.grey.shade50),
                      children: [
                        _thCell('TIMESTAMP'),
                        _thCell('EVENT'),
                        _thCell('DISTRICT'),
                        _thCell('STATE'),
                        _thCell('USER NAME'),
                        _thCell('PHONE'),
                        _thCell('MESSAGE'),
                      ],
                    ),
                    ...records.map((r) => _buildHistoryRow(r)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  TableRow _buildHistoryRow(Map<String, dynamic> r) {
    final timestamp = r['timestamp'] as Timestamp?;
    final event = r['event'] as String? ?? '';
    final district = r['district'] as String? ?? '';
    final state = r['state'] as String? ?? '';
    final userInfo = r['userInfo'] as Map<String, dynamic>?;

    final timeStr = timestamp != null
        ? DateFormat('dd MMM, HH:mm:ss').format(timestamp.toDate())
        : '—';
    final districtStr =
        district.isNotEmpty ? district.toUpperCase().replaceAll('_', ' / ') : '—';
    final stateStr = state.isNotEmpty ? state : '—';
    final userName = userInfo?['name'] as String? ?? '—';
    final phone = userInfo?['mobile_number'] as String? ?? '—';
    final message = userInfo?['message'] as String? ?? '—';

    final isTriggered = event == 'triggered';

    return TableRow(
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      children: [
        _tdCell(timeStr),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTriggered
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              isTriggered ? 'TRIGGERED' : 'RESOLVED',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w700,
                color: isTriggered
                    ? Colors.red.shade700
                    : Colors.green.shade700,
              ),
            ),
          ),
        ),
        _tdCell(districtStr),
        _tdCell(stateStr),
        _tdCell(userName),
        _tdCell(phone),
        _tdCell(message, maxLines: 2),
      ],
    );
  }

  // ─── Shared table cell helpers ──────────────────────────────────────────────

  Widget _thCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tdCell(
    String text, {
    bool bold = false,
    Color? color,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: color ?? Colors.grey.shade800,
        ),
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Row(
      children: [
        Text(
          'SECURE ACCESS',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'PRIVACY ENSURED',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '© 2026 RAPID RESPONSE TEAM',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
