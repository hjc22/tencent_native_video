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

    BOOL isCache = [argsMap[@"isCache"] boolValue];
    
    BOOL isLoop = [argsMap[@"loop"] boolValue];
    
    loop = isLoop;
    
    
    NSLog(@" json----%i", argsMap[@"isCache"]);

    NSLog(@" json----%i", isCache);
    
    if (isCache) {
        // 设置缓存路径
        playConfig.cacheFolderPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        playConfig.maxCacheItems = 20;
    }

    playConfig.progressInterval =  0.5;
    
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


    _txPlayer = [[TXVodPlayer alloc]init];

    [_txPlayer setConfig:playConfig];
    [_txPlayer setIsAutoPlay:autoPlayArg];
    _txPlayer.enableHWAcceleration = YES;
    [_txPlayer setVodDelegate:self];
    [_txPlayer setVideoProcessDelegate:self];
    [_txPlayer setStartTime:startPosition];
    
//    [_txPlayer setLoop:(BOOL) loop];

    NSLog(@"播放器初始化结束");

    return self;

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
                int64_t progress = [player currentPlaybackTime] * 1000;
                int64_t duration = [player duration] * 1000;
                int64_t playableDuration  = [player playableDuration] * 1000;
                
                if(self->_eventSink!=nil){
                    self->_eventSink(@{
                        @"event":@"progress",
                        @"progress":@(progress),
                        @"duration":@(duration),
                        @"playable":@(playableDuration)
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
                
                if(self->loop) {
                    self->_eventSink(@{
                        @"event":@"singlePlayCompleted",
                    });
                    [self->_txPlayer seek:(float) 0];
                    [self->_txPlayer resume];
                }
                else {
                    self->_eventSink(@{
                        @"event":@"playend",
                    });
                }
                
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
    loop = loop;
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

