//
//  UCAppDelegate.h
//  UConnect
//
//  Created by Tomo Ueda on 12/10/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UCViewController;
@class UCMatchViewController;
@interface UCAppDelegate : UIResponder <UIApplicationDelegate>
extern NSString *const SCSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UCViewController *mainViewController;

-(void)openSession;
-(void)showCommonViewWithMatch:(NSInteger) match idNum:(NSInteger)idNum viewToDisplay: (UCMatchViewController *) matchViewController;

@end
