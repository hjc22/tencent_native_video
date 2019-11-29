import 'dart:async';

import 'package:flutter/services.dart';


class TencentNativeVideoController {
  MethodChannel _channel;

  String viewId;
  TencentNativeVideoController.init(int id) {
    viewId = id.toString();
    _channel =  new MethodChannel('plugins.hjc.com/tencentVideo_$id');
  }
  Future<void> loadUrl({String url}) async {
    return await _channel.invokeMethod('loadUrl', {
      'url': url,
      'viewId': viewId
    });
  }

  Future<void> pause() async {
    return await _channel.invokeMethod('pause', viewId);
  }

  Future<void> play({String url}) async {
    return await _channel.invokeMethod('play', viewId);
  }

  dispose() async {

    print('333333255');
    _channel.invokeMethod('dispose', viewId);
  }
}
