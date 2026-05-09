import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hn_item.dart';

class HnRepository {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0';

  final http.Client _client;

  HnRepository({http.Client? client}) : _client = client ?? http.Client();

  /// Returns the list of top story IDs (up to 500).
  Future<List<int>> getTopStoryIds() async {
    final response =
        await _client.get(Uri.parse('$_baseUrl/topstories.json'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load top stories: ${response.statusCode}');
    }
    return (jsonDecode(response.body) as List<dynamic>).cast<int>();
  }

  /// Fetches a single item (story or comment) by ID.
  /// Returns null if the item is deleted/dead or not found.
  Future<HnItem?> getItem(int id) async {
    final response =
        await _client.get(Uri.parse('$_baseUrl/item/$id.json'));
    if (response.statusCode != 200) return null;
    final body = response.body;
    if (body == 'null' || body.isEmpty) return null;
    final json = jsonDecode(body) as Map<String, dynamic>;
    final item = HnItem.fromJson(json);
    if (item.deleted || item.dead) return null;
    return item;
  }

  /// Fetches multiple items concurrently.
  Future<List<HnItem>> getItems(List<int> ids) async {
    final results = await Future.wait(ids.map(getItem));
    return results.whereType<HnItem>().toList();
  }
}
