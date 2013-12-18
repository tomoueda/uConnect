//
//  UCViewController.h
//  UConnect
//
//  Created by Tomo Ueda on 12/10/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import <FacebookSDK/FacebookSDK.h>

@class UCViewModel;
@interface UCViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong) UCViewModel *viewModel;



-(IBAction)switchYellow:(UISwitch*)sender;
-(IBAction)switchRed:(UISwitch*)sender;
-(IBAction)switchGreen:(UISwitch*)sender;



@end
