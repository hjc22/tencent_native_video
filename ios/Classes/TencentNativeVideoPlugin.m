#import "TencentNativeVideoPlugin.h"
#import "VideoViewFactory.h"

@implementation TencentNativeVideoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
 VideoViewFactory* videoViewFactory =
       [[VideoViewFactory alloc] initWithMessenger:registrar.messenger];
   [registrar registerViewFactory:videoViewFactory withId:@"plugins.hjc.com/tencentVideo"];
}


@end
