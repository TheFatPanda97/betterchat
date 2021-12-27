import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("主页")),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 7.5, top: 15, left: 15),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/shawn.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 150,
                    child: InkWell(onTap: () async {
                      const errorSnackBar = SnackBar(
                        content: Text('需要获取音视频权限才能进入'),
                      );

                      if (!(await Permission.camera.request().isGranted) ||
                          !(await Permission.microphone.request().isGranted)) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(errorSnackBar);
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        '/video',
                      );
                    }),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  height: 150,
                  margin: EdgeInsets.only(left: 7.5, top: 15, right: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
