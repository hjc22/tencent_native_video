//
//  FLTVideoPlayer.m
//  flutter_plugin_demo3
//
//  Created by Wei on 2019/5/15.
//

#import "VideoPlayer.h"
#import <libkern/OSAtomic.h>



@implementation VideoPlayer{
    VView* _view;
    
    BOOL* loop;
}

- (instancetype)initWithCall:(NSDictionary*)argsMap viewId: (int64_t*) viewId view: (VView*) view messenger:(NSObject<FlutterBinaryMessenger>*)messenger{
    self = [super init];
    
    
    _view = view;

     NSLog(@"FLTVideo  viewId %lld",viewId);

    FlutterEventChannel* eventChannel = [FlutterEventChannel
                                         eventChannelWithName:[NSString stringWithFormat:@"plugins.hjc.com/tencentVideo/videoEvents%lld",viewId]
                                         binaryMessenger:messenger];



    _eventChannel = eventChannel;
    [_eventChannel setStreamHandler:self];
//    TXVodPlayConfig* playConfig = [[TXVodPlayConfig alloc]init];
//
//    playConfig.playerType = PLAYER_AVPLAYER;
//    playConfig.connectRetryCount=  3 ;
//    playConfig.connectRetryInterval = 3;
//    playConfig.timeout = 10 ;

//    id headers = argsMap[@"headers"];
//    if (headers!=nil&&headers!=NULL&&![@"" isEqualToString:headers]&&headers!=[NSNull null]) {
//        NSDictionary* headers =  argsMap[@"headers"];
//        playConfig.headers = headers;
//    }

    BOOL isCache = [argsMap[@"isCache"] boolValue];
    
    BOOL isLoop = [argsMap[@"loop"] boolValue];
    
    loop = isLoop;
    
    
    NSLog(@" json----%i", argsMap[@"isCache"]);

    NSLog(@" json----%i", isCache);
    
    

//    playConfig.progressInterval =  0.5;
    
    BOOL autoPlayArg = [argsMap[@"autoPlay"] boolValue];

    
//    NSLog(@" json----%@", argsMap[@"autoPlay"]);
//
    NSString *a;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:argsMap options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        a =  @"{}";
    } else {
        a=  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSLog(@" json----%@", a);
    
    float startPosition=0;
    id startTime = argsMap[@"startTime"];
    if(startTime!=nil&&startTime!=NULL&&![@"" isEqualToString:startTime]&&startTime!=[NSNull null]){
        startPosition =[argsMap[@"startTime"] floatValue];
    }


    _txPlayer = [[AliPlayer alloc] init];
    
    _txPlayer.delegate = self;
    
    _txPlayer.autoPlay = autoPlayArg;
    
    _txPlayer.loop = isLoop;
    
    _txPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    
    if (isCache) {
            // 设置缓存路径
    //        playConfig.cacheFolderPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/TXCache"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if(![[NSFileManager defaultManager]fileExistsAtPath:path]) {
                [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            [self addSkipBackupAttributeToItemAtPath: path];
            
            fileManager = nil;
            
            NSLog(@"开启缓存----%@", path);
            
    //        playConfig.cacheFolderPath = path;
    //        playConfig.maxCacheItems = 1000;
            
            AVPCacheConfig *config = [[AVPCacheConfig alloc] init];
            
            config.enable = YES;
            
            config.maxDuration = 100;
            
            config.path = path;
            
            config.maxSizeMB = 500;
            
            [_txPlayer setCacheConfig:config];
        }
    
    

//    [_txPlayer setConfig:playConfig];
//    [_txPlayer setIsAutoPlay:autoPlayArg];
//    _txPlayer.enableHWAcceleration = YES;
//    [_txPlayer setVodDelegate:self];
//    [_txPlayer setVideoProcessDelegate:self];
//    [_txPlayer setStartTime:startPosition];
    
//    [_txPlayer setLoop:(BOOL) loop];

    NSLog(@"播放器初始化结束");

    return self;

}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
//    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
 
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

-(void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {

    if (eventWithString == EVENT_PLAYER_CACHE_SUCCESS) {
        NSLog(@"缓存成功");
    }else if (eventWithString == EVENT_PLAYER_CACHE_ERROR) {
        NSLog(@"缓存失败");
    }
}

- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    //提示错误，及stop播放
    if(self->_eventSink!=nil){
//        NSString *code = (NSString) errorModel.code;
        
         NSString *code = [NSString stringWithFormat: @"%d", errorModel.code];
        self->_eventSink(@{
            @"event":@"error",
            @"errorInfo": errorModel.message,
            @"errorCode": code,
        });
    }
}

/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新进度条
    
    int64_t progress = position;
                    int64_t duration = [player duration];
                    int64_t playableDuration  = [player bufferedPosition];
                    if(self->_eventSink!=nil){
                        self->_eventSink(@{
                            @"event":@"progress",
                            @"progress":@(progress),
                            @"duration":@(duration),
                            @"playable":@(playableDuration)
                        });
                    }
}

