import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> alerts = [];

  final DateFormat _readableFormat = DateFormat("d'th of' MMMM yyyy");

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ================= SAFE DATE PARSER =================
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      try {
        return _readableFormat
            .parse(value.toString().replaceAll("  ", " "));
      } catch (_) {
        debugPrint("⚠️ Invalid date skipped: $value");
        return null;
      }
    }
  }

  // ================= LOAD NOTIFICATIONS =================
  Future<void> _loadNotifications() async {
    try {
      final results = await Future.wait([
        supabase.from('vehicle_services').select(),
        supabase.from('vehicle_documents').select(),
      ]);

      final services = results[0] as List;
      final documents = results[1] as List;

      final now = DateTime.now();
      final List<Map<String, dynamic>> generated = [];

      // -------- SERVICES --------
      for (final s in services) {
        final expiry = _parseDate(s['expiry_date']);
        if (expiry == null) continue;

        final days = expiry.difference(now).inDays;

        if (days < 0 || days <= 30) {
          generated.add({
            "id": "service_${s['id']}",
            "title": days < 0
                ? "Service Expired"
                : "Service Expiring Soon",
            "message":
                "${s['vehicle_name']} • ${s['service_name']} ${days < 0 ? 'expired' : 'expires in $days days'}",
            "color": days < 0
                ? Colors.red
                : days == 30
                    ? Colors.amber
                    : Colors.redAccent,
          });
        }
      }

      // -------- DOCUMENTS --------
      for (final d in documents) {
        final expiry = _parseDate(d['expiry_date']);
        if (expiry == null) continue;

        final days = expiry.difference(now).inDays;
        final type = (d['doc_type'] ?? "Document").toString().toUpperCase();

        if (days < 0 || days <= 30) {
          generated.add({
            "id": "doc_${d['id']}",
            "title":
                days < 0 ? "$type Expired" : "$type Expiring Soon",
            "message": days < 0
                ? "$type document has expired"
                : "$type expires in $days days",
            "color": days < 0
                ? Colors.red
                : days == 30
                    ? Colors.amber
                    : Colors.redAccent,
          });
        }
      }

      setState(() {
        alerts = generated;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Notification error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
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
                      child: const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Notifications",
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
                child:
                isLoading
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
                              "Loading notifications...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : alerts.isEmpty
                        ? Center(
                            child: Container(
                              constraints: BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
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
                                      color: const Color(0xFF126180).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "No notifications",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "You're all caught up!",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: isWideScreen ? 900 : double.infinity),
                                child: Column(
                                  children: alerts.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final n = entry.value;
                                    return _buildNotificationCard(i, n);
                                  }).toList(),
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

  Widget _buildNotificationCard(int index, Map<String, dynamic> notification) {
    return Dismissible(
      key: ValueKey(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
      ),
      onDismissed: (_) {
        setState(() {
          alerts.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF126180),
            content: const Text(
              "✓ Notification dismissed",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification['color'].withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notification['color'].withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_active,
                color: notification['color'],
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: TextStyle(
                      color: notification['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['message'],
                    style: const TextStyle(
                      color: Color(0xFF636E72),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: notification['color'].withOpacity(0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
