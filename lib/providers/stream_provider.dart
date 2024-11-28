import 'package:flutter/foundation.dart';
import '../models/stream_feed.dart';

class EspStreamProvider extends ChangeNotifier {
  final List<StreamFeed> _streams = [];

  List<StreamFeed> get streams => _streams;

  void addStream(StreamFeed stream) {
    _streams.add(stream);
    notifyListeners();
  }

  void removeStream(String id) {
    _streams.removeWhere((stream) => stream.id == id);
    notifyListeners();
  }
}
