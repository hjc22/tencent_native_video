



#import <UIKit/UIKit.h>

typedef void(^ViewLayoutSubviews)(void);

@interface VView : UIView

- (instancetype _Nonnull )initWithFrame:(CGRect)frame;

- layoutSubviews;

- (void) addLayoutEvent: (ViewLayoutSubviews) callback;
@end

