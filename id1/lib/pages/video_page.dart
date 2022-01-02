import 'package:betterchat/utils/generate_user_sig.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:betterchat/widgets/moveable_container.dart';
import 'package:audioplayers/audioplayers.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late TRTCCloud trtcCloud;
  final audioPlayer = AudioCache();
  late AudioPlayer lateAudioPlayer;
  int? localViewId;
  bool isOpenFrontCamera = true;
  bool isMicOn = true;
  String? remoteUserId;

  @override
  initState() {
    super.initState();
    initRoom();
  }

  onRtcListener(type, param) async {
    // Callback for room entry
    if (type == TRTCCloudListener.onEnterRoom) {
      if (param > 0) {
        lateAudioPlayer = await audioPlayer.loop(
          'ringtone.mp3',
        );
      }
    }
    // Callback for the entry of a remote user
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      // The parameter is the user ID of the remote user.
    }
    // Callback of whether a remote user has playable video in the primary stream (usually used for camera video)
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      setState(() {
        remoteUserId = param['userId'];
      });
      //param['userId'] is the user ID of the remote user.
      //param['visible'] indicates whether video is enabled.
      lateAudioPlayer.release();
    }

    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      await destoryRoom();
      Navigator.pop(context);
    }
  }

  destoryRoom() async {
    lateAudioPlayer.release();
    trtcCloud.unRegisterListener(onRtcListener);
    await trtcCloud.exitRoom();
    await TRTCCloud.destroySharedInstance();
  }

  initRoom() async {
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    trtcCloud.registerListener(onRtcListener);

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
      child: SafeArea(
        child: Stack(children: <Widget>[
          if (remoteUserId != null) ...[
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Expanded(
                  child: TRTCCloudVideoView(onViewCreated: (viewId) async {
                    await trtcCloud.startRemoteView(
                      remoteUserId!,
                      TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
                      viewId,
                    );
                  }),
                )),
          ],
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
                          await destoryRoom();
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
          MoveableStackItem(
            trtcCloud: trtcCloud,
            remoteUserConnected: remoteUserId != null,
            updateLocalViewId: (int viewId) {
              setState(() {
                localViewId = viewId;
              });
            },
            isOpenFrontCamera: isOpenFrontCamera,
          ),
          if (remoteUserId == null) ...[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.5),
                width: MediaQuery.of(context).size.width,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '呼叫龙儿中 。。。',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
