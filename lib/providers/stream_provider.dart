import 'package:flutter/foundation.dart';
import '../models/stream_feed.dart';
import '../models/display_type.dart';

class EspStreamProvider extends ChangeNotifier {
  final List<StreamFeed> _streams = [];
  DisplayType _displayType = DisplayType.tabs;

  List<StreamFeed> get streams => _streams;
  DisplayType get displayType => _displayType;

  void setDisplayType(DisplayType type) {
    _displayType = type;
    notifyListeners();
  }

  void addStream(StreamFeed stream) {
    _streams.add(stream);
    notifyListeners();
  }

  void removeStream(String id) {
    _streams.removeWhere((stream) => stream.id == id);
    notifyListeners();
  }
}
