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
    TXVodPlayConfig* playConfig = [[TXVodPlayConfig alloc]init];
    
    playConfig.playerType = PLAYER_AVPLAYER;
    playConfig.connectRetryCount=  3 ;
    playConfig.connectRetryInterval = 3;
    playConfig.timeout = 10 ;

    id headers = argsMap[@"headers"];
    if (headers!=nil&&headers!=NULL&&![@"" isEqualToString:headers]&&headers!=[NSNull null]) {
        NSDictionary* headers =  argsMap[@"headers"];
        playConfig.headers = headers;
    }

    BOOL isCache = argsMap[@"isCache"];
    if (isCache) {
        // 设置缓存路径
        playConfig.cacheFolderPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        playConfig.maxCacheItems = 10;
    }

    playConfig.progressInterval =  1;
    
    BOOL autoPlayArg = [argsMap[@"autoPlay"] boolValue];
    BOOL loop = [argsMap[@"loop"] boolValue];
    
    
    
//    NSString *a;
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:argsMap options:NSJSONWritingPrettyPrinted error:&error];
//    if (!jsonData) {
//        a =  @"{}";
//    } else {
//        a=  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//    
    
    

    if(autoPlayArg == nil || autoPlayArg == NULL) {
        autoPlayArg = true;
    }
    
    if(loop == nil || loop == NULL) {
        loop = false;
    }
    
    float startPosition=0;

    id startTime = argsMap[@"startTime"];
    if(startTime!=nil&&startTime!=NULL&&![@"" isEqualToString:startTime]&&startTime!=[NSNull null]){
        startPosition =[argsMap[@"startTime"] floatValue];
    }


    _txPlayer = [[TXVodPlayer alloc]init];

    [_txPlayer setConfig:playConfig];
    [_txPlayer setIsAutoPlay:autoPlayArg];
    _txPlayer.enableHWAcceleration = YES;
    [_txPlayer setVodDelegate:self];
    [_txPlayer setVideoProcessDelegate:self];
    [_txPlayer setStartTime:startPosition];
    
    NSLog(@" json----%@", argsMap[@"loop"]);
    
    NSLog(@" json----%i", loop);
    
    [_txPlayer setLoop:(BOOL) loop];
    

//    id  pathArg = argsMap[@"uri"];
//    if(pathArg!=nil&&pathArg!=NULL&&![@"" isEqualToString:pathArg]&&pathArg!=[NSNull null]){
//        NSLog(@"播放器启动方式1  play");
//        [_txPlayer startPlay:pathArg];
//    }
    
    NSLog(@"播放器初始化结束");


    return  self;

}






/**
 * 点播事件通知
 *
 * @param player 点播对象
 * @param EvtID 参见TXLiveSDKEventDef.h
 * @param param 参见TXLiveSDKTypeDef.h
 * @see TXVodPlayer
 */
