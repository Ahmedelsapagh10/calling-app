import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  late RtcEngine _engine;

  Future<void> initialize() async {
    _engine = createAgoraRtcEngine(); // ✅ Use this method to create engine
    await _engine.initialize(const RtcEngineContext(
      appId: '22c6a09b3eab42b49f90445c09d0c047',
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine.enableVideo();
  }

  RtcEngine get engine => _engine;
}
