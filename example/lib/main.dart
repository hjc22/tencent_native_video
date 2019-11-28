import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tencent_native_video/tencentNativeVideoPlayer.dart';
import 'package:tencent_native_video/tencent_native_video.dart';

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
    try {

    } on PlatformException {
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
          child: GestureDetector(
            onTap: () {
              print('21424');
            },
            onHorizontalDragEnd: (d) {
              print('3333');
              _controller.dispose();

            },
            child: TencentNativeVideoPlayer(
              onCreated: (TencentNativeVideoController controller) {
                _controller = controller;
                controller.loadUrl(url: 'http://img.askcnd.com/v/50656.mp4');
              },
            ),
          ),
        ),
      ),
    );
  }
}
