import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/stream_feed.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class StreamView extends StatefulWidget {
  final StreamFeed stream;

  const StreamView({super.key, required this.stream});

  @override
  State<StreamView> createState() => _StreamViewState();
}

class _StreamViewState extends State<StreamView> {
  Uint8List? _currentFrame;
  final StreamController<Uint8List> _streamController =
      StreamController<Uint8List>();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _connectToStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _streamController.close();
    super.dispose();
  }

  void _connectToStream() async {
    try {
      final response = await http.Client()
          .send(http.Request('GET', Uri.parse(widget.stream.url)));

      final Stream<List<int>> stream = response.stream;
      List<int> buffer = [];
      bool isCollecting = false;

      _subscription = stream.listen((List<int> chunk) {
        for (int byte in chunk) {
          if (!isCollecting && byte == 0xFF && buffer.isEmpty) {
            isCollecting = true;
          }

          if (isCollecting) {
            buffer.add(byte);

            // Check for JPEG end marker
            if (buffer.length >= 2 &&
                buffer[buffer.length - 2] == 0xFF &&
                buffer[buffer.length - 1] == 0xD9) {
              if (mounted) {
                setState(() {
                  _currentFrame = Uint8List.fromList(buffer);
                });
                _streamController.add(_currentFrame!);
              }
              buffer = [];
              isCollecting = false;
            }
          }
        }
      }, onError: (error) {
        debugPrint('Stream error: $error');
      });
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base layer: Stream image
        _currentFrame != null
            ? Image.memory(
                _currentFrame!,
                gaplessPlayback: true,
                fit: BoxFit.contain,
              )
            : const Center(child: CircularProgressIndicator()),

        // Overlay layer: ROI frames
        IgnorePointer(
          ignoring: true,
          child: CustomPaint(
            size: Size.infinite,
            painter: RioFramePainter(
              widget.stream.rioFrames,
              imageSize: _currentFrame != null
                  ? _getImageDimensions(_currentFrame!)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Size _getImageDimensions(Uint8List imageData) {
    int width = 0;
    int height = 0;

    // Search for SOF0 marker (Start Of Frame)
    for (int i = 0; i < imageData.length - 8; i++) {
      // Check for SOF0 marker (0xFF, 0xC0)
      if (imageData[i] == 0xFF && imageData[i + 1] == 0xC0) {
        // Height is at offset 5-6 (big endian)
        height = (imageData[i + 5] << 8) | imageData[i + 6];
        // Width is at offset 7-8 (big endian)
        width = (imageData[i + 7] << 8) | imageData[i + 8];
        break;
      }
    }

    // Fallback to default VGA if dimensions couldn't be extracted
    if (width == 0 || height == 0) {
      debugPrint(
          'Warning: Could not extract JPEG dimensions, using default VGA size');
      return const Size(640, 480);
    }

    return Size(width.toDouble(), height.toDouble());
  }
}

class RioFramePainter extends CustomPainter {
  final List<Map<String, int>> frames;
  final Size? imageSize;

  RioFramePainter(this.frames, {this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize == null) return;

    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate scale factors to map image coordinates to screen coordinates
    final double scaleX = size.width / imageSize!.width;
    final double scaleY = size.height / imageSize!.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Center the image frame
    final double offsetX = (size.width - (imageSize!.width * scale)) / 2;
    final double offsetY = (size.height - (imageSize!.height * scale)) / 2;

    for (var frame in frames) {
      // Assuming frame contains 'x', 'y', 'width', 'height'
      final double x = frame['x']!.toDouble() * scale + offsetX;
      final double y = frame['y']!.toDouble() * scale + offsetY;
      final double width = frame['width']!.toDouble() * scale;
      final double height = frame['height']!.toDouble() * scale;

      canvas.drawRect(
        Rect.fromLTWH(x, y, width, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RioFramePainter oldDelegate) => true;
}
