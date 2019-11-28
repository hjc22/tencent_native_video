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

import com.tencent.rtmp.ITXVodPlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXPlayerAuthBuilder;
import com.tencent.rtmp.TXVodPlayConfig;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;


public class TencentVideo implements PlatformView, MethodCallHandler {
    private TXVodPlayer txPlayer;
    private TXCloudVideoView mView;
    private final MethodChannel methodChannel;
    TXVodPlayConfig mPlayConfig;

TencentVideo(
        final Context context,
        BinaryMessenger messenger,
        int id,
        Map<String, Object> params) {

           View view1 = LayoutInflater.from(context)
            .inflate(R.layout.tencent_video, null);
            mView = (TXCloudVideoView) view1.findViewById(R.id.superVodPlayerView);
            txPlayer = new TXVodPlayer(context);

            setPlayConfig();

    txPlayer.setPlayerView(mView);
            methodChannel = new MethodChannel(messenger, "plugins.hjc.com/tencentVideo_" + id);
            methodChannel.setMethodCallHandler(this);
 }

    private void setPlayConfig() {
        mPlayConfig = new TXVodPlayConfig();
        mPlayConfig.setCacheFolderPath(Environment.getExternalStorageDirectory().getPath() + "/txcache");
        mPlayConfig.setMaxCacheItems(2);
        txPlayer.setConfig(this.mPlayConfig);
        txPlayer.enableHardwareDecode(true);
        txPlayer.setLoop(true);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, Result result) {
      switch (methodCall.method) {
          case "loadUrl":
              String url = methodCall.arguments.toString();
              txPlayer.startPlay(url);

              break;
          case "dispose":
                  txPlayer.stopPlay(true);
                  methodChannel.setMethodCallHandler(null);
                  txPlayer = null;
                  mView.onDestroy();
                  mView = null;
                  break;

          default:
              result.notImplemented();
      }
  }
    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        txPlayer.stopPlay(true);
        txPlayer = null;
        mView.onDestroy();
    }

    @Override
    public View getView() {
        return mView;
    }
}