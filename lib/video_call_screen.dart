import 'package:flutter/material.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

class VideoCallScreen extends StatefulWidget {
  final String accessToken;
  final String roomName;

  const VideoCallScreen({
    super.key,
    required this.accessToken,
    required this.roomName,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Room? _room;
  LocalVideoTrack? _localVideoTrack;
  List<RemoteParticipant> _remoteParticipants = [];

  @override
  void initState() {
    super.initState();
    _connectToRoom();
  }

  Future<void> _connectToRoom() async {
    try {
      final cameraCapturer = CameraCapturer(CameraSource.fromMap(
        {
          'source': 'camera',
          'cameraSource': 'back',
        },
      ));
      _localVideoTrack = LocalVideoTrack(true, cameraCapturer);
      final connectOptions = ConnectOptions(
        widget.accessToken,
        roomName: widget.roomName,
        videoTracks: [_localVideoTrack!],
      );
      _room = await TwilioProgrammableVideo.connect(connectOptions);
      setState(() {
        _remoteParticipants = _room?.remoteParticipants ?? [];
      });
    } catch (e) {
      print('Error connecting to room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: () async {
              await _room?.disconnect();
            if(!context.mounted){
              return;
            }  Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Local video
            Expanded(
              flex: 1,
              child: _localVideoTrack != null
                  ? _LocalVideoTrackWidget(_localVideoTrack!)
                  : Center(child: CircularProgressIndicator()),
            ),
            // Remote videos
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: _remoteParticipants.length,
                itemBuilder: (context, index) {
                  return _RemoteParticipantWidget(
                    _remoteParticipants[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localVideoTrack?.release();
    _room?.disconnect();
    super.dispose();
  }
}


class _LocalVideoTrackWidget extends StatelessWidget {
  final LocalVideoTrack localVideoTrack;

  const _LocalVideoTrackWidget(this.localVideoTrack, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: localVideoTrack.widget(),
    );
  }
}

class _RemoteParticipantWidget extends StatelessWidget {
  final RemoteParticipant participant;

  const _RemoteParticipantWidget(this.participant, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> videoWidgets = participant.remoteVideoTracks.map(
            (track) {
      if (track.isTrackEnabled) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: track.remoteVideoTrack?.widget(),
        );
      } else {
        return Container();
      }
    }).toList();

    return Column(
      children: videoWidgets,
    );
  }
}