import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AITourService {

  // ✅ CORRECT BASE URL HANDLING
  static String get baseUrl {
    if (kIsWeb) {
      // Web browser
      return "http://127.0.0.1:5001";
    }

    if (Platform.isAndroid) {
      // 🔴 REAL ANDROID PHONE → use PC IP
      return "http://192.168.0.103:5001";
      // (10.0.2.2 is ONLY for emulator, not real phone)
    }

    // Fallback
    return "http://192.168.0.103:5001";
  }

  static Future<Map<String, dynamic>> generateTour(
      Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/ai-tour-plan"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode(data),
          )
          // ✅ INCREASE TIMEOUT (VERY IMPORTANT)
          .timeout(const Duration(minutes: 3));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["success"] == true) {
          return {
            "itinerary": decoded["itinerary"],
            "images": decoded["destination_images"] ?? [],
          };
        } else {
          throw Exception(decoded["error"] ?? "AI generation failed");
        }
      } else {
        throw Exception(
          "Request failed (${response.statusCode}): ${response.body}",
        );
      }
    } on SocketException {
      throw Exception(
        "Cannot connect to server at $baseUrl.\n"
        "Make sure:\n"
        "- Backend is running\n"
        "- Phone & PC are on same Wi-Fi\n"
        "- Correct IP is used",
      );
    } on TimeoutException {
      throw Exception(
        "Request timed out. Server is taking too long to respond.",
      );
    } catch (e) {
      rethrow;
    }
  }
}