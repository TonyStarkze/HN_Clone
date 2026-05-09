class HnItem {
  final int id;
  final String? type;
  final String? title;
  final String? url;
  final String? text; // HTML string for comments/posts
  final String? by;
  final int score;
  final int descendants;
  final List<int> kids;
  final int time;
  final bool deleted;
  final bool dead;

  const HnItem({
    required this.id,
    this.type,
    this.title,
    this.url,
    this.text,
    this.by,
    this.score = 0,
    this.descendants = 0,
    this.kids = const [],
    this.time = 0,
    this.deleted = false,
    this.dead = false,
  });

  factory HnItem.fromJson(Map<String, dynamic> json) {
    return HnItem(
      id: json['id'] as int,
      type: json['type'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      text: json['text'] as String?,
      by: json['by'] as String?,
      score: (json['score'] as int?) ?? 0,
      descendants: (json['descendants'] as int?) ?? 0,
      kids: (json['kids'] as List<dynamic>?)?.cast<int>() ?? [],
      time: (json['time'] as int?) ?? 0,
      deleted: (json['deleted'] as bool?) ?? false,
      dead: (json['dead'] as bool?) ?? false,
    );
  }

  String get domain {
    if (url == null) return '';
    try {
      final uri = Uri.parse(url!);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return '';
    }
  }
}
