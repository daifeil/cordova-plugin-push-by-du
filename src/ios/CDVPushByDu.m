/********* Echo.m Cordova Plugin Implementation *******/

#import "CDVPushByDu.h"
#import <Cordova/CDVPlugin.h>
#import "BPush.h"
#import "AppDelegate+by_du_push.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


@implementation CDVPushByDu

@synthesize callbackId;

- (void)notificationReceived:(NSDictionary *)userInfo {
    NSLog(@"Notification received");
    
    NSDictionary *notificationMessage = userInfo;
    if (notificationMessage)
    {
        NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:4];
        NSMutableDictionary* additionalData = [NSMutableDictionary dictionaryWithCapacity:4];
        
        
        for (id key in notificationMessage) {
            if ([key isEqualToString:@"aps"]) {
                id aps = [notificationMessage objectForKey:@"aps"];
                
                for(id key in aps) {
                    NSLog(@"Push Plugin key: %@", key);
                    id value = [aps objectForKey:key];
                    
                    if ([key isEqualToString:@"alert"]) {
                        if ([value isKindOfClass:[NSDictionary class]]) {
                            for (id messageKey in value) {
                                id messageValue = [value objectForKey:messageKey];
                                if ([messageKey isEqualToString:@"body"]) {
                                    [message setObject:messageValue forKey:@"message"];
                                } else if ([messageKey isEqualToString:@"title"]) {
                                    [message setObject:messageValue forKey:@"title"];
                                } else {
                                    [additionalData setObject:messageValue forKey:messageKey];
                                }
                            }
                        }
                        else {
                            [message setObject:value forKey:@"message"];
                        }
                    } else if ([key isEqualToString:@"title"]) {
                        [message setObject:value forKey:@"title"];
                    } else if ([key isEqualToString:@"badge"]) {
                        [message setObject:value forKey:@"count"];
                    } else if ([key isEqualToString:@"sound"]) {
                        [message setObject:value forKey:@"sound"];
                    } else if ([key isEqualToString:@"image"]) {
                        [message setObject:value forKey:@"image"];
                    } else {
                        [additionalData setObject:value forKey:key];
                    }
                }
            } else {
                if(!([key length]==0)){
                    [additionalData setObject:[notificationMessage objectForKey:key] forKey:key];
                }
            }
        }
        

        
        [message setObject:additionalData forKey:@"additionalData"];
        
        NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:2];
        [result setObject:message forKey:@"data"];
        [result setObject:@"onMessage" forKey:@"type"];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [pluginResult setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
   
        // NSError* error  = nil;
        // NSData* jsonData = [NSJSONSerialization dataWithJSONObject:message options:0 error:&error];
        // NSString* jsonString = nil;
        
        // if (error == nil) {
        //     jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // }
        
        // NSString* jsString = [NSString stringWithFormat:@"cordova.fireDocumentEvent('CDVRemoteNotification',{'message':%@});", jsonString];
        
        // [self.commandDelegate evalJs:jsString];
        
    }
    

}

- (void)setTag :(CDVInvokedUrlCommand*)command {

    NSString* tagName = [command.arguments objectAtIndex:0];
    
    [BPush setTag:tagName withCompleteHandler:^(id result, NSError *error) {
        CDVPluginResult* pluginResult = nil;
        if (result) {
            NSLog(@"设置tag成功");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)onBind {
    // NSString *channelId = [BPush getChannelId];
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:3];
    [message setObject:[BPush getChannelId] forKey:@"channelId"];
    [message setObject:[BPush getUserId] forKey:@"userId"];
    [message setObject:[BPush getAppId] forKey:@"appId"];
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setObject:message forKey:@"data"];
    [result setObject:@"onBind" forKey:@"type"];
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [pluginResult setKeepCallbackAsBool:TRUE];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];

}

- (void)onMessage:(CDVInvokedUrlCommand*)command
{
    //    [self unBind];
    self.callbackId = command.callbackId;

}

- (void)init:(CDVInvokedUrlCommand*)command
{

    NSString* apiKey = [command.arguments objectAtIndex:0];
    NSString* pushMode = [command.arguments objectAtIndex:1];
    
    NSLog(@"echo============= %@",apiKey);
    NSLog(@"echo============= %@",pushMode);
    
    BPushMode pushModeBool = BPushModeProduction;
    if([pushMode isEqualToString:@"NO"])
        pushModeBool = BPushModeDevelopment;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    
    [BPush registerChannel:appDelegate.launchNotification apiKey: apiKey pushMode:pushModeBool withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:YES isDebug:YES];
    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [appDelegate.launchNotification objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"从消息启动:%@",userInfo);
        [BPush handleNotification:userInfo];
    }
    //bind BaiduPush key end ===========
    UIApplication *application = [UIApplication sharedApplication];
    
    
    // iOS10 下需要使用新的 API    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                                  if (granted) {
                                      [application registerForRemoteNotifications];
                                  }
                              }];
#endif
    }
    else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
}

-(void) unBind:(CDVInvokedUrlCommand *)command
{
    [BPush unbindChannelWithCompleteHandler:^(id result, NSError *error) {
        
        NSLog(@"in unbindChannel");
    }];
}

- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command
{
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    int badge = [[options objectForKey:@"badge"] intValue] ?: 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
    
    NSString* message = [NSString stringWithFormat:@"app badge count set to %d", badge];
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}

- (void)getApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command
{
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)badge];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}


/*!
 @method
 @abstract 设置Tag
 */
- (void)setTags:(CDVInvokedUrlCommand*)command{
    NSLog(@"设置Tag");
    NSString *tagsString = command.arguments[0];
    
    CDVPluginResult* pluginResult = nil;
    
    if (![self checkTagString:tagsString]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@","];
    if (tags) {
        [BPush setTags:tags withCompleteHandler:^(id result, NSError *error) {
            CDVPluginResult* pluginResult = nil;
            // 设置多个标签组的返回值
            if ([self returnBaiduResult:result])
            {
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

/*!
 @method
 @abstract 删除Tag
 */
- (void)delTags:(CDVInvokedUrlCommand*)command{
    NSLog(@"删除Tag");
    CDVPluginResult* pluginResult = nil;
    NSString *tagsString = command.arguments[0];
    if (![self checkTagString:tagsString]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@","];
    if (tags) {
        [BPush delTags:tags withCompleteHandler:^(id result, NSError *error) {
            // 删除标签的返回值
            CDVPluginResult* pluginResult = nil;
            if ([self returnBaiduResult:result])
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

- (BOOL)checkTagString:(NSString *)tagStr {
    NSString *str = [tagStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    if ([str isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)returnBaiduResult:(id)result{
    NSString *resultStr = result[@"error_code"];
    if (!resultStr || [[resultStr description] isEqualToString:@"0"]){
        return YES;
    }
    return NO;
}

@end
