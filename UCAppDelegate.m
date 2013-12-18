//
//  UCAppDelegate.m
//  UConnect
//
//  Created by Tomo Ueda on 12/10/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import "UCAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UCLoginViewController.h"
#import "UCMatchViewController.h"

@implementation UCAppDelegate
NSString *const SCSessionStateChangedNotification = @"com.tomoueda.uconnect:SCSessionStateChangedNotification";
@synthesize mainViewController = _mainViewController;
@synthesize navController = _navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.mainViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UCViewController"];
    self.navController = [[UINavigationController alloc]
                          initWithRootViewController:(UIViewController*)self.mainViewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [self openSession];
    } else {
        [self showLoginView];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)showCommonViewWithMatch:(NSInteger) match idNum:(NSInteger)idNum viewToDisplay:(UCMatchViewController *) matchViewController
{
    UIViewController *topViewController = [self.navController topViewController];
    [matchViewController setNumMatch:match];
    [matchViewController setIdNum:idNum];
    [topViewController presentViewController:matchViewController animated:NO completion:nil];
}

-(void)showLoginView
{
    UIViewController *topViewController = [self.navController topViewController];
    UIViewController *presentedViewController = [topViewController presentedViewController];
    
    if (![presentedViewController isKindOfClass:[UCLoginViewController class]]) {
        UCLoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UCLoginViewController"];
        [topViewController presentViewController:loginViewController animated:NO completion:nil];
    } else {
        UCLoginViewController *loginViewController = (UCLoginViewController*)presentedViewController;
        [loginViewController loginFailed];
    }
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)openSession
{
    NSArray* myPermissions = [NSArray arrayWithObjects:
                              @"user_interests", @"user_likes", @"friends_likes", @"friends_interests", nil];
    [FBSession openActiveSessionWithReadPermissions:myPermissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      [self sessionStateChanged:session
                                                          state:state
                                                          error:error];
                                  }];
}

-(void)sessionStateChanged:(FBSession *)session
                     state:(FBSessionState) state
                     error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            UIViewController *topViewController = [self.navController topViewController];
            if ([[topViewController presentedViewController]
                 isKindOfClass:[UCLoginViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            //Once user has logged in we want them to be looking at root view
            [self.navController popToRootViewControllerAnimated:NO];
            [FBSession.activeSession closeAndClearTokenInformation];
            [self showLoginView];
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SCSessionStateChangedNotification
     object:session];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
