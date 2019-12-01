import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'tencent_native_video.dart';

class TencentNativeVideoController extends ValueNotifier<VideoPlayerValue> {
  MethodChannel _channel;

  String viewId;
  bool _isDisposed = false;

  final PlayerConfig playerConfig;

  StreamSubscription<dynamic> _eventSubscription;

  TencentNativeVideoController.init(int id, {this.playerConfig}): viewId = id.toString(), _channel = MethodChannel('plugins.hjc.com/tencentVideo_$id'), super(VideoPlayerValue());

//  viewId = id.toString();
//  _channel =  new MethodChannel('plugins.hjc.com/tencentVideo_$id');
//
//  super(VideoPlayerValue());
  Future<void> loadUrl({String url}) async {

    _eventSubscription = _eventChannelFor(viewId)
        .receiveBroadcastStream()
        .listen(eventListener);

    value = value.copyWith(isPlaying: playerConfig.autoPlay);

    return await _channel.invokeMethod('loadUrl', {
      'url': url,
      'viewId': viewId
    });


  }

  Future<void> pause() async {
    value = value.copyWith(isPlaying: true);

    return _applyPlayPause();
  }

  Future<void> play({String url}) async {
    value = value.copyWith(isPlaying: false);
    return _applyPlayPause();
  }

  Future<void> _applyPlayPause() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    if (value.isPlaying) {
      return await _channel.invokeMethod('pause', viewId);
    } else {
      return await _channel.invokeMethod('play', viewId);
    }
  }

  dispose() async {
    if (!_isDisposed) {
      _isDisposed = true;
      await _eventSubscription?.cancel();
      print('333333255');
      _channel.invokeMethod('dispose', viewId);
    }
  }

  void eventListener(dynamic event) {

    print(value);
    if (_isDisposed) {
      return;
    }
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'initialized':
        value = value.copyWith(
          duration: Duration(milliseconds: map['duration']),
          size: Size(map['width']?.toDouble() ?? 0.0,
              map['height']?.toDouble() ?? 0.0),
        );
        break;
      case 'progress':
        value = value.copyWith(
          position: Duration(milliseconds: map['progress']),
          duration: Duration(milliseconds: map['duration']),
          playable: Duration(milliseconds: map['playable']),
        );
        break;
      case 'loading':
        value = value.copyWith(isLoading: true);
        break;
      case 'loadingend':
        value = value.copyWith(isLoading: false);
        break;
      case 'playend':
        value = value.copyWith(isPlaying: false, position: value.duration);
        break;
      case 'netStatus':
        value = value.copyWith(netSpeed: map['netSpeed']);
        break;
      case 'error':
        value = value.copyWith(errorDescription: map['errorInfo']);
        break;
    }
  }


  EventChannel _eventChannelFor(String viewId) {
     return EventChannel('plugins.hjc.com/tencentVideo/videoEvents$viewId');
  }
}