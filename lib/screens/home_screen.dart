import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stream_provider.dart';
import '../widgets/stream_view.dart';
import '../models/stream_feed.dart';
import '../models/display_type.dart';

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
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: (value) {
                    if (value == 'display_type') {
                      _showDisplayTypeDialog(context, espStreamProvider);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'display_type',
                      child: Text('Display Type'),
                    ),
                  ],
                ),
              ],
              bottom: espStreamProvider.displayType == DisplayType.tabs
                  ? TabBar(
                      tabs: espStreamProvider.streams
                          .map((stream) => Tab(text: stream.id))
                          .toList(),
                    )
                  : null,
            ),
            body: espStreamProvider.displayType == DisplayType.tabs
                ? TabBarView(
                    children: espStreamProvider.streams
                        .map((stream) => StreamView(stream: stream))
                        .toList(),
                  )
                : _buildGridView(espStreamProvider),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddStreamDialog(context, espStreamProvider),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildTabView(EspStreamProvider provider) {
  //   return DefaultTabController(
  //     length: provider.streams.length,
  //     child: TabBarView(
  //       children: provider.streams
  //           .map((stream) => StreamView(stream: stream))
  //           .toList(),
  //     ),
  //   );
  // }

  Widget _buildGridView(EspStreamProvider provider) {
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.zero,
      mainAxisSpacing: 1,
      crossAxisSpacing: 10,
      children:
          provider.streams.map((stream) => StreamView(stream: stream)).toList(),
    );
  }

  void _showDisplayTypeDialog(
      BuildContext context, EspStreamProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Display Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tabs'),
                leading: Radio<DisplayType>(
                  value: DisplayType.tabs,
                  groupValue: provider.displayType,
                  onChanged: (DisplayType? value) {
                    provider.setDisplayType(value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Grid'),
                leading: Radio<DisplayType>(
                  value: DisplayType.grid,
                  groupValue: provider.displayType,
                  onChanged: (DisplayType? value) {
                    provider.setDisplayType(value!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddStreamDialog(BuildContext context, EspStreamProvider provider) {
    final TextEditingController ipController =
        TextEditingController(text: '192.168.68.139');
    final TextEditingController endpointController =
        TextEditingController(text: 'stream');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Stream'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'Device IP'),
              ),
              TextField(
                controller: endpointController,
                decoration: const InputDecoration(labelText: 'Endpoint'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.addStream(
                  StreamFeed(
                    id: 'Stream ${provider.streams.length + 1}',
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
  }
}
