import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tencent_native_video/tencentNativeVideoPlayer.dart';
import 'package:tencent_native_video/tencent_native_video.dart';
import 'package:native_video_view/native_video_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {} on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  TencentNativeVideoController _controller;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Stack(
//            fit: StackFit.expand,
            children: <Widget>[
              TencentNativeVideoPlayer(
                playerConfig: PlayerConfig(
                  loop: true,
                  autoPlay: false
                ),
                  onCreated: (TencentNativeVideoController controller) async {
                    _controller = controller;

                    controller.addListener(() {
                        print(controller.value);
                    });
                    controller.loadUrl(url: 'https://img.askcnd.com/v/50656.mp4');

                    await Future.delayed(const Duration(seconds: 2));

                    controller.play();

                  },
                ),

//              NativeVideoView(
//                onPrepared: (c, d) {},
//                onCompletion: (d) {},
//                onError: (d, c, b, f) {},
//                onCreated: (VideoViewController controller) {
//                  _controller = controller;
//                  controller.setVideoSource(
//                      'https://img.askcnd.com/v/50656.mp4',
//                      sourceType: VideoSourceType.network);
//                },
//              ),
              GestureDetector(
                onTap: () {
                  print('tap----');
                },
                child: Opacity(
                  opacity: 0,
                  child: Container(
                    color: Colors.yellow,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
