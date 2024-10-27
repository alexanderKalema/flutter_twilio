import 'package:flutter/material.dart';
import 'package:video_call_app/video_call_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoCallScreen(
                    accessToken: 'YOUR_ACCESS_TOKEN',
                    roomName: 'ROOM_NAME',
                  ),
                ),
              );
            },
            child: const Text('Start Video Call'),
          ),
        ),
      ),
    );
  }
}