import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final supabase = Supabase.instance.client;

  // 🔑 NO AUTH – SAME ID ALWAYS
  final String userId =
      Supabase.instance.client.auth.currentSession?.user.email ?? "guest";

  final TextEditingController vehicleCtrl = TextEditingController();

  String? selectedService;
  DateTime? selectedDate;

  bool isLoading = false;
  List<Map<String, dynamic>> services = [];

  // ⏱ DURABILITY IN MONTHS (20+ SERVICES)
  final Map<String, int> serviceDurability = {
    "Engine Oil Change": 6,
    "Oil Filter": 6,
    "Air Filter": 12,
    "Fuel Filter": 12,
    "Coolant Replacement": 24,
    "Transmission Oil": 36,
    "Brake Fluid": 24,
    "Brake Pads": 24,
    "Brake Disc": 48,
    "Clutch Plate": 36,
    "Battery": 36,
    "Tyres": 48,
    "Wheel Alignment": 12,
    "Wheel Balancing": 12,
    "Suspension Check": 24,
    "Shock Absorbers": 48,
    "Spark Plugs": 24,
    "AC Service": 12,
    "Chain Lubrication": 6,
    "Chain & Sprocket": 36,
    "General Service": 12,
    "Full Vehicle Inspection": 12,
  };

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // ================= LOAD =================
  Future<void> _loadServices() async {
    setState(() => isLoading = true);

    final res = await supabase
        .from('vehicle_services')
        .select()
        .eq('user_id', userId)
        .order('expiry_date', ascending: true);

    setState(() {
      services = List<Map<String, dynamic>>.from(res);
      isLoading = false;
    });
  }

  // ================= SAVE =================
  Future<void> _saveService() async {
    if (vehicleCtrl.text.trim().isEmpty) {
      _toast("Enter vehicle name");
      return;
    }
    if (selectedService == null) {
      _toast("Select service");
      return;
    }
    if (selectedDate == null) {
      _toast("Select service date");
      return;
    }

    final months = serviceDurability[selectedService!]!;
    final expiry = DateTime(
      selectedDate!.year,
      selectedDate!.month + months,
      selectedDate!.day,
    );

    await supabase.from('vehicle_services').insert({
      'user_id': userId,
      'vehicle_name': vehicleCtrl.text.trim(),
      'service_name': selectedService,
      'service_date': selectedDate!.toIso8601String().substring(0, 10),
      'expiry_date': expiry.toIso8601String().substring(0, 10),
    });

    vehicleCtrl.clear();
    selectedService = null;
    selectedDate = null;

    _toast("Service saved successfully");
    _loadServices();
  }

  // ================= DELETE =================
  Future<void> _deleteService(String id) async {
    await supabase.from('vehicle_services').delete().eq('id', id);
    _toast("Service deleted");
    _loadServices();
  }

  // ================= DAYS LEFT =================
  int _daysLeft(String expiry) {
    return DateTime.parse(expiry)
        .difference(DateTime.now())
        .inDays;
  }

  Color _statusColor(String expiry) {
    final days = _daysLeft(expiry);
    if (days > 30) return Colors.green;
    if (days == 30) return Colors.amber;
    return Colors.red;
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
                      child: const Icon(Icons.build, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Service & Maintenance",
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
                              "Loading service records...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : services.isEmpty
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
                                    child: const Icon(Icons.car_repair, size: 64, color: Color(0xFF126180)),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "No service records",
                                    style: TextStyle(
                                      color: Color(0xFF126180),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Track your vehicle maintenance",
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
                                  children: services.map((s) => _buildServiceCard(s)).toList(),
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF126180), Color(0xFF1E88B8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF126180).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _openEntrySheet,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final days = _daysLeft(service['expiry_date']);
    final statusColor = _statusColor(service['expiry_date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.build_circle, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['vehicle_name'],
                      style: const TextStyle(
                        color: Color(0xFF2D3436),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service['service_name'],
                      style: const TextStyle(
                        color: Color(0xFF636E72),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                onPressed: () => _deleteService(service['id']),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      "Service Date: ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      service['service_date'],
                      style: const TextStyle(
                        color: Color(0xFF2D3436),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      "Expiry Date: ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      service['expiry_date'],
                      style: const TextStyle(
                        color: Color(0xFF2D3436),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      days < 0 ? Icons.error : Icons.access_time,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      days < 0 ? "Expired" : "$days days left",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ENTRY SHEET =================
  void _openEntrySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Service Entry",
              style: TextStyle(
                color: Color(0xFF126180),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: vehicleCtrl,
              style: const TextStyle(color: Color(0xFF2D3436)),
              decoration: InputDecoration(
                labelText: "Vehicle name",
                labelStyle: const TextStyle(color: Color(0xFF126180)),
                filled: true,
                fillColor: const Color(0xFFF5F8FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF126180), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              style: const TextStyle(color: Color(0xFF2D3436)),
              decoration: InputDecoration(
                labelText: "Service",
                labelStyle: const TextStyle(color: Color(0xFF126180)),
                filled: true,
                fillColor: const Color(0xFFF5F8FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF126180), width: 2),
                ),
              ),
              items: serviceDurability.keys
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style:
                            const TextStyle(color: Color(0xFF2D3436)),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => selectedService = v,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF126180),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
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
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Text(
                selectedDate == null
                    ? "Pick Service Date"
                    : selectedDate!
                        .toIso8601String()
                        .substring(0, 10),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF126180),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.pop(context);
                _saveService();
              },
              child: const Text(
                "SAVE",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOAST =================
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          msg,
          style: const TextStyle(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }
}
