import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../services/ai_tour_service.dart';
import 'map_route_page.dart';
import 'saved_trips_page.dart';

class AITourPage extends StatefulWidget {
  const AITourPage({super.key});

  @override
  State<AITourPage> createState() => _AITourPageState();
}

class _AITourPageState extends State<AITourPage> {
  final startCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  final budgetCtrl = TextEditingController(text: "25000");

  DateTime? startDate;
  DateTime? endDate;

  bool loading = false;
  String result = "";
  List<String> destinationImages = [];
  int travelers = 1;

  final prefs = [
    "Beach",
    "Mountains",
    "Nature",
    "Adventure",
    "Food",
    "Shopping",
    "Photography",
    "Temples"
  ];
  final selectedPrefs = [];

  Future<void> _pickDate(bool start) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF126180),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D3436),
              secondary: Color(0xFF1E88B8),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF126180),
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      setState(() {
        start ? startDate = d : endDate = d;
      });
    }
  }

  Future<void> generateTrip() async {
    // Validate inputs
    if (startCtrl.text.trim().isEmpty || destCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both start location and destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    final data = {
      "start_location": startCtrl.text,
      "destination": destCtrl.text,
      "start_date":
          startDate != null ? DateFormat("yyyy-MM-dd").format(startDate!) : "",
      "end_date":
          endDate != null ? DateFormat("yyyy-MM-dd").format(endDate!) : "",
      "days": (startDate != null && endDate != null)
          ? endDate!.difference(startDate!).inDays + 1
          : 3,
      "travelers": travelers,
      "budget": "₹${budgetCtrl.text}",
      "interests": selectedPrefs,
    };

    try {
      final response = await AITourService.generateTour(data);
      if (!mounted) return;
      setState(() {
        result = response['itinerary'];
        destinationImages = List<String>.from(response['images'] ?? []);
      });
      print('✅ Images received: ${destinationImages.length}');
      print('Images: $destinationImages');
      await saveTrip();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating trip: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      print('AI Tour Error: $e'); // Debug log
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  // ✅ NO AUTH – DB ONLY
  Future<void> saveTrip() async {
    await Supabase.instance.client.from('ai_trips').insert({
      'start_location': startCtrl.text,
      'destination': destCtrl.text,
      'itinerary': result,
      'created_at': DateTime.now().toIso8601String(),
    });
  }



  void shareTrip() {
    Share.share(result.replaceAll('*', ''));
  }

  // Helper: Geocode location name to coordinates using Nominatim (OpenStreetMap)
  Future<Map<String, double>?> _geocodeLocation(String location) async {
    try {
      final encodedLocation = Uri.encodeComponent(location);
      final url = 'https://nominatim.openstreetmap.org/search?'
          'q=$encodedLocation&'
          'format=json&'
          'limit=1';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterAutoCompanion/1.0'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final result = data[0];
          return {
            'lat': double.parse(result['lat']),
            'lon': double.parse(result['lon']),
          };
        }
      }
    } catch (e) {
      print('Geocoding error for $location: $e');
    }
    return null;
  }

  // Helper: Calculate appropriate zoom level based on distance
  int _calculateZoom(Map<String, double> start, Map<String, double> end) {
    final latDiff = (start['lat']! - end['lat']!).abs();
    final lonDiff = (start['lon']! - end['lon']!).abs();
    final maxDiff = latDiff > lonDiff ? latDiff : lonDiff;
    
    if (maxDiff < 0.05) return 13;      // ~5km
    if (maxDiff < 0.1) return 12;       // ~10km
    if (maxDiff < 0.5) return 10;       // ~50km
    if (maxDiff < 1.0) return 9;        // ~100km
    if (maxDiff < 3.0) return 8;        // ~300km
    if (maxDiff < 5.0) return 7;        // ~500km
    if (maxDiff < 10.0) return 6;       // ~1000km
    return 5;                            // >1000km
  }

  Future<void> openMap() async {
    // Auto-save map with offline capability
    try {
      const uuid = Uuid();
      final tripId = uuid.v4();
      final mapName = '${startCtrl.text} → ${destCtrl.text}';
      
      // Calculate trip duration
      final days = (startDate != null && endDate != null)
          ? endDate!.difference(startDate!).inDays + 1
          : 3;
      
      // Download static map image for offline viewing using OpenStreetMap
      String? mapImagePath;
      try {
        // Get coordinates from location names using Nominatim (OSM geocoding)
        final startCoords = await _geocodeLocation(startCtrl.text);
        final destCoords = await _geocodeLocation(destCtrl.text);
        
        if (startCoords != null && destCoords != null) {
          // Calculate center and zoom level
          final centerLat = (startCoords['lat']! + destCoords['lat']!) / 2;
          final centerLon = (startCoords['lon']! + destCoords['lon']!) / 2;
          final zoom = _calculateZoom(startCoords, destCoords);
          
          // OpenStreetMap Static Map API URL (using staticmap service)
          final mapUrl = 'https://staticmap.openstreetmap.de/staticmap.php?'
              'center=$centerLat,$centerLon&'
              'zoom=$zoom&'
              'size=800x600&'
              'markers=$centerLat,$centerLon,lightblue&'
              'markers=${startCoords['lat']},${startCoords['lon']},green&'
              'markers=${destCoords['lat']},${destCoords['lon']},red';
          
          if (!kIsWeb) {
            final response = await http.get(Uri.parse(mapUrl));
            if (response.statusCode == 200) {
              final directory = await getApplicationDocumentsDirectory();
              final filePath = '${directory.path}/maps/$tripId.png';
              final file = File(filePath);
              await file.create(recursive: true);
              await file.writeAsBytes(response.bodyBytes);
              mapImagePath = filePath;
            }
          }
        }
      } catch (e) {
        print('Map image download failed: $e');
      }
      
      // Store trip details in places jsonb column
      final tripDetails = {
        'trip_duration_days': days,
        'travelers': travelers,
        'budget': budgetCtrl.text,
        'interests': selectedPrefs,
        'start_location': startCtrl.text,
        'destination': destCtrl.text,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'itinerary_preview': result.isNotEmpty ? result.substring(0, result.length > 200 ? 200 : result.length) : '',
        'map_image_path': mapImagePath,
      };
      
      // Save to Supabase
      await Supabase.instance.client.from('saved_maps').insert({
        'id': tripId,
        'map_name': mapName,
        'places': tripDetails,
        'is_downloaded': mapImagePath != null,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (!mounted) return;
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Map saved for offline access! View in Maps Module'),
          backgroundColor: Color(0xFF126180),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Continue to open map even if save fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save map: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      print('Map save error: $e'); // Debug log
    }
    
    // Open map page
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapRoutePage(
          start: startCtrl.text,
          destination: destCtrl.text,
        ),
      ),
    );
  }

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
                      child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Trip Planner",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.history, color: Colors.white, size: 24),
                        tooltip: 'View Saved Trips',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SavedTripsPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: loading
                    ? Center(
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
                              "Generating your perfect trip...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : result.isEmpty
                        ? _form(isWideScreen)
                        : _result(isWideScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(bool isWideScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: BoxConstraints(maxWidth: isWideScreen ? 900 : double.infinity),
          child: Column(
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(bottom: 32),
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
                  children: [
                    Icon(
                      Icons.explore,
                      size: 64,
                      color: const Color(0xFF126180).withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Plan Your Dream Trip",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF126180),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "AI-powered itinerary generator for unforgettable journeys",
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

              // Form Card
              Container(
                padding: const EdgeInsets.all(32),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("📍 Location Details"),
                    const SizedBox(height: 16),
                    _field("Start Location", Icons.my_location, startCtrl),
                    _field("Destination", Icons.location_on, destCtrl),

                    const SizedBox(height: 24),
                    _sectionHeader("📅 Travel Dates"),
                    const SizedBox(height: 16),
                    isWideScreen
                        ? Row(
                            children: [
                              Expanded(child: _dateBtn("Start Date", Icons.calendar_today, () => _pickDate(true), startDate)),
                              const SizedBox(width: 16),
                              Expanded(child: _dateBtn("End Date", Icons.event, () => _pickDate(false), endDate)),
                            ],
                          )
                        : Column(
                            children: [
                              _dateBtn("Start Date", Icons.calendar_today, () => _pickDate(true), startDate),
                              const SizedBox(height: 12),
                              _dateBtn("End Date", Icons.event, () => _pickDate(false), endDate),
                            ],
                          ),

                    const SizedBox(height: 24),
                    _sectionHeader("👥 Travelers & Budget"),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Number of Travelers",
                                style: TextStyle(
                                  color: Color(0xFF126180),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF126180),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$travelers",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF126180),
                              inactiveTrackColor: Colors.grey.shade300,
                              thumbColor: const Color(0xFF126180),
                              overlayColor: const Color(0xFF126180).withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                            ),
                            child: Slider(
                              value: travelers.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              onChanged: (v) => setState(() => travelers = v.toInt()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _field("Budget (₹)", Icons.currency_rupee, budgetCtrl, keyboard: TextInputType.number),

                    const SizedBox(height: 24),
                    _sectionHeader("🎯 Travel Preferences"),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: prefs.map((p) {
                        final s = selectedPrefs.contains(p);
                        return InkWell(
                          onTap: () => setState(() => s ? selectedPrefs.remove(p) : selectedPrefs.add(p)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: s
                                  ? const LinearGradient(
                                      colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                                    )
                                  : null,
                              color: s ? null : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: s ? Colors.transparent : const Color(0xFF126180).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: s
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF126180).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                color: s ? Colors.white : const Color(0xFF126180),
                                fontWeight: s ? FontWeight.bold : FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: generateTrip,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF126180).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  "Generate AI Trip",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _result(bool isWideScreen) {
    final sections = result.split(RegExp(r'\n\s*\n'));

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: BoxConstraints(maxWidth: isWideScreen ? 1000 : double.infinity),
          child: Column(
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(bottom: 24),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.stars, size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Your AI-Generated Itinerary",
                      style: TextStyle(
                        color: Color(0xFF126180),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Personalized travel plan created just for you",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Row
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: isWideScreen
                    ? Row(
                        children: [
                          Expanded(child: _actionBtn(Icons.map, "View Map", openMap, true)),
                          const SizedBox(width: 16),
                          Expanded(child: _actionBtn(Icons.share, "Share", shareTrip, true)),
                          const SizedBox(width: 16),
                          Expanded(child: _actionBtn(Icons.refresh, "Plan New Trip", () => setState(() => result = ""), true)),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _actionBtn(Icons.map, "View Map", openMap, true)),
                              const SizedBox(width: 12),
                              Expanded(child: _actionBtn(Icons.share, "Share", shareTrip, true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _actionBtn(Icons.refresh, "Plan New Trip", () => setState(() => result = ""), true)),
                            ],
                          ),
                        ],
                      ),
              ),

              // Itinerary Cards
              Container(
                padding: const EdgeInsets.all(32),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF126180).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event_note, color: Color(0xFF126180), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Day-by-Day Plan",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF126180),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...sections.map(_dayCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayCard(String text) {
    IconData icon = Icons.event_note;
    Color iconBg = const Color(0xFFAFD5F5);
    Color accentColor = const Color(0xFF126180);
    final t = text.toLowerCase();
    
    // Parse day number if present
    String? dayTitle;
    int? dayNumber;
    final dayMatch = RegExp(r'day\s+(\d+)', caseSensitive: false).firstMatch(text);
    if (dayMatch != null) {
      dayNumber = int.tryParse(dayMatch.group(1) ?? '');
      dayTitle = 'Day ${dayMatch.group(1)}';
      print('📅 Day card: $dayTitle, imageCount: ${destinationImages.length}, dayNum: $dayNumber');
    }
    
    if (t.contains("morning")) {
      icon = Icons.wb_sunny;
      iconBg = const Color(0xFFFFE082);
      accentColor = const Color(0xFFF57C00);
    }
    if (t.contains("afternoon")) {
      icon = Icons.wb_cloudy;
      iconBg = const Color(0xFF90CAF9);
      accentColor = const Color(0xFF1976D2);
    }
    if (t.contains("evening")) {
      icon = Icons.nights_stay;
      iconBg = const Color(0xFF9FA8DA);
      accentColor = const Color(0xFF5C6BC0);
    }
    if (t.contains("night")) {
      icon = Icons.hotel;
      iconBg = const Color(0xFF7986CB);
      accentColor = const Color(0xFF303F9F);
    }
    if (t.contains("day") && !t.contains("morning") && !t.contains("afternoon")) {
      icon = Icons.calendar_today;
      iconBg = const Color(0xFF80CBC4);
      accentColor = const Color(0xFF00897B);
    }

    // Extract location names and activities
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final hasMultipleLines = lines.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            iconBg.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with day title and icon
          if (dayTitle != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // Image for all day cards
          if (dayTitle != null)
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
              ),
              child: destinationImages.isNotEmpty && dayNumber != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            destinationImages[(dayNumber - 1) % destinationImages.length],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: iconBg.withOpacity(0.2),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: accentColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      iconBg.withOpacity(0.3),
                                      iconBg.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: accentColor.withOpacity(0.3),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.photo_camera, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Destination Photo',
                                    style: TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            iconBg.withOpacity(0.3),
                            iconBg.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 60,
                            color: accentColor.withOpacity(0.3),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.photo_camera, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Destination Image',
                                    style: TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasMultipleLines)
                        ...lines.map((line) {
                          final cleanLine = line.replaceAll('*', '').trim();
                          final isBullet = cleanLine.startsWith('-') || cleanLine.startsWith('•');
                          final isTitle = cleanLine.contains(':') && cleanLine.indexOf(':') < 30;
                          
                          if (isTitle) {
                            final parts = cleanLine.split(':');
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          parts[0].trim(),
                                          style: TextStyle(
                                            color: accentColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (parts.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6, left: 12),
                                      child: Text(
                                        parts.sublist(1).join(':').trim(),
                                        style: const TextStyle(
                                          color: Color(0xFF2D3436),
                                          fontSize: 14,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          } else if (isBullet) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      cleanLine.replaceFirst(RegExp(r'^[-•]\s*'), ''),
                                      style: const TextStyle(
                                        color: Color(0xFF2D3436),
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              cleanLine,
                              style: const TextStyle(
                                color: Color(0xFF2D3436),
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          );
                        })
                      else
                        Text(
                          text.replaceAll('*', ''),
                          style: const TextStyle(
                            color: Color(0xFF2D3436),
                            fontSize: 15,
                            height: 1.8,
                            letterSpacing: 0.2,
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
    );
  }

  Widget _actionBtn(IconData i, String t, VoidCallback f, bool isFullWidth) {
    return SizedBox(
      height: isFullWidth ? 56 : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF126180),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: const Color(0xFF126180).withOpacity(0.2),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onPressed: f,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(i, size: 22),
            const SizedBox(width: 10),
            Text(
              t,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String l, IconData i, TextEditingController c,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        style: const TextStyle(
          color: Color(0xFF2D3436),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF126180).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(i, color: const Color(0xFF126180), size: 20),
          ),
          labelText: l,
          labelStyle: TextStyle(
            color: const Color(0xFF126180).withOpacity(0.7),
            fontSize: 15,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF126180).withOpacity(0.15),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF126180),
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateBtn(String t, IconData i, VoidCallback f, DateTime? selectedDate) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      margin: const EdgeInsets.only(bottom: 0),
      child: OutlinedButton(
        onPressed: f,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF126180),
          side: BorderSide(
            color: const Color(0xFF126180).withOpacity(0.3),
            width: 2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF126180).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(i, color: const Color(0xFF126180), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t,
                    style: TextStyle(
                      color: const Color(0xFF126180).withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(selectedDate)
                        : 'Select date',
                    style: const TextStyle(
                      color: Color(0xFF126180),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF126180), Color(0xFF1E88B8)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF126180),
          ),
        ),
      ],
    );
  }
}
