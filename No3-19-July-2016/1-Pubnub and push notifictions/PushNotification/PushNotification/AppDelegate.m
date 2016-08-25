//
//  AppDelegate.m
//  PushNotification
//
//  Created by Andrija Milovanovic on 5/13/16.
//  Copyright © 2016 Endava. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self registerForPushNotification: application];
    return YES;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;

    if (application.applicationState == UIApplicationStateActive)
    {
        NSString* alert = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
        
        ViewController* rvc = (ViewController*)application.keyWindow.rootViewController;
        [rvc messageReceived:[NSString stringWithFormat:@"NOTIFICATION:%@", alert]];

    }    
}

-(void) registerForPushNotification:(UIApplication*) application
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
-(void)application:(UIApplication *) application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    ViewController* rvc = (ViewController*)application.keyWindow.rootViewController;
    [rvc registerToken:token];
}

-(void)application:(UIApplication *) application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings
{
     [application registerForRemoteNotifications];

}

@end
