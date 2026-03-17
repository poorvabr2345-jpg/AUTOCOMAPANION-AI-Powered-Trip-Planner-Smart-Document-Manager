import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/document_upload_service.dart';
import '../../services/document_db_service.dart';

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  XFile? _pickedFile;
  String? _fileName;

  bool _loading = false;
  bool _scanCompleted = false;
  bool _saving = false;

  String expiryDate = "";
  String documentType = "";
  String documentNumber = "";
  double confidence = 0;

  /// 🔗 BACKEND URL - Use IP address for mobile, localhost for web
  String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5002";
    }
    return "http://192.168.0.103:5002"; // Your computer's IP
  }

  // ================= DOCUMENT TYPE =================
  String selectedDocType = "insurance";

  final List<Map<String, String>> docTypes = [
    {"label": "Insurance", "value": "insurance"},
    {"label": "RC Book", "value": "rc"},
    {"label": "PUC", "value": "puc"},
    {"label": "Driving Licence", "value": "dl"},
    {"label": "Other", "value": "others"},
  ];

  // =========================================================
  // PICK IMAGE FROM GALLERY
  // =========================================================
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _pickedFile = picked;
      _imageBytes = bytes;
      _fileName = picked.name;

      expiryDate = "";
      documentType = "";
      documentNumber = "";
      confidence = 0;

      _scanCompleted = false;
    });
  }

  // =========================================================
  // PICK IMAGE FROM CAMERA (Mobile only)
  // =========================================================
  Future<void> _pickImageFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _pickedFile = picked;
      _imageBytes = bytes;
      _fileName = picked.name;

      expiryDate = "";
      documentType = "";
      documentNumber = "";
      confidence = 0;

      _scanCompleted = false;
    });
  }

  // =========================================================
  // OCR API CALL
  // =========================================================
  Future<void> _scanDocument() async {
    if (_imageBytes == null) return;

    setState(() => _loading = true);

    try {
      final uri = Uri.parse("$baseUrl/api/document/scan");

      final request = http.MultipartRequest("POST", uri)
        ..fields["doc_type"] = selectedDocType
        ..files.add(
          http.MultipartFile.fromBytes(
            "file",
            _imageBytes!,
            filename: _fileName ?? "document.jpg",
          ),
        );

      final streamed = await request.send();
      final response = await streamed.stream.bytesToString();

      final data = jsonDecode(response);

      if (data["success"] == true) {
        setState(() {
          expiryDate = data["expiry_date"] ?? "Not detected";
          documentType = data["document_type"] ?? selectedDocType;
          documentNumber = data["document_number"] ?? "Not detected";
          confidence = (data["confidence"] ?? 0).toDouble();
          _scanCompleted = true;
        });
      } else {
        _showError("Scan failed");
      }
    } catch (e) {
      _showError("OCR error");
    } finally {
      setState(() => _loading = false);
    }
  }

  // =========================================================
  // SAVE DOCUMENT (AFTER SCAN)
  // =========================================================
  Future<void> _saveDocument() async {
    if (_pickedFile == null) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1️⃣ Upload to Supabase Storage
      final fileUrl = await DocumentUploadService.uploadDocument(
        _pickedFile!,
        "${user.uid}/$documentType",
      );

      if (fileUrl == null) throw Exception("Upload failed");

      // 2️⃣ Save metadata to DB
      await DocumentDBService.saveDocument(
        userId: user.uid,
        docType: documentType,
        fileUrl: fileUrl,
        expiryDate: expiryDate,
      );

      // 3️⃣ Success popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF126180),
          content: Text(
            "✓ Saved to ${documentType.toUpperCase()}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  // =========================================================
  // UI HELPERS
  // =========================================================
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
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
                      child: const Icon(Icons.document_scanner, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Document Scanner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: isWideScreen ? 700 : double.infinity),
                      child: Column(
                        children: [
                          // IMAGE PREVIEW
                          Container(
                            height: 280,
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
                            child: _imageBytes == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF126180).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Select a document to scan",
                                          style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 24),

                          // DOC TYPE
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedDocType,
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                labelText: "Document Type",
                                labelStyle: const TextStyle(color: Color(0xFF126180), fontWeight: FontWeight.w600),
                                border: InputBorder.none,
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF126180).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.description, color: Color(0xFF126180), size: 20),
                                ),
                              ),
                              style: const TextStyle(color: Color(0xFF2D3436), fontSize: 16, fontWeight: FontWeight.w500),
                              items: docTypes
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d["value"],
                                      child: Text(d["label"]!),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() => selectedDocType = val!);
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // PICK BUTTONS - Gallery and Camera
                          Row(
                            children: [
                              // Gallery Button
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.95),
                                      foregroundColor: const Color(0xFF126180),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        side: BorderSide(
                                          color: const Color(0xFF126180).withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.photo_library, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          "Gallery",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Camera Button (Mobile only)
                              Expanded(
                                child: SizedBox(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: _pickImageFromCamera,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF126180),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.camera_alt, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          "Camera",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // SCAN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _scanDocument,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
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
                                  child: _loading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.document_scanner, color: Colors.white, size: 24),
                                            SizedBox(width: 12),
                                            Text(
                                              "Scan Document",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // RESULT + SAVE BUTTON
                          if (_scanCompleted)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
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
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF126180), Color(0xFF1E88B8)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Scan Results",
                                        style: TextStyle(
                                          color: Color(0xFF126180),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _info("Document Type", documentType),
                                  _info("Document Number", documentNumber),
                                  _info("Expiry Date", expiryDate),
                                  _info(
                                    "Confidence",
                                    "${(confidence * 100).toStringAsFixed(1)}%",
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: ElevatedButton(
                                      onPressed: _saving ? null : _saveDocument,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
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
                                          child: _saving
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(Icons.save, color: Colors.white, size: 24),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      "Save Document",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Color(0xFF636E72),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D3436),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


