import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile.dart';
import '../../widgets/sos_alerts_table.dart';

/// SOS Monitor screen with district filtering
class SOSMonitorScreen extends StatelessWidget {
  final UserProfile userProfile;

  const SOSMonitorScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          _buildActiveCountCard(),
          const SizedBox(height: 40),
          SOSAlertsTable(userProfile: userProfile),
          const SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE ALERTS (LAST 1 HOUR)',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Live SOS Monitor',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            height: 1.2,
          ),
        ),
        if (!userProfile.isSuperAdmin &&
            userProfile.assignedDistricts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Showing alerts for: ${userProfile.assignedDistricts.map((d) => d.toUpperCase()).join(", ")}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveCountCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: buildAlertsQuery(userProfile).snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        
        if (snapshot.hasData) {
          // Filter to only count alerts less than 1 hour old
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            
            if (timestamp == null) return false;
            
            final alertTime = timestamp.toDate();
            final difference = DateTime.now().difference(alertTime);
            
            return difference.inHours < 1;
          });
          
          count = filteredDocs.length;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL ACTIVE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        ),
      ],
    );
  }

  /// Build the Firestore query for SOS alerts based on user profile
  static Query<Map<String, dynamic>> buildAlertsQuery(UserProfile userProfile) {
    var query = FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('active', isEqualTo: true);

    // Filter by districts for regular admins
    if (!userProfile.isSuperAdmin && userProfile.assignedDistricts.isNotEmpty) {
      query = query.where('district', whereIn: userProfile.assignedDistricts);
    }

    return query;
  }
}
