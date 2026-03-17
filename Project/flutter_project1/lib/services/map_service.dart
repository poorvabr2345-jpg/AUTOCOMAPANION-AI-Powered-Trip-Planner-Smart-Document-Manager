import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapService {
  // Supabase client
  static final SupabaseClient supabase = Supabase.instance.client;

  /// ------------------------------------------------------------
  /// Save map automatically when AI Tour opens the map
  /// (Prevents duplicate saves for the same trip)
  /// ------------------------------------------------------------
  static Future<void> saveMapIfNotExists({
    required String tripId,
    required String mapName,
    required String startLocation,
    required String destination,
    Map<String, dynamic>? travelDates,
  }) async {
    try {
      // Check if map already exists for this trip
      final existing = await supabase
          .from('saved_maps')
          .select('id')
          .eq('trip_id', tripId)
          .maybeSingle();

      // If already saved, do nothing
      if (existing != null) return;

      // Insert new offline-ready map
      await supabase.from('saved_maps').insert({
        'user_id': supabase.auth.currentUser?.id ?? 'guest',
        'trip_id': tripId,
        'map_name': mapName,
        'start_location': startLocation,
        'destination': destination,
        'travel_dates': travelDates,
        'is_downloaded': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // You can log this if needed
      rethrow;
    }
  }

  /// ------------------------------------------------------------
  /// Fetch all saved maps for Maps Module (Offline View)
  /// ------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> fetchSavedMaps() async {
    final response = await supabase
        .from('saved_maps')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// ------------------------------------------------------------
  /// Open Microsoft Maps (Online Navigation)
  /// ------------------------------------------------------------
  static Future<void> openMicrosoftMaps(
    double lat,
    double lng,
  ) async {
    final Uri url = Uri.parse(
      'https://www.bing.com/maps?cp=$lat~$lng&lvl=15',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch Microsoft Maps';
    }
  }
}
