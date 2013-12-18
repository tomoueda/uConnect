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

@class Firebase;
@interface UCViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableDictionary *checker;
@property (strong, nonatomic) NSMutableDictionary *counter;
@property (nonatomic) BOOL green;
@property (nonatomic) BOOL yellow;
@property (nonatomic) BOOL red;
@property (nonatomic) NSInteger highestmatch;
@property (nonatomic) NSMutableArray *booleans;

-(IBAction)switchYellow:(UISwitch*)sender;
-(IBAction)switchRed:(UISwitch*)sender;
-(IBAction)switchGreen:(UISwitch*)sender;



@end
