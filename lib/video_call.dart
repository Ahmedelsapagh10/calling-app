import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constant.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int _remoteUid = 0;
  late RtcEngine _engine;

  @override
  void initState() {
    initAgora();
    super.initState();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: AgoraManager.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine.enableVideo();

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
      token: AgoraManager.token,
      channelId: AgoraManager.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    setState(() {});
  }

  Widget _renderLocalPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: 'channel1'),
        ),
      );
    } else {
      return const Text(
        'Calling …',
        style: TextStyle(fontSize: 20, color: Colors.black),
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: _renderRemoteVideo()),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(150.0),
                child: Container(
                  height: 150,
                  width: 150,
                  child: _renderLocalPreview(),
                ),
              ),
            ),
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
