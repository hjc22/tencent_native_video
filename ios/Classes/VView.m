
#import "VVIew.h"
#import <UIKit/UIKit.h>






@implementation VView {
    ViewLayoutSubviews _callback;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
//        [self initWithFrame:frame];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"21441");
    if(_callback != nil) {
        _callback();
    }
}

- (void) addLayoutEvent: (ViewLayoutSubviews) callback {
    
    NSLog(@"77777");
    _callback = callback;
}

@end
