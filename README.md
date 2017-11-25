# react-native-braintree-payments-test
react-native-braintree-payments test implementation


use tokenization key from braintree...


google service file from sample google project

## For iOS

To use PayPal payment button in the DropIn component 

### Register a URL type
1. In Xcode, click on your project in the Project Navigator and navigate to App Target > Info > URL Types

2. Click [+] to add a new URL type
3. Under URL Schemes, enter your app switch return URL scheme. This scheme must start with your app's Bundle ID and be dedicated to Braintree app switch returns. For example, if the app bundle ID is com.your-company.Your-App, then your URL scheme could be com.your-company.Your-App.payments.

##### IMPORTANT
If you have multiple app targets, be sure to add the return URL type for all of the targets.


###Update `AppDelegate.m` file in XCode 

##### NOTE: 
REPLACE `com.your-company.Your-App.payments` with `your-bundle-ID.payments`

```objc

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // ...(any other code)

  [BTAppSwitch setReturnURLScheme:@"com.your-company.Your-App.payments"];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  if ([url.scheme localizedCaseInsensitiveCompare:@"com.your-company.Your-App.payments"] == NSOrderedSame) {
    return [BTAppSwitch handleOpenURL:url options:options];
  }
  return NO;
}

// If you support iOS 7 or 8, add the following method.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  if ([url.scheme localizedCaseInsensitiveCompare:@"com.your-company.Your-App.payments"] == NSOrderedSame) {
    return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
  }
  return NO;
}

```
