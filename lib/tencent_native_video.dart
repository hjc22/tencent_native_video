import 'dart:async';

import 'package:flutter/services.dart';

class TencentNativeVideoController {
  MethodChannel _channel;


  TencentNativeVideoController.init(int id) {
    _channel =  new MethodChannel('plugins.hjc.com/tencentVideo_$id');
  }
  Future<void> loadUrl({String url}) async {
    return await _channel.invokeMethod('loadUrl', url);
  }

  dispose() async {

    print('333333255');
     _channel.invokeMethod('dispose');
  }
}
