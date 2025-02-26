import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constant.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({
    required this.token,
    required this.channelName,
     Key? key}) : super(key: key);
  final String token;
  final String channelName;
  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  int _remoteUid = 0;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> initAgora() async {
    await Permission.microphone.request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: AgoraManager.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine.enableAudio();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('local user ${connection.localUid} joined');
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print('remote user $uid joined');
          setState(() {
            _remoteUid = uid;
          });
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          print('remote user $uid left');
          setState(() {
            _remoteUid = 0;
          });
          Navigator.of(context).pop(true);
        },
      ),
    );

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName, //AgoraManager.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    setState(() {});
  }

  Widget _renderRemoteAudio() {
    return Text(
      _remoteUid != 0 ? 'Calling with $_remoteUid' : 'Calling …',
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: Center(child: _renderRemoteAudio()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                icon: const Icon(Icons.call_end,
                    size: 44, color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
