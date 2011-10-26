Getting Started
=========
1. Clone the repository from GitHub
`git clone git://github.com/stackmob/StackMob_iOS.git`
2. Open the Demo project.
3. Drag the 'StackMob' folder from the Demo project into your app's project
4. Add the following Frameworks to your project:

    - CFNetwork.framework
    - CoreLocation.framework
    - SystemConfiguration.framework

5. Edit 'StackMobConfiguration.h' to include your app's account and app info

```objective-c
#define STACKMOB_PUBLIC_KEY         @""
#define STACKMOB_PRIVATE_KEY        @""
#define STACKMOB_APP_NAME           @""
#define STACKMOB_APP_SUBDOMAIN      @""
#define STACKMOB_APP_DOMAIN         @"" // most likely 'stackmob.com'
#define STACKMOB_USER_OBJECT_NAME   @"" // most likely 'user' or 'account'
#define STACKMOB_API_VERSION        0   // 0 for sandbox, 1 for production
```

6. ```#import "Stackmob.h"``` in any classes that interact with Stackmob.


Coding
=====
You can now make requests to your servers on StackMob using the following patterns.

####GET

```objective-c
 /*
   * dictionary: 
   * NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
   * [dictionary setValue:userName forKey:kAttributeUserUserName];
   */
[[StackMob stackmob] get:@"account" withArguments:dictionary andCallback:^(BOOL success, id result){
    if(success){
      // Cast result to an NSDictionary* and do something with the UI
      // Alert delegates
    }
    else{
      // Cast result to an NSError* and alert your delegates
    }
}];
```
####POST
```objective-c
 /*
   * dictionary: 
   * NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
   * [dictionary setValue:userName forKey:kAttributeUserUserName];
   * [dictionary setValue:password forKey:kAttributeUserPassword];
   * [dictionary setValue:firstName forKey:kAttributeUserFirstName];
   * [dictionary setValue:lastName forKey:kAttributeUserLastName];
   * [dictionary setValue:email forKey:kAttributeUserEmail];
   */
[[StackMob stackmob] post:@"account" withArguments:dictionary andCallback:^(BOOL success, id result){
    if(success){
      // Cast result to a NSDictionary* and do something with the UI
      // Alert delegates
    }
    else{
      // Cast result to an NSError* and alert your delegates
    }
}];
```
####File Uploads
If you need to upload a binary file just add an NSData* object to your argument dictionary

```objective-c
// kAttributePostPhoto here is the name of the binary field in your object model
[dictionary setValue:[NSData dataWithContentsOfFile:pathToDataFile] forKey:kAttributePostPhoto];
```
####Facebook Registration
You can register a new user with a facebook token and username

```objective-c
[[StackMob stackmob] registerWithFacebookToken:token username:myLoginObject.userName andCallback:^(BOOL success, id result){
    if(success){
      // Cast result to a NSDictionary* and do something with the UI
      // Alert delegates
    }
    else{
      // Cast result to an NSError* and alert your delegates
    }
}];
```
You can also link an existing user account to his/her Facebook account:

```objective-c
[[StackMob stackmob] linkUserWithFacebookToken:facebookToken withCallback:^(BOOL success, id result){
    if(success){
        // User accounts linked.  Alert your delegates
    }
    else{
        // Error.  Display alert to user and/or alert your delegates
    }
}];
```
####Twitter Registration
You can register a new user with a twitter token, secret and username

```objective-c
[[StackMob stackmob] registerWithTwitterToken:token secret:secret username:username andCallback:^(BOOL success, id result){
    if(success){
        // User registered.  Persist the user and alert your delegates
    }
    else{
        // Error.  Display alert to user and/or alert your delegates
    }
}];
```
You can also link an existing user account to his/her Twitter account:

```objective-c
[[StackMob stackmob] linkUserWithTwitterToken:@"" secret:@"" andCallback:^(BOOL success, id result){
    if(success){
        // User accounts linked.  Alert your delegates
    }
    else{
        // Error.  Display alert to user and/or alert your delegates
    }
}];
```
####iOS PUSH Notifications
You can register an Apple Push Notification service device by creating and calling a method like registerForPush.  Keep in mind you may want to do this only after registering a user.

```objective-c
- (void)registerForPush
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: 
     (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}
```

```objective-c
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [[token componentsSeparatedByString:@" "] componentsJoinedByString:@""];
    // Persist your user's accessToken here if you need
    [[StackMob stackmob] registerForPushWithUser:currentUser.userName andToken:token andCallback:^(BOOL success, id result){
        if(success){
            // User created.  Alert your delegates
        }
        else{
            // Unable to register device for PUSH notifications 
            // Failed.  Alert your delgates
        }
    }];
}
```

Troubleshooting
===============


