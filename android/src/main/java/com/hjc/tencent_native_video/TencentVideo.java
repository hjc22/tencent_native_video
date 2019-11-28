package com.hjc.tencent_native_video;

import android.content.Context;
import android.app.Activity;
import android.os.Build;
import android.os.Handler;
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

TencentVideo(
        final Context context,
        BinaryMessenger messenger,
        int id,
        Map<String, Object> params) {

           mView = LayoutInflater.from(context)
            .inflate(R.layout.tencent_video, null);
            videoPlayer = (EmptyControlVideo) mView.findViewById(R.id.video_player);

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
        GSYVideoType.setShowType(GSYVideoType.SCREEN_MATCH_FULL);
         GSYVideoType.setRenderType(GSYVideoType.GLSURFACE);
        PlayerFactory.setPlayManager(Exo2PlayerManager.class);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
      switch (methodCall.method) {
          case "loadUrl":
              String url = methodCall.arguments.toString();

              videoPlayer.setUp(url, true, "测试视频");

              videoPlayer.startPlayLogic();

              result.success(true);

              break;
          case "dispose":
                  methodChannel.setMethodCallHandler(null);
                 GSYVideoManager.releaseAllVideos();
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
        methodChannel.setMethodCallHandler(null);
//        mView.destroy();
        GSYVideoManager.releaseAllVideos();
    }

    @Override
    public View getView() {
        return mView;
    }
}