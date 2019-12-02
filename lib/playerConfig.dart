import 'package:flutter/material.dart';


class PlayerConfig {
  final bool autoPlay;
  final bool loop;
  final Map<String, String> headers;
  final bool isCache;
  final VoidCallback onSinglePlayCompleted;
  final VoidCallback onCompleted;
  final int progressInterval;
  // 单位:秒
  final int startTime;
  final Map<String, dynamic> auth;


  const PlayerConfig(
      {this.autoPlay = true,
        this.loop = false,
        this.headers,
        this.isCache = true,
        this.progressInterval = 200,
        this.startTime,
        this.auth,
        this.onSinglePlayCompleted,
        this.onCompleted
      });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'autoPlay': this.autoPlay,
    'loop': this.loop,
    'headers': this.headers,
    'isCache': this.isCache,
    'progressInterval': this.progressInterval,
    'startTime': this.startTime,
    'auth': this.auth,
  };
}