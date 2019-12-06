//
//  FLTVideoPlayer.h
//  flutter_plugin_demo3
//
//  Created by Wei on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import <Flutter/Flutter.h>
#import "VVIew.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : NSObject<FlutterStreamHandler,AVPDelegate>
@property(readonly,nonatomic) AliPlayer* txPlayer;
@property(nonatomic) FlutterEventChannel* eventChannel;
@property(nonatomic) VView* _view;

//ios主动和flutter通信
@property(nonatomic) FlutterEventSink eventSink;
@property(nonatomic, readonly) bool disposed;

/**
 * 是否循环播放
 */
@property (nonatomic, assign) BOOL loop;

- (instancetype)initWithCall:(NSDictionary*)argsMap
                   viewId: (int64_t*) viewId
                   view: (VView*) view
                   messenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)dispose;
-(void)resume;
-(void)pause;
-(int64_t)position;
-(int64_t)duration;
-(void)seekTo:(int)position;
/**
 * 设置播放开始时间
 * 在startPlay前设置，修改开始播放的起始位置
 */
- (void)setStartTime:(CGFloat)startTime;

/**
 * 停止播放音视频流
 * @return 0 = OK
 */
- (int)stopPlay;
/**
 * 可播放时长
 */
- (float)playableDuration;
/**
 * 视频宽度
 */
- (int)width;

/**
 * 视频高度
 */
- (int)height;
/**
 * 设置画面的方向
 * @param rotation 方向
 * @see TX_Enum_Type_HomeOrientation
 */
- (void)setRenderRotation:(AVPRotateMode)rotation;
/**
 * 设置画面的裁剪模式
 * @param renderMode 裁剪
 * @see TX_Enum_Type_RenderMode
 */
- (void)setRenderMode:(AVPScalingMode)renderMode;
/**
 * 设置静音
 */
- (void)setMute:(BOOL)bEnable;

/*
 * 截屏
 * @param snapshotCompletionBlock 通过回调返回当前图像
 */
- (void)onCaptureScreen:(AliPlayer *)player image:(UIImage *)image;
/**
 * 设置播放速率
 * @param rate 正常速度为1.0；小于为慢速；大于为快速。最大建议不超过2.0
 */
- (void)setRate:(float)rate;
// 设置播放清晰度
- (void)setBitrateIndex:(int)index;
/**
 * 设置画面镜像
 */
- (void)setMirror:(BOOL)isMirror;

-(void) startPlay:(NSString *) url;

@end

NS_ASSUME_NONNULL_END
