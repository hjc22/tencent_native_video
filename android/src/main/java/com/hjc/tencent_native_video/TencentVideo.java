package com.hjc.tencent_native_video;

import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.LayoutInflater;
import 	android.os.Environment;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformView;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import com.shuyu.gsyvideoplayer.GSYVideoManager;
import com.shuyu.gsyvideoplayer.utils.OrientationUtils;
import com.shuyu.gsyvideoplayer.video.StandardGSYVideoPlayer;
import com.shuyu.gsyvideoplayer.utils.GSYVideoType;
import com.shuyu.gsyvideoplayer.player.PlayerFactory;
import tv.danmaku.ijk.media.exo2.Exo2PlayerManager;
import com.shuyu.gsyvideoplayer.listener.GSYSampleCallBack;
import com.shuyu.gsyvideoplayer.utils.Debuger;
import com.shuyu.gsyvideoplayer.listener.GSYVideoProgressListener;


public class TencentVideo implements PlatformView, MethodCallHandler {

    EmptyControlVideo videoPlayer;


    private View mView;
    private final MethodChannel methodChannel;


    static Map<String, EmptyControlVideo> _videos = new HashMap<String, EmptyControlVideo>();


    static Boolean isInit = true;

    private QueuingEventSink eventSink = new QueuingEventSink();

    private  EventChannel eventChannel;

    private  final String _viewId;


    TencentVideo(
        final Context context,
        BinaryMessenger messenger,
        int id,
        Map<String, Object> params,
        Registrar registrar) {

           mView = LayoutInflater.from(context)
            .inflate(R.layout.tencent_video, null);
            videoPlayer = (EmptyControlVideo) mView.findViewById(R.id.video_player);

            _viewId = String.valueOf(id);

            videoPlayer.setPlayTag(_viewId);

            _videos.put(_viewId, videoPlayer);

            if(isInit) {
                isInit = false;
                videoInit();
            }
            initEventChannel( messenger, registrar);

            setPlayConfig(context, params);

            methodChannel = new MethodChannel(messenger, "plugins.hjc.com/tencentVideo_" + id);
            methodChannel.setMethodCallHandler(this);

    }
    // 初始化eventChannel
    public void initEventChannel( BinaryMessenger messenger, Registrar registrar) {
        EventChannel _eventChannel = new EventChannel(registrar.messenger(), "plugins.hjc.com/tencentVideo/videoEvents" + _viewId);

        Log.i("eventChannel--", "plugins.hjc.com/tencentVideo/videoEvents" + _viewId);

        eventChannel = _eventChannel;

        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        eventSink.setDelegate(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        eventSink.setDelegate(null);
                    }
                }
        );
    }


    private void setPlayConfig(final Context context, Map<String, Object> params) {
       //是否可以滑动调整
        videoPlayer.setIsTouchWiget(false);

//        videoPlayer.setLooping(false);

        final boolean isLoop =  (boolean) params.get("loop");
        final boolean isCache =  (boolean) params.get("isCache");
        final boolean autoPlay =  (boolean) params.get("autoPlay");



        Log.i("tag---", "开始了----");


        videoPlayer.setVideoAllCallBack(new GSYSampleCallBack(){

            @Override
            public void onPrepared(String url, Object... objects) {
                super.onPrepared(url, objects);

                Log.i("tag---", "开始了22----");
                Debuger.printfLog("Duration " + videoPlayer.getDuration() + "CurrentPosition");

                Map<String, Object> preparedMap = new HashMap<>();
                preparedMap.put("event", "initialized");
                preparedMap.put("duration", (int) videoPlayer.getDuration());
                preparedMap.put("width", videoPlayer.getGSYVideoManager().getCurrentVideoWidth());
                preparedMap.put("height", videoPlayer.getGSYVideoManager().getCurrentVideoHeight());
                eventSink.success(preparedMap);

            }
            // 播放完成
            public void onAutoComplete(String url, Object... objects) {
                super.onAutoComplete(url, objects);

                if(isLoop) {
                    Map<String, Object> playendMap = new HashMap<>();
                    playendMap.put("event", "singlePlayCompleted");

                    videoPlayer.seekTo(0);
                    videoPlayer.startPlayLogic();
//                    videoPlayer.onVideoReset();
                    eventSink.success(playendMap);
                }
                else {
                    Log.i("tag--播放完成","");
                    Map<String, Object> playendMap = new HashMap<>();
                    playendMap.put("event", "playend");
                    eventSink.success(playendMap);
                }
            }

            // 播放完成
            public void onComplete(String url, Object... objects) {
                Log.i("tag--播放完成","");

                Map<String, Object> playendMap = new HashMap<>();
                playendMap.put("event", "playend");
                eventSink.success(playendMap);
            }

            //播放错误，objects[0]是title，object[1]是当前所处播放器（全屏或非全屏）
            public void onPlayError(String url, Object... objects) {
                super.onPlayError(url, objects);

                Log.i("tag--错误-","");

                Map<String, Object> errorMap = new HashMap<>();
                errorMap.put("event", "error");
                errorMap.put("errorInfo", objects[0]);
                eventSink.success(errorMap);
            }
        });


        videoPlayer.setGSYVideoProgressListener(new GSYVideoProgressListener(){
            @Override
            public void onProgress(int progress, int secProgress, int currentPosition, int duration) {
                Map<String, Object> progressMap = new HashMap<>();
                Log.i("tag--进度-", String.valueOf(progress));
                Log.i("tag--进度-", String.valueOf(currentPosition));
                Log.i("tag--进度-", String.valueOf(duration));

                progressMap.put("event", "progress");
                progressMap.put("progress", currentPosition );
                progressMap.put("duration", duration);
                progressMap.put("playable", secProgress);
                eventSink.success(progressMap);
            };
        });
    }


    String _url;
    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {


        String viewId;
        EmptyControlVideo _videoPlayer;

        if(String.class.isInstance(methodCall.arguments)) {
            viewId = methodCall.arguments.toString();

            _videoPlayer = _videos.get(viewId);

            if(_videoPlayer == null) {
                result.error("NO_VIEWID", "No viewId", null);
                return;
            }
        }
        else {
            _videoPlayer = null;
            viewId = "";
        }
      switch (methodCall.method) {
          case "loadUrl":
              Map<String, String> args = methodCall.arguments();

              String url = args.get("url");

              viewId = args.get("viewId");

              _videoPlayer = _videos.get(viewId);

              _url = url;

              Log.i("url222-start--", _url);

              _videoPlayer.setUp(url, true, "测试视频");

              _videoPlayer.startPlayLogic();

              result.success(true);

              break;
          case "pause":
              _videoPlayer.onVideoPause();
              result.success(true);
              break;
          case "play":
              _videoPlayer.onVideoResume();
              result.success(true);
              break;
          case "dispose":
              _videoPlayer.setVideoAllCallBack(null);
              _videoPlayer.setGSYVideoProgressListener(null);
              _videoPlayer.releaseVideos();
              _videos.remove(viewId);
              mView.setVisibility(View.GONE);
              eventChannel.setStreamHandler(null);
              mView = null;
              result.success(true);
              break;

          default:
              result.notImplemented();
      }
  }
    @Override
    public void dispose() {

    }

    static void videoInit() {
        GSYVideoManager.releaseAllVideos();
        GSYVideoType.setShowType(GSYVideoType.SCREEN_MATCH_FULL);
        GSYVideoType.setRenderType(GSYVideoType.GLSURFACE);
        PlayerFactory.setPlayManager(Exo2PlayerManager.class);
    }

    @Override
    public View getView() {
        return mView;
    }
}