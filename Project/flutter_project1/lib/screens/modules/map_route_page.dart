import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapRoutePage extends StatelessWidget {
  final String start;
  final String destination;

  const MapRoutePage({
    super.key,
    required this.start,
    required this.destination,
  });

  Future<void> _openInBrowser() async {
    final url =
        "https://www.google.com/maps/dir/?api=1&origin=$start&destination=$destination&travelmode=driving";

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ WEB / DESKTOP SAFE HANDLING
    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android)) {
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
                // Modern AppBar with glassmorphism
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.route, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Route Map",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Navigation Ready",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Body with enhanced card design
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Section with Icon
                            Container(
                              padding: const EdgeInsets.all(48),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.navigation,
                                        size: 56,
                                        color: Color(0xFF126180),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Your Route is Ready!",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Navigate with Google Maps",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Route Details Section
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  // Starting Point
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F8FB),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF126180).withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF126180).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.trip_origin,
                                            color: Color(0xFF126180),
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Starting Point",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                start,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xFF126180),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Arrow Indicator
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 3,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF126180).withOpacity(0.3),
                                                const Color(0xFF126180),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E88B8).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_downward,
                                            color: Color(0xFF1E88B8),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 3,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF126180),
                                                const Color(0xFF126180).withOpacity(0.3),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Destination
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF1E88B8).withOpacity(0.1),
                                          const Color(0xFFAFD5F5).withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF1E88B8).withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "DESTINATION",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                destination,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Color(0xFF126180),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Open Maps Button
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF126180).withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: _openInBrowser,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 20,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.open_in_new,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              const Text(
                                                "Open in Google Maps",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Info Text
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAFD5F5).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.grey.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "This will open Google Maps in your browser with turn-by-turn navigation",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ ANDROID ONLY (NO RED SCREEN)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF126180),
        foregroundColor: Colors.white,
        title: const Text("Route Map"),
        elevation: 0,
      ),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(12.9716, 77.5946),
          zoom: 6,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
