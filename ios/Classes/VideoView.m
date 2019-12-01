
#import "VideoView.h"
#import "VVIew.h"
#import <TXLiteAVSDK_Player/TXLiteAVSDK.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoPlayer.h"

@interface VideoView ()
@property(readonly, nonatomic) NSMutableDictionary* players;
@end

@implementation VideoView {

  int64_t _viewId;
  FlutterMethodChannel* _channel;
  VView * _videoView;
  NSURL * _videoUrl;
  VideoPlayer *_txVodPlayer;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if (self = [super init]) {
    _viewId = viewId;
    _videoView = [[VView alloc] initWithFrame: frame];
      
      NSDictionary *dic = args;
      
      _txVodPlayer = [[VideoPlayer alloc] initWithCall:dic
                                                viewId: (int64_t *) viewId
                                                view: (VView*) self.view
                                             messenger:messenger ];
      
    
    NSString* channelName = [NSString stringWithFormat:@"plugins.hjc.com/tencentVideo_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];

    __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
          [weakSelf onMethodCall:call result:result];
        }];
  }
  return self;
}


- (UIView*)view {
  return _videoView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"loadUrl"]) {
    [self onLoadUrl:call result:result];
  } else if ([[call method] isEqualToString:@"dispose"]) {
      [self dispose:call result:result];
      result(nil);
  } else if ([[call method] isEqualToString:@"pause"]) {
      [_txVodPlayer pause];
      result(nil);
  } else if ([[call method] isEqualToString:@"play"]) {
      [_txVodPlayer resume];
      result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onLoadUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args = [call arguments];
    
    NSString *url = [args valueForKey: @"url"];

    @try {
        [_txVodPlayer startPlay: url ];
        
        
    } @catch (NSException *exception) {
    } @finally {
        
    }
    
}

- (void)dispose:(FlutterMethodCall*)call result:(FlutterResult)result {
    _videoView = nil;
    [_videoView removeFromSuperview];
    [_videoView setHidden: true];
    [_channel setMethodCallHandler:nil];
    [_txVodPlayer dispose];
    
    
    result(nil);
}

- (bool)loadUrl{
  return true;
}


@end


