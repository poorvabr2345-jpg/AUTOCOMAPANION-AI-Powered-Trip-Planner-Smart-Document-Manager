import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/responsive_helper.dart';

class DocumentStoragePage extends StatefulWidget {
  const DocumentStoragePage({super.key});

  @override
  State<DocumentStoragePage> createState() =>
      _DocumentStoragePageState();
}

class _DocumentStoragePageState
    extends State<DocumentStoragePage> {
  final supabase = Supabase.instance.client;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  String? selectedCategory;
  bool isLoading = false;
  List<Map<String, dynamic>> documents = [];

  final categories = ["insurance", "puc", "rc", "dl", "others"];

  Future<void> _loadDocuments(String category) async {
    if (firebaseUser == null) return;

    setState(() {
      selectedCategory = category;
      isLoading = true;
      documents.clear();
    });

    final data = await supabase
        .from('vehicle_documents')
        .select()
        .eq('user_id', firebaseUser!.uid)
        .ilike('doc_type', category); // ✅ case-safe

    setState(() {
      documents = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  void _openDocument(String url) async {
    if (url.isEmpty) return;

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
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
                      onPressed: selectedCategory != null
                          ? () {
                              setState(() {
                                selectedCategory = null;
                                documents.clear();
                              });
                            }
                          : () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.folder_open, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      selectedCategory?.toUpperCase() ?? "Document Store",
                      style: const TextStyle(
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
                selectedCategory == null
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
                            child: Column(
                              children: [
                                // Hero Section
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
                                        child: const Icon(Icons.cloud_upload, size: 48, color: Colors.white),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Document Storage",
                                        style: TextStyle(
                                          color: Color(0xFF126180),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Organize and access your vehicle documents",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Categories Grid
                                isDesktop
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                          childAspectRatio: 2.5,
                                        ),
                                        itemCount: categories.length,
                                        itemBuilder: (_, i) => _buildCategoryCard(categories[i]),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: categories.length,
                                        itemBuilder: (_, i) => Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _buildCategoryCard(categories[i]),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : isLoading
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
                                  "Loading documents...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : documents.isEmpty
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  margin: const EdgeInsets.all(24),
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
                                      Icon(Icons.folder_off, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No documents found",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
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
                                    constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
                                    child: Column(
                                      children: documents.map((doc) => _buildDocumentCard(doc)).toList(),
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

  Widget _buildCategoryCard(String category) {
    IconData icon;
    Color iconColor;
    
    switch (category.toLowerCase()) {
      case 'insurance':
        icon = Icons.shield;
        iconColor = const Color(0xFF4CAF50);
        break;
      case 'puc':
        icon = Icons.eco;
        iconColor = const Color(0xFF8BC34A);
        break;
      case 'rc':
        icon = Icons.description;
        iconColor = const Color(0xFF2196F3);
        break;
      case 'dl':
        icon = Icons.credit_card;
        iconColor = const Color(0xFFFF9800);
        break;
      default:
        icon = Icons.folder;
        iconColor = const Color(0xFF9E9E9E);
    }

    return InkWell(
      onTap: () => _loadDocuments(category),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
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
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                category.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF2D3436),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF126180).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF126180),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    return InkWell(
      onTap: () => _openDocument(doc['file_url']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.description, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['doc_type'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF2D3436),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Tap to open document",
                    style: TextStyle(
                      color: Color(0xFF636E72),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF126180).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.open_in_new,
                color: Color(0xFF126180),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
