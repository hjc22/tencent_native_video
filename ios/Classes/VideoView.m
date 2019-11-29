
#import "VideoView.h"
#import "VVIew.h"
#import <TXLiteAVSDK_Player/TXLiteAVSDK.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface VideoView ()
@property(readonly, nonatomic) NSMutableDictionary* players;
@end

@implementation VideoView {

  int64_t _viewId;
  FlutterMethodChannel* _channel;
  VView * _videoView;
    NSURL * _videoUrl;
    
    TXVodPlayer *_txVodPlayer;
    
    
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if (self = [super init]) {
    _viewId = viewId;
    _videoView = [[VView alloc] initWithFrame: frame];
      _videoView.frame = _videoView.bounds;
      

      [_videoView addLayoutEvent: ^() {
          NSLog(@"88888");
          
//          if(_videoUrl != nil && _playModel == nil) {
//              [self loadUrl];
//          }
      }];
      
      
      
//    _videoView.contentMode = UIViewContentModeScaleAspectFit;
      
//    _videoView.frame = CGRectMake(0, 0, 200, 200);
      
      NSLog(@"frame--- %f", frame.size.width);
      NSLog(@"frame--- %f", frame.size.height);
      NSLog(@"frame--- %f", frame.origin.x);
      NSLog(@"frame--- %f", frame.origin.y);
      
      NSLog(@"frame--- %f", _videoView.bounds.size.width);
      NSLog(@"frame--- %f", _videoView.bounds.size.height);
      NSLog(@"frame--- %f", _videoView.bounds.origin.x);
      NSLog(@"frame--- %f", _videoView.bounds.origin.y);
      
      _txVodPlayer = [[TXVodPlayer alloc] init];
      [_txVodPlayer setupVideoWidget:_videoView insertIndex:0];
      TXVodPlayConfig* playConfig = [[TXVodPlayConfig alloc]init];
      
      playConfig.playerType = PLAYER_AVPLAYER;
      [_txVodPlayer setLoop: true];
      [_txVodPlayer setConfig:playConfig];
      
//    _videoView.backgroundColor = [UIColor yellowColor];
    NSDictionary *dic = args;
    
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
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onLoadUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary* args = [call arguments];
    
    NSString *url = [args valueForKey: @"url"];

//    NSURL* nsUrl = [NSURL URLWithString:[args valueForKey: @"url"]];
    
//    _videoUrl = url;
    
     NSLog(@"-22-- %@", url);
    
    [_txVodPlayer startPlay: url ];
}

- (void)dispose:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    
//    NSString* _currentViewId = [call arguments];
//    [_players[_currentViewId]  stopPlay];
//
//    [_players removeObjectForKey:_currentViewId];
//
//    [_videoView removeFromSuperview];
    [_txVodPlayer stopPlay];
    [_txVodPlayer removeVideoWidget];
    [_channel setMethodCallHandler:nil];
    result(nil);
}

- (bool)loadUrl{
    
    
    

    
//    _videoView.jp_videoPlayerDelegate = self;
//  [_videoView jp_playVideoWithURL:_videoUrl
//                           options:kNilOptions
//                            configuration:^(UIView *view, JPVideoPlayerModel *playerModel) {
//      self->_playModel = playerModel;
//
//      _players[@(_viewId)] = playerModel;
//
////      _videoView.frame = _videoView.bounds;
////      playerModel.playerLayer.frame = _videoView.bounds;
////      [_videoView setNeedsDisplay];
////      [playerModel.playerLayer setNeedsDisplay];
////      playerModel.playerLayer.contentsRect = _videoView.frame;
////      NSLog(@"22---- %f", _videoView.bounds.size.width);
////               NSLog(@"-22-- %f", _videoView.frame.size.height);
////
//      playerModel.playerLayer.contentsGravity = AVLayerVideoGravityResize;
//      playerModel.playerLayer.videoGravity = AVLayerVideoGravityResize; // self.muteSwitch.on = ![self.videoContainer jp_muted];
//                                                                 }];
  return true;
}

#pragma mark - JPVideoPlayerDelegate

- (BOOL)shouldAutoReplayForURL:(nonnull NSURL *)videoURL {
    return true;
}
//


@end

