//
//  AppDelegate+by_du_push.h
//  byDuPush
//
//  Created by zhiguo.du on 22/12/2016.
//
//

#import "AppDelegate.h"
#import "BPush.h"

@interface AppDelegate (by_du_push)

//@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSString *channelId;
//@property (nonatomic, retain) NSString *userId;

//@property (nonatomic, retain) NSString *apiKey;

//@property (nonatomic, retain) BOOL alertIsShowing;

//@property (nonatomic, retain) NSNumber *pushMode;

@property (nonatomic, retain) NSDictionary  *launchNotification;
@property (nonatomic, retain) NSNumber  *coldstart;


@end
