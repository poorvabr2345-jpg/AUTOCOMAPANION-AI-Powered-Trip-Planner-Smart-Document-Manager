// lib/screens/modules/maps_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'offline_map_viewer.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF126180),
              const Color(0xFF1E88B8),
              const Color(0xFFAFD5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.map, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                        "Maps",
                        style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: FutureBuilder(
                  future: Supabase.instance.client
                      .from('saved_maps')
                      .select()
                      .order('created_at', ascending: false),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF126180),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Loading maps...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final maps = snapshot.data as List;

                    if (maps.isEmpty) {
                      return Center(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: isWideScreen ? 600 : double.infinity),
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF126180),
                                      Color(0xFF1E88B8)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.map_outlined,
                                    size: 64, color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Offline Maps",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF126180),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No maps saved yet. Open a map from AI Tour to download it for offline access.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Display saved maps in a grid
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWideScreen ? 2 : 1,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: isWideScreen ? 1.5 : 0.85,
                        ),
                        itemCount: maps.length,
                        itemBuilder: (context, index) {
                          final map = maps[index];
                          return _buildMapCard(context, map);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapCard(BuildContext context, Map<String, dynamic> map) {
    final mapName = map['map_name'] ?? 'Unnamed Map';
    final createdAt = map['created_at'] != null
        ? DateTime.parse(map['created_at'])
        : DateTime.now();
    
    // Extract data from places jsonb field (stores all trip details)
    final places = map['places'] as Map<String, dynamic>?;
    final startLocation = places?['start_location'] ?? '';
    final destination = places?['destination'] ?? '';
    final tripDuration = places?['trip_duration_days'] ?? 0;
    final travelers = places?['travelers'] ?? 1;
    final budget = places?['budget'] ?? '';
    final interests = places?['interests'] as List?;
    final mapImagePath = places?['map_image_path'] as String?;
    final isOfflineAvailable = map['is_downloaded'] == true && mapImagePath != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Open the offline map viewer
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfflineMapViewer(
                  start: startLocation,
                  destination: destination,
                  mapImagePath: mapImagePath,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon and Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isOfflineAvailable ? Icons.offline_pin : Icons.map,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOfflineAvailable 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOfflineAvailable ? Colors.green : Colors.orange, 
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOfflineAvailable ? Icons.download_done : Icons.cloud_queue,
                            color: isOfflineAvailable ? Colors.green : Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOfflineAvailable ? 'Offline' : 'Online',
                            style: TextStyle(
                              color: isOfflineAvailable ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Map Name
                Text(
                  mapName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF126180),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Route Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trip_origin,
                              color: Color(0xFF126180), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              startLocation,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              destination,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Trip Details
                if (tripDuration > 0 || budget.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFAFD5F5).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF126180).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (tripDuration > 0)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFF126180), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                '$tripDuration ${tripDuration == 1 ? "Day" : "Days"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF126180),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.people,
                                  color: Color(0xFF126180), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                '$travelers ${travelers == 1 ? "Traveler" : "Travelers"}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF126180),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (budget.isNotEmpty && tripDuration > 0)
                        const SizedBox(height: 8),
                        if (budget.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  color: Color(0xFF126180), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                '₹$budget',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF126180),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                // Interests
                if (interests != null && interests.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1E88B8).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          interest.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF126180),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const Spacer(),
                const SizedBox(height: 16),

                // Footer with Date and Action Button
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OfflineMapViewer(
                              start: startLocation,
                              destination: destination,
                              mapImagePath: mapImagePath,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        isOfflineAvailable ? Icons.visibility : Icons.explore,
                        size: 16,
                      ),
                      label: Text(isOfflineAvailable ? 'View Map' : 'Open Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF126180),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
