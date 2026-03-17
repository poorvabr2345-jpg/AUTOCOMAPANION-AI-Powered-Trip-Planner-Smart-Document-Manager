import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'offline_map_page.dart';

class MapsPage extends StatelessWidget {
  MapsPage({super.key});
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Maps")),
      body: FutureBuilder(
        future: supabase.from('saved_maps').select(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final maps = snapshot.data as List;

          return ListView.builder(
            itemCount: maps.length,
            itemBuilder: (_, i) {
              final map = maps[i];
              return ListTile(
                title: Text(map['map_name']),
                trailing: const Icon(Icons.map),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfflineMapPage(
                        startLat: map['start_lat'],
                        startLng: map['start_lng'],
                        waypoints: List<Map<String, dynamic>>.from(map['waypoints']),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
