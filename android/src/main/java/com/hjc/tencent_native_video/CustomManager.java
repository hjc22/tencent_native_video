package com.hjc.tencent_native_video;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

//import com.example.gsyvideoplayer.R;
import com.shuyu.gsyvideoplayer.GSYVideoBaseManager;
import com.shuyu.gsyvideoplayer.player.IPlayerManager;
import com.shuyu.gsyvideoplayer.player.IjkPlayerManager;
import tv.danmaku.ijk.media.exo2.Exo2PlayerManager;
import com.shuyu.gsyvideoplayer.utils.CommonUtil;
import com.shuyu.gsyvideoplayer.video.base.GSYVideoPlayer;

import java.util.HashMap;
import java.util.Map;

import static com.shuyu.gsyvideoplayer.utils.CommonUtil.hideNavKey;

/**
 * 多个播放的管理器
 * Created by guoshuyu on 2018/1/31.
 */

public class CustomManager extends GSYVideoBaseManager {

//    public static final int SMALL_ID = R.id.custom_small_id;
//
//    public static final int FULLSCREEN_ID = R.id.custom_full_id;

    public static String TAG = "GSYVideoManager";

    private static Map<String, CustomManager> sMap = new HashMap<>();


    public CustomManager() {
        init();
    }

    @Override
    protected IPlayerManager getPlayManager() {
        return new Exo2PlayerManager();
    }


    /**
     * 页面销毁了记得调用是否所有的video
     */
    public static void releaseAllVideos(String key) {
        if (getCustomManager(key).listener() != null) {
            getCustomManager(key).listener().onCompletion();
        }
        getCustomManager(key).releaseMediaPlayer();
    }


    /**
     * 暂停播放
     */
    public void onPause(String key) {
        if (getCustomManager(key).listener() != null) {
            getCustomManager(key).listener().onVideoPause();
        }
    }

    /**
     * 恢复播放
     */
    public void onResume(String key) {
        if (getCustomManager(key).listener() != null) {
            getCustomManager(key).listener().onVideoResume();
        }
    }

    public void onBufferingUpdate(final int percent) {
        Log.i("percent=----", String.valueOf(percent));
    }



    /**
     * 恢复暂停状态
     *
     * @param seek 是否产生seek动作,直播设置为false
     */
    public void onResume(String key, boolean seek) {
        if (getCustomManager(key).listener() != null) {
            getCustomManager(key).listener().onVideoResume(seek);
        }
    }


    /**
     * 单例管理器
     */
    public static synchronized Map<String, CustomManager> instance() {
        return sMap;
    }

    /**
     * 单例管理器
     */
    public static synchronized CustomManager getCustomManager(String key) {
        if (TextUtils.isEmpty(key)) {
            throw new IllegalStateException("key not be empty");
        }
        CustomManager customManager = sMap.get(key);
        if (customManager == null) {
            customManager = new CustomManager();
            sMap.put(key, customManager);
        }
        return customManager;
    }

    public static void onPauseAll() {
        if (sMap.size() > 0) {
            for (Map.Entry<String, CustomManager> header : sMap.entrySet()) {
                header.getValue().onPause(header.getKey());
            }
        }
    }

    public static void onResumeAll() {
        if (sMap.size() > 0) {
            for (Map.Entry<String, CustomManager> header : sMap.entrySet()) {
                header.getValue().onResume(header.getKey());
            }
        }
    }

    /**
     * 恢复暂停状态
     *
     * @param seek 是否产生seek动作
     */
    public static void onResumeAll(boolean seek) {
        if (sMap.size() > 0) {
            for (Map.Entry<String, CustomManager> header : sMap.entrySet()) {
                header.getValue().onResume(header.getKey(), seek);
            }
        }
    }

    public static void clearAllVideo() {
        if (sMap.size() > 0) {
            for (Map.Entry<String, CustomManager> header : sMap.entrySet()) {
                CustomManager.releaseAllVideos(header.getKey());
            }
        }
        sMap.clear();
    }

    public static void removeManager(String key) {
        sMap.remove(key);
    }

}