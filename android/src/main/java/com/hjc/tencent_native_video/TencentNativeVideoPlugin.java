package com.hjc.tencent_native_video;

import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.BinaryMessenger;


/** TencentNativeVideoPlugin */
public class TencentNativeVideoPlugin implements FlutterPlugin {

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    BinaryMessenger messenger = flutterPluginBinding.getFlutterEngine().getDartExecutor();

    Log.i("native video----", "init44");
    flutterPluginBinding
            .getFlutterEngine()
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory(
                    "plugins.hjc.com/tencentVideo",
                    new TencentVideoFactory(messenger,/*containerView=*/ null));
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {

    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "plugins.hjc.com/tencentVideo",
                    new TencentVideoFactory(registrar.messenger(

                    ), null));
  }



  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
