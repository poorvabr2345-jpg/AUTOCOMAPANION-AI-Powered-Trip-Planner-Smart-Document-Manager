import 'package:flutter/material.dart';

class SavedTripDetailPage extends StatelessWidget {
  final String title;
  final String itinerary;

  const SavedTripDetailPage({
    super.key,
    required this.title,
    required this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    final sections = itinerary.split(RegExp(r'\n\s*\n'));

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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: sections.map((s) => _buildCard(s)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    IconData icon = Icons.event_note;
    Color iconColor = const Color(0xFF126180);
    Color cardColor = Colors.white;
    
    final t = text.toLowerCase();
    
    if (t.contains("overview") || t.contains("trip overview")) {
      icon = Icons.article;
      iconColor = const Color(0xFF126180);
    } else if (t.contains("day")) {
      icon = Icons.calendar_today;
      iconColor = const Color(0xFF1E88B8);
    } else if (t.contains("morning")) {
      icon = Icons.wb_sunny;
      iconColor = const Color(0xFFFFA726);
    } else if (t.contains("afternoon")) {
      icon = Icons.wb_cloudy;
      iconColor = const Color(0xFF42A5F5);
    } else if (t.contains("evening")) {
      icon = Icons.nights_stay;
      iconColor = const Color(0xFF7E57C2);
    } else if (t.contains("night")) {
      icon = Icons.hotel;
      iconColor = const Color(0xFF5C6BC0);
    } else if (t.contains("safety") || t.contains("tip")) {
      icon = Icons.info;
      iconColor = const Color(0xFF66BB6A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.2),
                  iconColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _getTitle(text),
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _formatText(text),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(String text) {
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines.first.trim();
      if (firstLine.endsWith(':')) {
        return firstLine.replaceAll(':', '');
      }
      return firstLine;
    }
    return 'Details';
  }

  String _formatText(String text) {
    final lines = text.split('\n');
    if (lines.length > 1) {
      // Skip the first line if it's a title
      if (lines.first.endsWith(':')) {
        return lines.skip(1).join('\n').replaceAll('*', '').trim();
      }
    }
    return text.replaceAll('*', '').trim();
  }
}
