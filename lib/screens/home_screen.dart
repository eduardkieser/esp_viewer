import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';
import '../widgets/stream_view.dart';
import '../models/stream_feed.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EspStreamProvider>(
      builder: (context, espStreamProvider, child) {
        return DefaultTabController(
          length: espStreamProvider.streams.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('ESP Viewer'),
              bottom: TabBar(
                tabs: espStreamProvider.streams
                    .map((stream) => Tab(text: stream.id))
                    .toList(),
              ),
            ),
            body: TabBarView(
              children: espStreamProvider.streams
                  .map((stream) => StreamView(stream: stream))
                  .toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController ipController =
                        TextEditingController(text: '192.168.68.139');
                    final TextEditingController endpointController =
                        TextEditingController(text: 'stream');

                    return AlertDialog(
                      title: const Text('Add Stream'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: ipController,
                            decoration:
                                const InputDecoration(labelText: 'Device IP'),
                          ),
                          TextField(
                            controller: endpointController,
                            decoration:
                                const InputDecoration(labelText: 'Endpoint'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Add a new stream to the provider
                            espStreamProvider.addStream(
                              StreamFeed(
                                id: 'Stream ${espStreamProvider.streams.length + 1}',
                                url:
                                    'http://${ipController.text}/${endpointController.text}',
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
