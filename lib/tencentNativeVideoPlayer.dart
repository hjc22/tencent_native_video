


import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './tencent_native_video.dart';

typedef ViewCreatedCallback = void Function(TencentNativeVideoController controller);

class TencentNativeVideoPlayer extends StatefulWidget {

  TencentNativeVideoPlayer({@required this.onCreated});

  final ViewCreatedCallback onCreated;


  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}


class _VideoPlayerState extends State<TencentNativeVideoPlayer> {

  @override
  void initState() {
    super.initState();
  }
  TencentNativeVideoController controller;

  static const _viewType = 'plugins.hjc.com/tencentVideo';

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: _viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
      
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: _viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
   
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    controller =
    await TencentNativeVideoController.init(id);
    if (widget.onCreated != null) widget.onCreated(controller);
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}