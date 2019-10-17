#import "FirebaseAuthUiPlugin.h"
#import <firebase_auth_ui/firebase_auth_ui-Swift.h>

@implementation FirebaseAuthUiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFirebaseAuthUiPlugin registerWithRegistrar:registrar];
}
@end
