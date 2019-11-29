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


public class TencentVideo implements PlatformView, MethodCallHandler {

    EmptyControlVideo videoPlayer;


    private View mView;
    private final MethodChannel methodChannel;


    static Map<String, EmptyControlVideo> _videos = new HashMap<String, EmptyControlVideo>();


    static Boolean isInit = true;

TencentVideo(
        final Context context,
        BinaryMessenger messenger,
        int id,
        Map<String, Object> params) {

           mView = LayoutInflater.from(context)
            .inflate(R.layout.tencent_video, null);
            videoPlayer = (EmptyControlVideo) mView.findViewById(R.id.video_player);

            videoPlayer.setPlayTag(String.valueOf(id));

            _videos.put(String.valueOf(id), videoPlayer);

            if(isInit) {
                isInit = false;
                videoInit();
            }

            setPlayConfig(context);

            methodChannel = new MethodChannel(messenger, "plugins.hjc.com/tencentVideo_" + id);
            methodChannel.setMethodCallHandler(this);
 }

    private void setPlayConfig(final Context context) {
       //是否可以滑动调整
        videoPlayer.setIsTouchWiget(false);

        videoPlayer.setLooping(true);


//        //设置返回键
//        videoPlayer.getBackButton().setVisibility(View.GONE);
//        //设置返回键
//        videoPlayer.getStartButton().setVisibility(View.GONE);
//        videoPlayer.getFullscreenButton().setVisibility(View.GONE);
//        videoPlayer.setIsTouchWigetFull(false);


        //增加title
//        videoPlayer.getTitleTextView().setVisibility(View.GONE);

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

              Log.i("url222-end--", viewId);
              Log.i("url222-length--", String.valueOf(_videos.size()));
              _videoPlayer.setVideoAllCallBack(null);
//              _videoPlayer.release();
              _videoPlayer.releaseVideos();
              _videos.remove(viewId);
              mView.setVisibility(View.GONE);
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