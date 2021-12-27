import 'package:flutter/material.dart';

class MoveableStackItem extends StatefulWidget {
  const MoveableStackItem({Key? key}) : super(key: key);

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
        child: Container(
          width: 130,
          height: 220,
          color: Colors.red,
        ),
      ),
    );
  }
}
