//
//  payments.m
//  payments
//
//  Created by Dileep Bolisetti on 11/8/17.
//  Copyright © 2017 Facebook. All rights reserved.
//
#import "payments.h"
#import <Foundation/Foundation.h>

@implementation Payments

@synthesize methodQueue = _methodQueue;
typedef void (^ Block)(id, int);
- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}
static NSString *URLScheme;
NSString *authorizationToken;

+ (instancetype)sharedInstance {
  static Payments *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[Payments alloc] init];
  });
  return _sharedInstance;
}

// To export a module named CalendarManager
RCT_EXPORT_MODULE();
//-(instancetype)init{
//  self = [super init];
//  if (self) {
//    [AWSServiceConfiguration
//     addGlobalUserAgentProductToken:[NSString stringWithFormat:@"react-native-kickass-component/0.0.1"]];
//  }
//  return self;
//}
RCT_EXPORT_METHOD(concatStr:(NSString *)string1
                  secondString:(NSString *)string2
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  resolve([NSString stringWithFormat:@"%@ %@", string1, string2]);
}
// This would name the module AwesomeCalendarManager instead
// RCT_EXPORT_MODULE(AwesomeCalendarManager);
RCT_EXPORT_METHOD(setupWithURLScheme:(NSString *)clientToken urlscheme:(NSString*)urlscheme callback:(RCTResponseSenderBlock)callback)
{
  URLScheme = urlscheme;
  [BTAppSwitch setReturnURLScheme:urlscheme];
  self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
  if (self.braintreeClient == nil) {
    callback(@[@false]);
  }
  else {
    authorizationToken = clientToken;
    callback(@[@true]);
  }
}

RCT_EXPORT_METHOD(init:(NSString *)clientToken resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
  if (self.braintreeClient == nil) {
    reject(@"error", @"There was an initialization error", false);
  }
  else {
    authorizationToken = clientToken;
    resolve(@true);
  }
}

RCT_EXPORT_METHOD(showPaymentViewController:(RCTResponseSenderBlock)callback)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithAPIClient:self.braintreeClient];
    dropInViewController.delegate = self;
    
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(userDidCancelPayment)];
    
    self.callback = callback;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    
    self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [self.reactRoot presentViewController:navigationController animated:YES completion:nil];
  });
}

RCT_EXPORT_METHOD(showDropIn:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSLog(@"DropIn Pressed");
  BTDropInRequest *request = [[BTDropInRequest alloc] init];
  
  BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:authorizationToken request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
    
    if (error) {
      NSLog(@"ERROR");
      reject(@"error", @"There was a processing error", error);
    } else if (result.cancelled) {
      NSLog(@"CANCELLED");
      resolve(@"User cancelled payment");
    } else {
      resolve(result.paymentMethod.nonce);
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
  }];
  self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  [self.reactRoot presentViewController:dropIn animated:YES completion:nil];
}





RCT_EXPORT_METHOD(showPayPalViewController:(RCTResponseSenderBlock)callback)
{
  dispatch_async(dispatch_get_main_queue(), ^{
    
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.braintreeClient];
    payPalDriver.viewControllerPresentingDelegate = self;
    
    [payPalDriver authorizeAccountWithCompletion:^(BTPayPalAccountNonce *tokenizedPayPalAccount, NSError *error) {
      NSArray *args = @[];
      if ( error == nil ) {
        args = @[[NSNull null], tokenizedPayPalAccount.nonce];
      } else {
        args = @[error.description, [NSNull null]];
      }
      callback(args);
    }];
  });
}
RCT_EXPORT_METHOD(getCardNonce: (NSString *)cardNumber
                  expirationMonth: (NSString *)expirationMonth
                  expirationYear: (NSString *)expirationYear
                  callback: (RCTResponseSenderBlock)callback
                  )
{
  BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient: self.braintreeClient];
  BTCard *card = [[BTCard alloc] initWithNumber:cardNumber expirationMonth:expirationMonth expirationYear:expirationYear cvv:nil];
  
  [cardClient tokenizeCard:card
                completion:^(BTCardNonce *tokenizedCard, NSError *error) {
                  
                  NSArray *args = @[];
                  if ( error == nil ) {
                    args = @[[NSNull null], tokenizedCard.nonce];
                  } else {
                    args = @[error.description, [NSNull null]];
                  }
                  callback(args);
                }
   ];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  if ([url.scheme localizedCaseInsensitiveCompare:URLScheme] == NSOrderedSame) {
    return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
  }
  return NO;
}

#pragma mark - BTViewControllerPresentingDelegate

- (void)paymentDriver:(id)paymentDriver requestsPresentationOfViewController:(UIViewController *)viewController {
  self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  [self.reactRoot presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(id)paymentDriver requestsDismissalOfViewController:(UIViewController *)viewController {
  self.reactRoot = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  [self.reactRoot dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTDropInViewControllerDelegate

- (void)userDidCancelPayment {
  [self.reactRoot dismissViewControllerAnimated:YES completion:nil];
  self.callback(@[@"User cancelled payment", [NSNull null]]);
}

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce {
  
  self.callback(@[[NSNull null],paymentMethodNonce.nonce]);
  [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
  [viewController dismissViewControllerAnimated:YES completion:nil];
  self.callback(@[@"Drop-In ViewController Closed", [NSNull null]]);
}
@end
