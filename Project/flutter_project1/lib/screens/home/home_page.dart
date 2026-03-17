import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modules/vehicle_doc_scanner_page.dart';
import '../modules/document_storage_page.dart';
import '../modules/service_page.dart';
import '../modules/notification_page.dart';
import '../modules/ai_tour_page.dart';
import '../modules/maps_page.dart';
import '../../utils/responsive_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.email?.split('@')[0] ?? "Traveler";
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      body: Row(
        children: [
          // Left Sidebar Navigation
          if (isDesktop)
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF126180), Color(0xFFAFD5F5)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.explore,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "AutoCompanion",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Navigation Items
                  _buildNavItem(Icons.dashboard_rounded, "Dashboard", 0, true),
                  _buildNavItem(Icons.swap_horiz_rounded, "Documents", 1, false),
                  _buildNavItem(Icons.account_balance_wallet_outlined, "Storage", 2, false),
                  _buildNavItem(Icons.bar_chart_rounded, "Analytics", 3, false),
                  _buildNavItem(Icons.person_outline_rounded, "Profile", 4, false),
                  _buildNavItem(Icons.settings_outlined, "Settings", 5, false),
                  
                  const Spacer(),
                  
                  // Discover Pro Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF126180), Color(0xFFAFD5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF126180).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Discover Pro",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          
          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
                      if (isDesktop)
                        Row(
                          children: [
                            // Search Bar
                            Container(
                              width: 280,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey[400], size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Search Trips",
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.tune, color: Colors.grey[400], size: 20),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Notification Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: Color(0xFF636E72),
                                      size: 22,
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF6B6B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // User Avatar
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF126180),
                                  child: Text(
                                    displayName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600], size: 20),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Hero Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF126180), Color(0xFFAFD5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF126180).withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Easy to Manage Your",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Travel Plans",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "View your detailed travel information here",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AITourPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFAFD5F5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Plan New Trip",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        if (isDesktop)
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.phone_iphone_rounded,
                                size: 80,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main Content Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Features
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Features",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Feature Cards Row 1
                            Row(
                              children: [
                                _buildFeatureCard(
                                  "AI Trip",
                                  "Planner",
                                  Icons.smart_toy,
                                  const Color(0xFF126180),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AITourPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildFeatureCard(
                                  "Scanner",
                                  "Documents",
                                  Icons.document_scanner,
                                  const Color(0xFF126180),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DocumentScannerPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildFeatureCard(
                                  "Storage",
                                  "Files",
                                  Icons.folder_outlined,
                                  const Color(0xFFAFD5F5),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DocumentStoragePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Feature Cards Row 2
                            Row(
                              children: [
                                _buildFeatureCard(
                                  "Service",
                                  "Monitor",
                                  Icons.build_outlined,
                                  const Color(0xFF00B894),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ServicePage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildFeatureCard(
                                  "Alerts",
                                  "Notification",
                                  Icons.notifications_outlined,
                                  const Color(0xFFFF6B6B),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationPage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildFeatureCard(
                                  "Maps",
                                  "Navigation",
                                  Icons.map_outlined,
                                  const Color(0xFFFDAA3B),
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MapsPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            
                            // Activity Chart
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF126180).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.bar_chart_rounded,
                                              color: Color(0xFF126180),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            "Total Activity",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D3436),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Simple Chart
                                  SizedBox(
                                    height: 180,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildChartBar("Mon", 60),
                                        _buildChartBar("Tue", 80),
                                        _buildChartBar("Wed", 100),
                                        _buildChartBar("Thu", 75),
                                        _buildChartBar("Fri", 90),
                                        _buildChartBar("Sat", 65),
                                        _buildChartBar("Sun", 85),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (isDesktop) const SizedBox(width: 32),
                      
                      // Right Column - Stats
                      if (isDesktop)
                        SizedBox(
                          width: 320,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Quick Stats",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Stats Card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFAFD5F5), Color(0xFF126180)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF126180).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Trips",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "24",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "This Month",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Text(
                                          "8 trips",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            "+15%",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AITourPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text("New Trip"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF126180),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const DocumentStoragePage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.folder, size: 18),
                                      label: const Text("Storage"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFAFD5F5),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              // Recent Activity
                              const Text(
                                "Recent Activity",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildActivityItem(
                                "Trip Planned",
                                "Today",
                                Icons.flight_takeoff,
                                const Color(0xFF126180),
                              ),
                              _buildActivityItem(
                                "Document Scanned",
                                "Yesterday",
                                Icons.document_scanner,
                                const Color(0xFF126180),
                              ),
                              _buildActivityItem(
                                "Service Booked",
                                "2 days ago",
                                Icons.build,
                                const Color(0xFF00B894),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isActive) {
    final isSelected = _selectedIndex == index || isActive;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF126180) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFFB2BEC3),
              size: 20,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFB2BEC3),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double percentage) {
    final height = (percentage / 100) * 120; // Reduced from 150 to 120 to leave room for label
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 35,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFAFD5F5).withOpacity(0.8),
                  const Color(0xFF126180),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
