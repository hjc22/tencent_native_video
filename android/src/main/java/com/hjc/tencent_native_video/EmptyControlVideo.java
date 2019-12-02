package com.hjc.tencent_native_video;

import android.content.Context;
import android.util.AttributeSet;
import android.text.TextUtils;
import android.util.Log;

import com.hjc.tencent_native_video.R;
import com.shuyu.gsyvideoplayer.video.StandardGSYVideoPlayer;
import com.shuyu.gsyvideoplayer.GSYVideoManager;
import com.shuyu.gsyvideoplayer.utils.Debuger;
import com.shuyu.gsyvideoplayer.video.base.GSYVideoViewBridge;
//import com.example.gsyvideoplayer.video.manager.CustomManager;

/**
 * 无任何控制ui的播放
 * Created by guoshuyu on 2017/8/6.
 */

public class EmptyControlVideo extends StandardGSYVideoPlayer {

    private final static String TAG = "MultiSampleVideo";

    public EmptyControlVideo(Context context, Boolean fullFlag) {
        super(context, fullFlag);
    }

    public EmptyControlVideo(Context context) {
        super(context);
    }

    public EmptyControlVideo(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    public int getLayoutId() {
        return R.layout.empty_control;
    }

    @Override
    protected void touchSurfaceMoveFullLogic(float absDeltaX, float absDeltaY) {
        super.touchSurfaceMoveFullLogic(absDeltaX, absDeltaY);
        //不给触摸快进，如果需要，屏蔽下方代码即可
        mChangePosition = false;

        //不给触摸音量，如果需要，屏蔽下方代码即可
        mChangeVolume = false;

        //不给触摸亮度，如果需要，屏蔽下方代码即可
        mBrightness = false;
    }

    @Override
    protected void touchDoubleUp() {
        //super.touchDoubleUp();
        //不需要双击暂停
    }

    @Override
    public GSYVideoViewBridge getGSYVideoManager() {
        CustomManager.getCustomManager(getKey()).initContext(getContext().getApplicationContext());
        return CustomManager.getCustomManager(getKey());
    }


    @Override
    protected void releaseVideos() {

        CustomManager.releaseAllVideos(getKey());
    }
//
    public String getKey() {
        if (mPlayPosition == -22) {
            Debuger.printfError(getClass().getSimpleName() + " used getKey() " + "******* PlayPosition never set. ********");
        }
        if (TextUtils.isEmpty(mPlayTag)) {
            Debuger.printfError(getClass().getSimpleName() + " used getKey() " + "******* PlayTag never set. ********");
        }
        return TAG + mPlayPosition + mPlayTag;
    }
}