/********* Echo.h Cordova Plugin Header *******/

#import <Cordova/CDVPlugin.h>

@interface CDVPushByDu : CDVPlugin


- (void)init:(CDVInvokedUrlCommand*)command;
- (void) unBind:(CDVInvokedUrlCommand *)command;

//send message to javascript
- (void)notificationReceived:(NSDictionary *)userInfo;
//set global call back
- (void)onMessage:(CDVInvokedUrlCommand*)command;

//send onBind Message to javascript

- (void)onBind;
- (void)setTags:(CDVInvokedUrlCommand*)command;
- (void)delTags:(CDVInvokedUrlCommand*)command;

- (void)getApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command;
- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command;

@property (nonatomic, copy) NSString *callbackId;


@end
