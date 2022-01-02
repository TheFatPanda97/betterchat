import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';

class MoveableStackItem extends StatefulWidget {
  TRTCCloud trtcCloud;
  final bool remoteUserConnected;
  final bool isOpenFrontCamera;
  final void Function(int localViewId) updateLocalViewId;

  MoveableStackItem(
      {Key? key,
      required this.trtcCloud,
      required this.remoteUserConnected,
      required this.isOpenFrontCamera,
      required this.updateLocalViewId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MoveableStackItemState();
  }
}

class _MoveableStackItemState extends State<MoveableStackItem> {
  double xPosition = 0;
  double yPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        onPanUpdate: (tapInfo) {
          if (!widget.remoteUserConnected) {
            return;
          }

          double width = MediaQuery.of(context).size.width;
          double height = MediaQuery.of(context).size.height;

          setState(() {
            if (xPosition + tapInfo.delta.dx >= 0 &&
                xPosition + tapInfo.delta.dx + 130 <= width) {
              xPosition += tapInfo.delta.dx;
            }

            if (yPosition + tapInfo.delta.dy >= 0 &&
                yPosition + tapInfo.delta.dy + 360 <= height) {
              yPosition += tapInfo.delta.dy;
            }
          });
        },
        child: SizedBox(
          width: widget.remoteUserConnected
              ? 130
              : MediaQuery.of(context).size.width,
          height: widget.remoteUserConnected
              ? 220
              : MediaQuery.of(context).size.height,
          child: TRTCCloudVideoView(onViewCreated: (viewId) async {
            await widget.trtcCloud
                .startLocalPreview(widget.isOpenFrontCamera, viewId);
            await widget.trtcCloud
                .startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
            widget.updateLocalViewId(viewId);
          }),
        ),
      ),
    );
  }
}
