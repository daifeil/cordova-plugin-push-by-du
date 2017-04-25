//
//  AppDelegate+by_du_push.m
//  byDuPush
//
//  Created by zhiguo.du on 22/12/2016.
//
//

#import "AppDelegate+by_du_push.h"
#import <objc/runtime.h>
#import "CDVPushByDu.h"


#define PushEnable ;
@implementation AppDelegate (by_du_push)

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

- (NSString *)channelId {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setChannelId:(NSString *)channelId_retain {
    objc_setAssociatedObject(self, @selector(channelId), channelId_retain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (NSString *)userId {
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//- (void)setUserId:(NSString *)userId {
//    objc_setAssociatedObject(self, @selector(userId), userId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (NSString *)apiKey {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setApiKey:(NSString *)apiKey {
    objc_setAssociatedObject(self, @selector(apiKey), apiKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (NSString *)pushMode {
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//- (void)setPushMode:(NSString *)pushMode {
//    objc_setAssociatedObject(self, @selector(pushMode), pushMode, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}


- (NSString *)launchNotification {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLaunchNotification:(NSString *)launchNotification {
    objc_setAssociatedObject(self, @selector(launchNotification), launchNotification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)coldstart {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setColdstart:(NSString *)coldstart {
    objc_setAssociatedObject(self, @selector(coldstart), coldstart, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    self.launchNotification = nil; // clear the association and release the object
    self.coldstart = nil;
//    self.appId = nil;
    self.channelId = nil;
    self.apiKey = nil;
//    self.coldstart = nil;
}

//static char channelId;

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load
{
    static dispatch_once_t onceTokenByDu;
    dispatch_once(&onceTokenByDu, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(byDuPushPluginSwizzledInit);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
}

- (AppDelegate *)byDuPushPluginSwizzledInit
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BPushConfig" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    self.apiKey = plistData[@"API_KEY"];
    BOOL pushM = [plistData[@"PRODUCTION_MODE"] boolValue];
    
//    self.pushMode = [NSNumber numberWithBool: pushM];
    
//    if(pushM == YES){
//        self.pushMode = BPushModeProduction;
//    }else{
//        self.pushMode = BPushModeDevelopment;
//    }
//    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createNotificationCheckerByDu:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(pushPluginOnApplicationDidBecomeActive:)
//                                                name:UIApplicationDidBecomeActiveNotification
//                                              object:nil];
    
    // This actually calls the original init method over in AppDelegate. Equivilent to calling super
    // on an overrided method, this is not recursive, although it appears that way. neat huh?
    return [self byDuPushPluginSwizzledInit];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
// to process notifications in cold-start situations
- (void)createNotificationCheckerByDu:(NSNotification *)notification
{
    NSLog(@"createNotificationChecker");
    if (notification)
    {
        NSDictionary *launchOptions = [notification userInfo];
        self.launchNotification = launchOptions;
    }
}

#ifdef PushEnable

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"#### didRegisterForRemoteNotificationsWithDeviceToken");
    NSLog(@"deviceToken: %@", deviceToken);
    
    [BPush registerDeviceToken:deviceToken];
    
    // [self unBind];
    [self bindBaiduPush];
    
//    CDVPushByDu *pushHandler = [self getCommandInstance:@"PushByDu"];
//    [pushHandler notificationReceived];

    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error in registration. Error: %@", error );
//    [self performSelector:@selector(delayMethod:) withObject:application afterDelay:3.0f];
}

//- (void)delayMethod:(UIApplication *)application  {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//    {
//        [application registerUserNotificationSettings:[UIUserNotificationSettings
//                                                       settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//        [application registerForRemoteNotifications];
//    }
//    else
//    {
//        [application registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
//    }
//}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //added 01-04-16
    // App 收到推送的通知
    [BPush handleNotification:userInfo];
//    NSLog(@"********** ios7.0之前 **********");
    
//    [self appdelegate:application didReceiveRemoteNotification:userInfo];
    
    CDVPushByDu *pushHandler = [self getCommandInstance:@"PushByDu"];
    [pushHandler notificationReceived:userInfo];
    
}

// 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台 时调起
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    CDVPushByDu *pushHandler = [self getCommandInstance:@"PushByDu"];
    [pushHandler notificationReceived:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
}

//bind bai du push

- (void)bindBaiduPush
{
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        //        [self.viewController addLogString:[NSString stringWithFormat:@"Method: %@\n%@",BPushRequestMethodBind,result]];
        // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
        if (result) {

            NSLog(@"Debug: set Channel id!");
            //            NSLog(@"On method:%@", method);
            //            NSLog(@"data:%@", [data description]);
            //            NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
            ////            if ([BPushRequestMethod_Bind isEqualToString:method]) {
            NSString *appid = [BPush getAppId];
            NSString *userid = [BPush getUserId];
            NSString *channelid = [BPush getChannelId];
            NSString *requestid = result;
            NSLog(@"appid:%@",appid);
            NSLog(@"userid:%@",userid);
            NSLog(@"requestid:%@",requestid);
            
            NSLog(@"channelid:%@",channelid);

            CDVPushByDu *pushHandler = [self getCommandInstance:@"PushByDu"];
            [pushHandler onBind];

        }
        
    }];
}


#endif
@end
