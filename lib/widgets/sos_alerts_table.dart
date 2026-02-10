import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';
import '../screens/monitor/sos_monitor_screen.dart';

/// Widget displaying the SOS alerts table
class SOSAlertsTable extends StatelessWidget {
  final UserProfile userProfile;

  const SOSAlertsTable({super.key, required this.userProfile});

  String _formatTimeElapsed(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';

    final now = DateTime.now();
    final alertTime = timestamp.toDate();
    final difference = now.difference(alertTime);

    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}S AGO';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}M ${difference.inSeconds % 60}S AGO';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}H ${difference.inMinutes % 60}M AGO';
    } else {
      return '${difference.inDays}D ${difference.inHours % 24}H AGO';
    }
  }

  String _formatDistrict(String? district) {
    if (district == null || district.isEmpty) return 'UNKNOWN';
    return district.toUpperCase().replaceAll('_', ' / ');
  }

  Future<void> _openInMaps(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) return;

    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: SOSMonitorScreen.buildAlertsQuery(userProfile)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final alerts = snapshot.data?.docs ?? [];

        if (alerts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildTable(alerts);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No active alerts',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All clear at the moment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<QueryDocumentSnapshot> alerts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableRows(alerts),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'NAME',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'DISTRICT',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'TIME ELAPSED',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'MAPS',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRows(List<QueryDocumentSnapshot> alerts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index].data() as Map<String, dynamic>;
        final userInfo = alert['userInfo'] as Map<String, dynamic>?;
        final location = alert['location'] as Map<String, dynamic>?;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: index < alerts.length - 1
                    ? Colors.grey.shade200
                    : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      userInfo?['name']?.toString().toUpperCase() ?? 'UNKNOWN',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  _formatDistrict(alert['district']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  _formatTimeElapsed(alert['timestamp'] as Timestamp?),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => _openInMaps(
                      location?['latitude'] as double?,
                      location?['longitude'] as double?,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'OPEN IN MAPS',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
