import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_profile.dart';
import './sos_monitor_screen.dart';

/// Map view of SOS alerts for super admins
class SOSMapScreen extends StatefulWidget {
  final UserProfile userProfile;

  const SOSMapScreen({super.key, required this.userProfile});

  @override
  State<SOSMapScreen> createState() => _SOSMapScreenState();
}

class _SOSMapScreenState extends State<SOSMapScreen> {
  String? selectedState;
  String? selectedDistrict;
  final MapController _mapController = MapController();
  Map<String, dynamic>? selectedAlert;

  // Center of India for initial map view
  static const LatLng indiaCenter = LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildActiveCountCard(),
                const SizedBox(height: 40),
                // Only show filters for super admins who can see all districts
                if (widget.userProfile.isSuperAdmin) ...[
                  _buildFilters(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
          _buildMap(),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(40),
            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE ALERTS MAP (LAST 1 HOUR)',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Live SOS Map',
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
            'Showing alerts for: ${widget.userProfile.assignedDistricts.map((d) => d.toUpperCase()).join(", ")}',
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
      stream: SOSMonitorScreen.buildAlertsQuery(widget.userProfile).snapshots(),
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

  Widget _buildFilters() {
    return StreamBuilder<QuerySnapshot>(
      stream: SOSMonitorScreen.buildAlertsQuery(widget.userProfile)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final allAlerts = snapshot.data?.docs ?? [];

        // Filter alerts to only show those less than 1 hour old
        final alerts = allAlerts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['timestamp'] as Timestamp?;

          if (timestamp == null) return false;

          final alertTime = timestamp.toDate();
          final difference = DateTime.now().difference(alertTime);

          return difference.inHours < 1;
        }).toList();

        // Extract unique states and districts from the alerts
        final states = <String>{};
        final districts = <String>{};

        for (var doc in alerts) {
          final data = doc.data() as Map<String, dynamic>;
          final district = data['district'] as String?;
          final state = data['state'] as String?;

          if (state != null && state.isNotEmpty) {
            states.add(state);
          }
          if (district != null && district.isNotEmpty) {
            districts.add(district);
          }
        }

        final sortedStates = states.toList()..sort();
        final sortedDistricts = districts.toList()..sort();

        return Row(
          children: [
            // State Filter
            Expanded(
              child: _buildFilterDropdown(
                label: 'FILTER BY STATE',
                value: selectedState,
                items: sortedStates,
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                    // Reset district filter when state changes
                    if (value != null) {
                      selectedDistrict = null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            // District Filter
            Expanded(
              child: _buildFilterDropdown(
                label: 'FILTER BY DISTRICT',
                value: selectedDistrict,
                items: sortedDistricts,
                onChanged: (value) {
                  setState(() {
                    selectedDistrict = value;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(
                  'All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  ...items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item.toUpperCase().replaceAll('_', ' / '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return StreamBuilder<QuerySnapshot>(
      stream: SOSMonitorScreen.buildAlertsQuery(widget.userProfile)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text('Error loading map: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final allAlerts = snapshot.data?.docs ?? [];

        // Filter alerts to only show those less than 1 hour old
        var alerts = allAlerts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['timestamp'] as Timestamp?;

          if (timestamp == null) return false;

          final alertTime = timestamp.toDate();
          final difference = DateTime.now().difference(alertTime);

          return difference.inHours < 1;
        }).toList();

        // Apply client-side filtering by state
        if (selectedState != null && selectedState!.isNotEmpty) {
          alerts = alerts.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final state = data['state'] as String?;
            return state == selectedState;
          }).toList();
        }

        // Apply client-side filtering by district
        if (selectedDistrict != null && selectedDistrict!.isNotEmpty) {
          alerts = alerts.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final district = data['district'] as String?;
            return district == selectedDistrict;
          }).toList();
        }

        // Build markers from alerts
        final markers = _buildMarkers(alerts);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            height: 600,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: indiaCenter,
                      initialZoom: 5.0,
                      minZoom: 4.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.rrt.admin_site',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  if (selectedAlert != null) _buildAlertInfoCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers(List<QueryDocumentSnapshot> alerts) {
    return alerts.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] as Map<String, dynamic>?;
      final latitude = location?['latitude'] as double?;
      final longitude = location?['longitude'] as double?;

      if (latitude == null || longitude == null) {
        return null;
      }

      return Marker(
        point: LatLng(latitude, longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedAlert = data;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.warning,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  Widget _buildAlertInfoCard() {
    if (selectedAlert == null) return const SizedBox.shrink();

    final userInfo = selectedAlert!['userInfo'] as Map<String, dynamic>?;
    final location = selectedAlert!['location'] as Map<String, dynamic>?;
    final timestamp = selectedAlert!['timestamp'] as Timestamp?;
    final district = selectedAlert!['district'] as String?;

    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALERT DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      selectedAlert = null;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userInfo?['name']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatDistrict(district),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatTimeElapsed(timestamp),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
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
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      ),
    );
  }

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
}
