
#import <Flutter/Flutter.h>


@interface VideoView : NSObject <FlutterPlatformView>

- (instancetype _Nonnull )initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                        binaryMessenger:(NSObject<FlutterBinaryMessenger>*_Nonnull)messenger;

- (UIView*_Nonnull)view;
@end
