import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../modules/document_storage_page.dart';
import '../modules/ai_tour_page.dart';
import '../modules/maps_page.dart';
import '../../utils/responsive_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final displayName =
        Supabase.instance.client.auth.currentUser?.email?.split('@')[0] ?? "Traveler";
    final isMobile = ResponsiveHelper.isMobile(context);
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
                              colors: [Color(0xFF6C5CE7), Color(0xFF5B4ECE)],
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
                        colors: [Color(0xFF6C5CE7), Color(0xFF5B4ECE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.3),
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
                                  backgroundColor: const Color(0xFF6C5CE7),
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
                        colors: [Color(0xFF6C5CE7), Color(0xFF5B4ECE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.4),
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
                                  backgroundColor: const Color(0xFF74B9FF),
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
                      // Left Column
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "My Features",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                                      onPressed: () {},
                                      color: Colors.grey[400],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onPressed: () {},
                                      color: const Color(0xFF6C5CE7),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Feature Cards
                            isMobile 
                                ? Column(
                                    children: [
                                      _buildMobilePortfolioCard(
                                        "AI Trip",
                                        "Travel",
                                        "\$145,25",
                                        "+\$0.4(47%)",
                                        const Color(0xFF0984E3),
                                        Icons.smart_toy,
                                        true,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const AITourPage(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildMobilePortfolioCard(
                                        "Maps",
                                        "Navigation",
                                        "\$320,15",
                                        "+\$0.5(55%)",
                                        const Color(0xFFFDAA3B),
                                        Icons.map,
                                        false,
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const MapsPage(),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildMobilePortfolioCard(
                                        "Scanner",
                                        "Documents",
                                        "\$250,23",
                                        "+\$0.4(47%)",
                                        const Color(0xFF6C5CE7),
                                        Icons.document_scanner,
                                        false,
                                        () {},
                                      ),
                                      const SizedBox(height: 16),
                                      _buildMobilePortfolioCard(
                                        "Storage",
                                        "Files",
                                        "\$180,45",
                                        "+\$0.3(32%)",
                                        const Color(0xFFA29BFE),
                                        Icons.folder_outlined,
                                        false,
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
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildPortfolioCard(
                                          "AI Trip",
                                          "Travel",
                                          "\$145,25",
                                          "+\$0.4(47%)",
                                          const Color(0xFF0984E3),
                                          Icons.smart_toy,
                                          true,
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
                                        _buildPortfolioCard(
                                          "Maps",
                                          "Navigation",
                                          "\$320,15",
                                          "+\$0.5(55%)",
                                          const Color(0xFFFDAA3B),
                                          Icons.map,
                                          false,
                                          () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const MapsPage(),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 16),
                                        _buildPortfolioCard(
                                          "Scanner",
                                          "Documents",
                                          "\$250,23",
                                          "+\$0.4(47%)",
                                          const Color(0xFF6C5CE7),
                                          Icons.document_scanner,
                                          false,
                                          () {},
                                        ),
                                        const SizedBox(width: 16),
                                        _buildPortfolioCard(
                                          "Storage",
                                          "Files",
                                          "\$180,45",
                                          "+\$0.3(32%)",
                                          const Color(0xFFA29BFE),
                                          Icons.folder_outlined,
                                          false,
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
                                  ),
                            const SizedBox(height: 32),
                            
                            // Chart Section
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
                                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.bar_chart_rounded,
                                              color: Color(0xFF6C5CE7),
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF74B9FF),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          "\$300",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Simple Chart
                                  SizedBox(
                                    height: 150,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildChartBar("Mon", 60),
                                        _buildChartBar("Sun", 80),
                                        _buildChartBar("Tue", 100),
                                        _buildChartBar("Wed", 75),
                                        _buildChartBar("Thu", 90),
                                        _buildChartBar("Fri", 65),
                                        _buildChartBar("Sat", 85),
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
                      
                      // Right Column
                      if (isDesktop)
                        SizedBox(
                          width: 320,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "My Cards",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Balance Card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0984E3).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Balance",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "\$450,933",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Monthly profit",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Text(
                                          "\$12,484",
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
                                            "+10%",
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
                                      onPressed: () {},
                                      icon: const Icon(Icons.download, size: 18),
                                      label: const Text("Request"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6C5CE7),
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
                                      onPressed: () {},
                                      icon: const Icon(Icons.upload, size: 18),
                                      label: const Text("Transfer"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF74B9FF),
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
                              
                              // Recent Transactions
                              const Text(
                                "Recent Transaction",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildTransactionItem(
                                "New Trip",
                                "Today",
                                "-Rp.600K",
                                Icons.flight_takeoff,
                                const Color(0xFF0984E3),
                                false,
                              ),
                              _buildTransactionItem(
                                "Service Paid",
                                "Today",
                                "+Rp.500K",
                                Icons.build,
                                const Color(0xFF00B894),
                                true,
                              ),
                              _buildTransactionItem(
                                "Document Upload",
                                "Yesterday",
                                "+Rp.900K",
                                Icons.upload_file,
                                const Color(0xFF6C5CE7),
                                true,
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
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
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

  Widget _buildMobilePortfolioCard(
    String name,
    String subtitle,
    String value,
    String change,
    Color color,
    IconData icon,
    bool isPositive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 13,
                    color: isPositive ? const Color(0xFF00B894) : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard(
    String name,
    String subtitle,
    String value,
    String change,
    Color color,
    IconData icon,
    bool isPositive,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Icon(
                    Icons.more_vert,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
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
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? const Color(0xFF00B894) : const Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double percentage) {
    final height = (percentage / 100) * 150;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF74B9FF).withOpacity(0.8),
                const Color(0xFF0984E3),
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
    );
  }

  Widget _buildTransactionItem(
    String title,
    String time,
    String amount,
    IconData icon,
    Color color,
    bool isPositive,
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
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF00B894) : const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }
}
