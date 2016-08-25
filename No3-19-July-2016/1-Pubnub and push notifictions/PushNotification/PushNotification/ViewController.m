//
//  ViewController.m
//  PushNotification
//
//  Created by Andrija Milovanovic on 5/13/16.
//  Copyright © 2016 Endava. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *receivedMessage;

@property (weak, nonatomic) IBOutlet UITextView *sendMessage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) getFormatedMessage:(NSString*)message
{
    NSDictionary* dict = @{@"msg": message,
                           @"pn_apns" : @{
                                   @"aps" : @{
                                       @"alert" : @{
                                               @"title" : @"andrija",
                                               @"body"  : message
                                               },
                                       @"badge" : @1,
                                       @"summary_for_mobile" : @"Push notifcation from andrija"
                                    }
                                },
                            @"pn_debug" : @true
                            };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (IBAction)onSendMessage:(id)sender {
    
    NSString* channel = @"push_testing1";
    NSString* pub_key = @"pub-c-02685f6c-349a-4cbb-b7d6-90dc8ded7889";
    NSString* sub_key = @"sub-c-9373c8de-18ec-11e6-9f24-02ee2ddab7fe";
    NSString* message = [self getFormatedMessage:self.sendMessage.text ];
    NSString* url = [NSString stringWithFormat:@"http://pubsub.pubnub.com/publish/%@/%@/0/%@/0", pub_key, sub_key, channel];
    
    [self makeRestAPICall:url postBody:message];
}

-(void) registerToken:(NSString*) token
{
    NSString* channel = @"push_testing1"; //comma separated channels
    NSString* sub_key = @"sub-c-9373c8de-18ec-11e6-9f24-02ee2ddab7fe";
    NSString* url = [NSString stringWithFormat:@"http://pubsub.pubnub.com/v1/push/sub-key/%@/devices/%@?add=%@&type=apns", sub_key, token, channel];
    
    
    [self makeRestAPICall:url postBody:nil];
}



-(void) messageReceived:(NSString*) message
{
    [self printMessage:message];
}
-(void) printMessage:(NSString*) message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _receivedMessage.text = [_receivedMessage.text stringByAppendingString:@"\n"];
        _receivedMessage.text = [_receivedMessage.text stringByAppendingString:message];
    });
}


-(void) makeRestAPICall : (NSString*) reqURLStr postBody:(NSString*) post
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
                                                                 delegate: nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:reqURLStr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    if( post.length > 0 ) {
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            if(error == nil && data != nil) {
                                                                [self printMessage:[NSString stringWithFormat:@"Send:%@",  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
                                                            } else  if(error == nil ) {
                                                                [self printMessage:@"error"];
                                                            }
                                                        }];
    [dataTask resume];
}



@end
