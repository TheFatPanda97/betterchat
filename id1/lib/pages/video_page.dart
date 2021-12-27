import 'package:betterchat/utils/generate_user_sig.dart';
import 'package:flutter/material.dart';
// import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:betterchat/widgets/moveable_container.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late TRTCCloud trtcCloud;
  int? localViewId;
  bool isOpenFrontCamera = true;
  bool isMicOn = true;

  @override
  initState() {
    super.initState();
    initRoom();
  }

  initRoom() async {
    // 创建 TRTCCloud 单例
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    // 注册事件回调
    // trtcCloud.registerListener(onRtcListener);

    final userSig = GenerateUserSig.genUserSig();

    await trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: GenerateUserSig.sdkAppId, // Application ID
            userId: GenerateUserSig.userId, // User ID
            userSig: userSig, // User signature
            roomId: 2), // Room ID
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: TRTCCloudVideoView(onViewCreated: (viewId) async {
            await trtcCloud.startLocalPreview(isOpenFrontCamera, viewId);
            await trtcCloud
                .startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
            setState(() {
              localViewId = viewId;
            });
          }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(45.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: () {
                    trtcCloud.muteLocalAudio(isMicOn ? true : false);
                    setState(() {
                      isMicOn = !isMicOn;
                    });
                  },
                  child: Icon(
                    Icons.mic_off,
                    size: 27,
                    color: isMicOn ? Colors.white : Colors.black,
                  ),
                  backgroundColor: isMicOn ? Colors.black : Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35, right: 35),
                  child: Transform.scale(
                    scale: 1.5,
                    child: FloatingActionButton(
                      onPressed: () async {
                        await trtcCloud.exitRoom();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.phone_disabled_rounded),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                FloatingActionButton(
                    onPressed: () async {
                      await trtcCloud.stopLocalPreview();
                      await trtcCloud.startLocalPreview(
                          !isOpenFrontCamera, localViewId);
                      setState(() {
                        isOpenFrontCamera = !isOpenFrontCamera;
                      });
                    },
                    child: Icon(
                      Icons.cameraswitch_rounded,
                      size: 27,
                      color: isOpenFrontCamera ? Colors.white : Colors.black,
                    ),
                    backgroundColor:
                        isOpenFrontCamera ? Colors.black : Colors.white),
              ],
            ),
          ),
        ),
        const MoveableStackItem(),
      ]),
    );
  }
}