/**
 * 点播事件通知
 *
 * @param player 点播对象
 * @param EvtID 参见TXLiveSDKEventDef.h
 * @param param 参见TXLiveSDKTypeDef.h
 * @see TXVodPlayer
 */
-(void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    
     switch (eventType) {
         case AVPEventPrepareDone: {
             // 准备完成
             int64_t duration = [player duration];
//                             NSString *durationStr = [NSString stringWithFormat: @"%ld", (long)duration];
//                             NSInteger  durationInt = [durationStr intValue];
             if(self->_eventSink!=nil){
                 self->_eventSink(@{
                     @"event":@"initialized",
                     @"duration":@(duration),
                     @"width":@([player width]),
                     @"height":@([player height])
                 });
             }
         }
             break;
         case AVPEventAutoPlayStart:
             // 自动播放开始事件
             break;
         case AVPEventFirstRenderedStart:
             // 首帧显示
             break;
         case AVPEventCompletion:
             // 播放完成
             
             if(self->_eventSink!=nil){
                 self->_eventSink(@{
                     @"event":@"playend",
                 });
             }
             
             break;
         case AVPEventLoadingStart:
             // 缓冲开始
             if(self->_eventSink!=nil){
                             self->_eventSink(@{
                                 @"event":@"loading",
                             });
                         }
             break;
         case AVPEventLoadingEnd:
             // 缓冲完成
             if(self->_eventSink!=nil){
                             self->_eventSink(@{
                                 @"event":@"loadingend",
                             });
                         }
             break;
         case AVPEventSeekEnd:
             // 跳转完成
             break;
         case AVPEventLoopingStart:
             // 循环播放开始
             NSLog(@"循环播放开始");
             if(self->loop) {
                 self->_eventSink(@{
                     @"event":@"singlePlayCompleted",
                 });
             }
             break;
         default:
             break;
     }

//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        if(EvtID==PLAY_EVT_VOD_PLAY_PREPARED){
//            if ([player isPlaying]) {
//
//                int64_t duration = [player duration];
//                NSString *durationStr = [NSString stringWithFormat: @"%ld", (long)duration];
//                NSInteger  durationInt = [durationStr intValue];
//                if(self->_eventSink!=nil){
//                    self->_eventSink(@{
//                        @"event":@"initialized",
//                        @"duration":@(durationInt),
//                        @"width":@([player width]),
//                        @"height":@([player height])
//                    });
//                }
//
//            }
//
//        }else if(EvtID==PLAY_EVT_PLAY_PROGRESS){
//            if ([player isPlaying]) {
//                int64_t progress = [player currentPlaybackTime] * 1000;
//                int64_t duration = [player duration] * 1000;
//                int64_t playableDuration  = [player playableDuration] * 1000;
//
//                if(self->_eventSink!=nil){
//                    self->_eventSink(@{
//                        @"event":@"progress",
//                        @"progress":@(progress),
//                        @"duration":@(duration),
//                        @"playable":@(playableDuration)
//                    });
//                }
//
//            }
//
//        }else if(EvtID==PLAY_EVT_PLAY_LOADING){
//            if(self->_eventSink!=nil){
//                self->_eventSink(@{
//                    @"event":@"loading",
//                });
//            }
//
//        }else if(EvtID==PLAY_EVT_VOD_LOADING_END){
//            if(self->_eventSink!=nil){
//                self->_eventSink(@{
//                    @"event":@"loadingend",
//                });
//            }
//
//        }else if(EvtID==PLAY_EVT_PLAY_END){
//            if(self->_eventSink!=nil){
//
//                if(self->loop) {
//                    self->_eventSink(@{
//                        @"event":@"singlePlayCompleted",
//                    });
////                    [self->_txPlayer seek:(float) 0];
////                    [self->_txPlayer resume];
//                }
//                else {
//                    self->_eventSink(@{
//                        @"event":@"playend",
//                    });
//                }
//
//            }
//
//        }else if(EvtID==PLAY_ERR_NET_DISCONNECT){
//            if(self->_eventSink!=nil){
//                self->_eventSink(@{
//                    @"event":@"error",
//                    @"errorInfo":param[@"EVT_MSG"],
//                });
//
//                self->_eventSink(@{
//                    @"event":@"disconnect",
//                });
//
//            }
//
//        }else if(EvtID==ERR_PLAY_LIVE_STREAM_NET_DISCONNECT){
//            if(self->_eventSink!=nil){
//                self->_eventSink(@{
//                    @"event":@"error",
//                    @"errorInfo":param[@"EVT_MSG"],
//                });
//            }
//        }else if(EvtID==WARNING_LIVE_STREAM_SERVER_RECONNECT){
//            if(self->_eventSink!=nil){
//                self->_eventSink(@{
//                    @"event":@"error",
//                    @"errorInfo":param[@"EVT_MSG"],
//                });
//            }
//        }else {
//            if(EvtID<0){
//                if(self->_eventSink!=nil){
//                    self->_eventSink(@{
//                        @"event":@"error",
//                        @"errorInfo":param[@"EVT_MSG"],
//                    });
//                }
//            }
//        }

//    });
}

//- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary *)param {
//    if(self->_eventSink!=nil){
//        self->_eventSink(@{
//            @"event":@"netStatus",
//            @"netSpeed": param[NET_STATUS_NET_SPEED],
//            @"cacheSize": param[NET_STATUS_V_SUM_CACHE_SIZE],
//        });
//    }
//}

#pragma FlutterStreamHandler
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    NSLog(@"FLTVideo停止通信");
    return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;

    NSLog(@"FLTVideo开启通信");
    //[self sendInitialized];
    return nil;
}

- (void)dispose {
    _disposed = true;
    [self stopPlay];
    [_txPlayer destroy];
    _view = nil;
    _txPlayer = nil;
     NSLog(@"FLTVideo  dispose");
}

-(void)setLoop:(BOOL)loop{
    [_txPlayer setLoop:loop];
    loop = loop;
}

- (void)resume{
    [_txPlayer start];
}
-(void)pause{
    [_txPlayer pause];
}
- (int64_t)position{
    return [_txPlayer currentPosition];
}

- (int64_t)duration{
    return [_txPlayer duration];
}

- (void)seekTo:(int)position{
    [_txPlayer seekToTime:position seekMode:AVP_SEEKMODE_INACCURATE];
}

//- (void)setStartTime:(CGFloat)startTime{
//    [_txPlayer set];
//}

- (void)stopPlay{
    return [_txPlayer stop];
}

- (float)playableDuration{
    return [_txPlayer bufferedPosition];
}

- (int)width{
    return [_txPlayer width];
}

- (int)height{
    return [_txPlayer height];
}

- (void)setRenderMode:(AVPScalingMode)renderMode{
    [_txPlayer setScalingMode:(AVPScalingMode) renderMode];
}

- (void)setRenderRotation:(AVPRotateMode)rotation{

    [_txPlayer setRotateMode:rotation];
}

- (void)setMute:(BOOL)bEnable{
    [_txPlayer setMuted: bEnable];
}


- (void)setRate:(float)rate{
    [_txPlayer setRate:rate];
}
//
- (void)setBitrateIndex:(int)index{
    [_txPlayer selectTrack:index];
}
//
- (void)setMirror:(AVPMirrorMode)isMirror{
    [_txPlayer setMirrorMode:(AVPMirrorMode) isMirror];
}
//截图回调
- (void)onCaptureScreen:(AliPlayer *)player image:(UIImage *)image {
    // 处理截图
}

-(void) startPlay:(NSString *) url {
    AVPUrlSource *urlSoucre = [[AVPUrlSource alloc] urlWithString:url];
    [_txPlayer setUrlSource:urlSoucre];
    _txPlayer.playerView = _view;
    [_txPlayer prepare];
}
@end

