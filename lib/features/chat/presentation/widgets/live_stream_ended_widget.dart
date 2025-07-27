
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class LivestreamEndedWidget extends StatefulWidget {
  const LivestreamEndedWidget({super.key, required this.call});

  final Call call;

  @override
  State<LivestreamEndedWidget> createState() => _LivestreamEndedWidgetState();
}

class _LivestreamEndedWidgetState extends State<LivestreamEndedWidget> {
  late Future<Result<List<CallRecording>>> _recordingsFuture;

  @override
  void initState() {
    super.initState();
    _recordingsFuture = widget.call.listRecordings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.call.leave();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Livestream has ended'),
            FutureBuilder(
              future: _recordingsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isSuccess) {
                  final recordings = snapshot.requireData.getDataOrNull();

                  if (recordings == null || recordings.isEmpty) {
                    return const Text('No recordings found');
                  }

                  return Column(
                    children: [
                      const Text('Watch recordings'),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: recordings.length,
                        itemBuilder: (context, index) {
                          final recording = recordings[index];
                          return ListTile(
                            title: Text(recording.url),
                            onTap: () {
                              // open
                            },
                          );
                        },
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
