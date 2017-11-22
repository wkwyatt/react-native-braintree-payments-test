//
//  payments.h
//  payments
//
//  Created by Dileep Bolisetti on 11/8/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#ifndef payments_h
#define payments_h


#import <React/RCTBridgeModule.h>
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"

#import "BraintreeCore.h"
#import "BraintreePayPal.h"
#import "BraintreeCard.h"
#import "BraintreeUI.h"


@interface Payments : UIViewController <RCTBridgeModule, BTDropInViewControllerDelegate, BTViewControllerPresentingDelegate>

@property (nonatomic, strong) BTAPIClient *braintreeClient;
@property (nonatomic, strong) UIViewController *reactRoot;

@property (nonatomic, strong) RCTResponseSenderBlock callback;

+ (instancetype)sharedInstance;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
#endif /* payments_h */
