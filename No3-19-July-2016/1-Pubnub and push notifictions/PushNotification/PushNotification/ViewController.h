//
//  ViewController.h
//  PushNotification
//
//  Created by Andrija Milovanovic on 5/13/16.
//  Copyright © 2016 Endava. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

-(void) messageReceived:(NSString*) message;
-(void) registerToken:(NSString*) token;

@end

