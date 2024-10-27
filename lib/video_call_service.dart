import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallService {
  Room? _room;

  Future<bool> requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return await Permission.camera.isGranted &&
        await Permission.microphone.isGranted;
  }

  Future<Room?> connectToRoom(String accessToken, String roomName) async {
    try {
      final connectOptions = ConnectOptions(
        accessToken,
        roomName: roomName,
        enableNetworkQuality: true,
        enableDominantSpeaker: true,
        preferredAudioCodecs: [OpusCodec()],
        preferredVideoCodecs: [H264Codec()],
        enableAutomaticSubscription: true,
      );

      _room = await TwilioProgrammableVideo.connect(connectOptions);
      return _room;
    } catch (e) {
      print('Error connecting to room: $e');
      return null;
    }
  }

  Future<void> disconnect() async {
    try {
      await _room?.disconnect();
      _room = null;
    } catch (e) {
      print('Error disconnecting from room: $e');
    }
  }
}