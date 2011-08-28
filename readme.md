Getting Started
=========
1. Clone the repository from GitHub
`git clone git://github.com/stackmob/StackMob_iOS.git`
2. Open the StackMobiOS project in XCode
3.  Build the target "Build Framework"
Note: if your are not building for iOS 4.3, modify lines 8 and 9 in script/build.sh
```sh
xcodebuild -configuration Release -target "StackMob" -sdk iphoneos5.0
xcodebuild -configuration Release -target "StackMob" -sdk iphonesimulator5.0
```
4.  Copy $\{StackMobiOSHome\}/build/Framework/StackMob.framework to your project as a framework
5. Add the following to Other Linker Flags in the build configuration of your project: -ObjC -all_load
6.  Add the following Frameworks to your project:

    - CFNetwork.framework
    - CoreLocation.framework
    - SystemConfirmation.framework
    - YAJLiOS.framework - This is provided as part of our GitHub project. You will find it in the external folder

7. Copy and configure a StackMob.plist in your app's main Bundle

    - copy Demo/DemoApp/DemoApp/StackMob.plist into your Xcode project
    - enter your app and account info

Coding
=====
You can now make requests to your servers on StackMob using the following pattern.

####GET

```objective-c
 /*
   * dictionary: 
   * NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
   * [dictionary setValue:userName forKey:kAttributeUserUserName];
   */
[[StackMob stackmob] get:@"account" withArguments:dictionary andCallback:^(BOOL success, id result){
    if(success){
      // Cast result to a NSDictionary* and do something with the UI
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
You can register a user with a facebook token and username

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
    /*
     * userInfo: 
     * NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
     * [userInfo setValue:self.deviceToken forKey:kAttributeUserDeviceToken];
     * [userInfo setValue:self.remoteID forKey:kAttributeUserUserID];
     */
    [[StackMob stackmob] registerUserForPushwithArguments:userInfo andCallback:^(BOOL success, id result){
        if(success){
            // Registered User and alert your delegates
        }
        else{
            // Unable to register device for PUSH notifications 
            // Failed.  Alert your delgates
        }
    }];
}
```

