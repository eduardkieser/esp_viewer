class StreamFeed {
  final String id;
  final String url;
  final List<Map<String, int>> rioFrames; // Will hold frame coordinates later

  StreamFeed({
    required this.id,
    required this.url,
    this.rioFrames = const [],
  });
}