-(void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param{

    dispatch_async(dispatch_get_main_queue(), ^{

        if(EvtID==PLAY_EVT_VOD_PLAY_PREPARED){
            if ([player isPlaying]) {

                int64_t duration = [player duration];
                NSString *durationStr = [NSString stringWithFormat: @"%ld", (long)duration];
                NSInteger  durationInt = [durationStr intValue];
                if(self->_eventSink!=nil){
                    self->_eventSink(@{
                        @"event":@"initialized",
                        @"duration":@(durationInt),
                        @"width":@([player width]),
                        @"height":@([player height])
                    });
                }

            }

        }else if(EvtID==PLAY_EVT_PLAY_PROGRESS){
            if ([player isPlaying]) {
                int64_t progress = [player currentPlaybackTime];
                int64_t duration = [player duration];
                int64_t playableDuration  = [player playableDuration];


                NSString *progressStr = [NSString stringWithFormat: @"%ld", (long)progress];
                NSString *durationStr = [NSString stringWithFormat: @"%ld", (long)duration];
                NSString *playableDurationStr = [NSString stringWithFormat: @"%ld", (long)playableDuration];
                NSInteger  progressInt = [progressStr intValue]*1000;
                NSInteger  durationint = [durationStr intValue]*1000;
                NSInteger  playableDurationInt = [playableDurationStr intValue]*1000;
                //                NSLog(@"单精度浮点数： %d",progressInt);
                //                NSLog(@"单精度浮点数： %d",durationint);
                if(self->_eventSink!=nil){
                    self->_eventSink(@{
                        @"event":@"progress",
                        @"progress":@(progressInt),
                        @"duration":@(durationint),
                        @"playable":@(playableDurationInt)
                    });
                }

            }

        }else if(EvtID==PLAY_EVT_PLAY_LOADING){
            if(self->_eventSink!=nil){
                self->_eventSink(@{
                    @"event":@"loading",
                });
            }

        }else if(EvtID==PLAY_EVT_VOD_LOADING_END){
            if(self->_eventSink!=nil){
                self->_eventSink(@{
                    @"event":@"loadingend",
                });
            }

        }else if(EvtID==PLAY_EVT_PLAY_END){
            if(self->_eventSink!=nil){
                self->_eventSink(@{
                    @"event":@"playend",
                });
            }

        }else if(EvtID==PLAY_ERR_NET_DISCONNECT){
            if(self->_eventSink!=nil){
                self->_eventSink(@{
                    @"event":@"error",
                    @"errorInfo":param[@"EVT_MSG"],
                });

                self->_eventSink(@{
                    @"event":@"disconnect",
                });

            }

        }else if(EvtID==ERR_PLAY_LIVE_STREAM_NET_DISCONNECT){
            if(self->_eventSink!=nil){
                self->_eventSink(@{
                    @"event":@"error",
                    @"errorInfo":param[@"EVT_MSG"],
                });
            }
        }else if(EvtID==WARNING_LIVE_STREAM_SERVER_RECONNECT){
            if(self->_eventSink!=nil){
                self->_eventSink(@{
                    @"event":@"error",
                    @"errorInfo":param[@"EVT_MSG"],
                });
            }
        }else {
            if(EvtID<0){
                if(self->_eventSink!=nil){
                    self->_eventSink(@{
                        @"event":@"error",
                        @"errorInfo":param[@"EVT_MSG"],
                    });
                }
            }
        }

    });
}

- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary *)param {
    if(self->_eventSink!=nil){
        self->_eventSink(@{
            @"event":@"netStatus",
            @"netSpeed": param[NET_STATUS_NET_SPEED],
            @"cacheSize": param[NET_STATUS_V_SUM_CACHE_SIZE],
        });
    }
}

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
    [_txPlayer removeVideoWidget];
    _view = nil;
    _txPlayer = nil;
     NSLog(@"FLTVideo  dispose");
}

-(void)setLoop:(BOOL)loop{
    [_txPlayer setLoop:loop];
    _loop = loop;
}

- (void)resume{
    [_txPlayer resume];
}
-(void)pause{
    [_txPlayer pause];
}
- (int64_t)position{
    return [_txPlayer currentPlaybackTime];
}

- (int64_t)duration{
    return [_txPlayer duration];
}

- (void)seekTo:(int)position{
    [_txPlayer seek:position];
}

- (void)setStartTime:(CGFloat)startTime{
    [_txPlayer setStartTime:startTime];
}

- (int)stopPlay{
    return [_txPlayer stopPlay];
}

- (float)playableDuration{
    return [_txPlayer playableDuration];
}

- (int)width{
    return [_txPlayer width];
}

- (int)height{
    return [_txPlayer height];
}

- (void)setRenderMode:(TX_Enum_Type_RenderMode)renderMode{
    [_txPlayer setRenderMode:renderMode];
}

- (void)setRenderRotation:(TX_Enum_Type_HomeOrientation)rotation{

    [_txPlayer setRenderRotation:rotation];
}

- (void)setMute:(BOOL)bEnable{
    [_txPlayer setMute:bEnable];
}




- (void)setRate:(float)rate{
    [_txPlayer setRate:rate];
}

- (void)setBitrateIndex:(int)index{
    [_txPlayer setBitrateIndex:index];
}

- (void)setMirror:(BOOL)isMirror{
    [_txPlayer setMirror:isMirror];
}

-(void)snapshot:(void (^)(UIImage * _Nonnull))snapshotCompletionBlock{

}
-(void) removeVideoWidget {
    [_txPlayer removeVideoWidget];
}

-(void) startPlay:(NSString *) url {
    [_txPlayer startPlay:url];
    [_txPlayer setupVideoWidget: _view insertIndex:0];
}
@end

