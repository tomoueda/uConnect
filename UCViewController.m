//
//  UCViewController.m
//  UConnect
//
//  Created by Tomo Ueda on 12/10/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import "UCViewController.h"
#import "UCAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>


@interface UCViewController ()

@end

@implementation UCViewController
@synthesize locationManager = _locationManager;
@synthesize scrollView = _scrollView;
@synthesize checker = _checker;
@synthesize highestmatch = _highestmatch;
@synthesize counter = _counter;
@synthesize booleans = _booleans;
@synthesize red = _red;
@synthesize yellow = _yellow;
@synthesize green = _green;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"uConnect";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Logout"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(logoutButtonWasPressed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Refresh"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(refresh:)];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 50;
    self.checker = [[NSMutableDictionary alloc] init];
    self.counter = [[NSMutableDictionary alloc] init];
    self.highestmatch = 0;
    self.booleans = [[NSMutableArray alloc] init];
    self.red = YES;
    self.green = YES;
    self.yellow = YES;
    [self resetBooleans];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SCSessionStateChangedNotification
     object:nil];
}

-(IBAction)switchRed:(UISwitch*)sender
{
    NSLog(@"change!");
    if (self.red) {
        self.red = NO;
    } else {
        self.red = YES;
    }
    [sender setOn:self.red];
    [self findHighestMatch];
    [self storeIDAndPersonalities];
}
-(IBAction)switchYellow:(UISwitch*)sender
{
    NSLog(@"change!");
    if (self.yellow) {
        self.yellow = NO;
    } else {
        self.yellow = YES;
    }
    [sender setOn:self.yellow];
    [self findHighestMatch];
    [self storeIDAndPersonalities];
}
-(IBAction)switchGreen:(UISwitch*)sender
{
    NSLog(@"change!");
    if (self.green) {
        self.green = NO;
    } else {
        self.green = YES;
    }
    [sender setOn:self.green];
    [self findHighestMatch];
    [self storeIDAndPersonalities];
}

-(void)resetBooleans
{
    for (NSInteger i = 0; i < 5; i++) {
        [self.booleans insertObject:[NSNumber numberWithBool:NO] atIndex:i];
    }
}

-(BOOL)booleanBlock
{
    for (NSInteger i = 0; i < 5; i++) {
        if ([self.booleans objectAtIndex:i]) {
            return YES;
        }
    }
    return NO;
}

- (void) createMyLikeHash
{
    NSString *interests = @"me/interests";
    NSString *books = @"me/books";
    NSString *movies = @"me/movies";
    NSString *music = @"me/music";
    NSString *likes = @"me/likes";
    NSString *games = @"me/games";
    NSString *tvshows = @"me/television";
    [self createMyLikeHashWithFacebookString:interests finishIndex:0];
    [self createMyLikeHashWithFacebookString:books finishIndex:1];
    [self createMyLikeHashWithFacebookString:movies finishIndex:2];
    [self createMyLikeHashWithFacebookString:music finishIndex:3];
    [self createMyLikeHashWithFacebookString:likes finishIndex:4];
    [self createMyLikeHashWithFacebookString:games finishIndex:5];
    [self createMyLikeHashWithFacebookString:tvshows finishIndex:6];
    NSLog(@"WHY DO I NOT WORK %d", [self.checker count]);
}

-(void)createMyLikeHashWithFacebookString:(NSString *)string finishIndex:(NSInteger) index;
{
    [FBRequestConnection startWithGraphPath:string completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSLog(@"%@", error);
             return;
         }
         NSArray *collection = (NSArray *)[result data];
         for (NSDictionary *interest in collection) {
             NSString *idnum = interest[@"id"];
             NSString *name = interest[@"name"];
             //NSLog(@"%@,%@", idnum, name);
             [self.checker setValue:name forKey:idnum];
             NSLog(@"%d", [self.checker count]);
         }
         [self.booleans insertObject:[NSNumber numberWithBool:YES] atIndex:index];
     }];
    
}

- (void) createCounterHash
{
    [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSLog(@"%@", error);
             return;
         }
         NSInteger i = 0;
         NSArray *collection = (NSArray *)[result data];
         for (NSDictionary *friends in collection) {
             NSString *idnum = friends[@"id"];
             NSString *friends_interest = [idnum stringByAppendingString:@"/interests"];
             NSString *friends_likes = [idnum stringByAppendingString:@"/likes"];
             NSString *friends_music = [idnum stringByAppendingString:@"/music"];
             NSString *friends_movies = [idnum stringByAppendingString:@"/movies"];
             NSString *friends_books = [idnum stringByAppendingString:@"/books"];
             NSString *friends_games = [idnum stringByAppendingString:@"/games"];
             NSString *friends_television = [idnum stringByAppendingString:@"/television"];
             [self createCounterHashFacebookConnectionWithString:friends_interest finishIndex:0 withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_likes finishIndex:1 withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_music finishIndex:2 withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_movies finishIndex:3 withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_books finishIndex:4 withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_games finishIndex:5 withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_television finishIndex:6 withFriend:idnum];
             i += 1;
             NSLog(@"%d", i);
             [self resetBooleans];
         }
     }];
}


-(void) createCounterHashFacebookConnectionWithString:(NSString*) string
                                          finishIndex: (NSInteger) index
                                           withFriend:(NSString *) friendID
{
    [FBRequestConnection startWithGraphPath:string completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSLog(@"%@", error);
             return;
         }
         NSArray *collection = (NSArray *)[result data];
         for (NSDictionary *interest in collection) {
             NSString *idnum = interest[@"id"];
             if ([self.checker objectForKey:idnum] != nil) {
                 if ([self.counter objectForKey:friendID] == nil) {
                     NSInteger count = 1;
                     NSLog(@"%d, %@", count, friendID);
                     [self.counter setValue:[NSNumber numberWithInt:count] forKey:friendID];
                 } else {
                     NSInteger count = [[self.counter valueForKey:friendID] intValue];
                     count += 1;
                     NSLog(@"%d, %@", count, friendID);
                     [self.counter setValue:[NSNumber numberWithInt:count] forKey:friendID];
                 }
             }
             if ([self.counter objectForKey:friendID] != nil) {
                 NSLog(@"%d", [[self.counter objectForKey:friendID] intValue]);
             }
         }
         [self.booleans insertObject:[NSNumber numberWithBool:YES] atIndex:index];
     }];
}

-(void) findHighestMatch {
    NSArray* counts = [self.counter allValues];
    for (NSInteger i = 0; i < [self.counter count]; i++) {
        if (self.highestmatch < [counts[i] intValue] ) {
            self.highestmatch = [counts[i] intValue];
        }
    }
    NSLog(@"%d", self.highestmatch);
}


- (void) storeIDAndPersonalities
{
    NSLog(@"DRAWING ALREADY");
    __block NSInteger y = 0;
    for (UIView *view in [self.view subviews]) {
        if (![view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    [self.scrollView setScrollEnabled:YES];
    NSLog(@"highestmatching... %d", [self highestmatch]);
    CGFloat width = self.scrollView.bounds.size.width;
    CGRect profile = CGRectMake(10, 10, 56, 73);
    CGRect label = CGRectMake(75, 0, 140, 50);
    CGRect label2 = CGRectMake(75, 50, 140, 50);
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection * connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 CGRect frame = CGRectMake(10, 75 + y * 110, width - 20, 100);
                 UIView *temp = [[UIView alloc] initWithFrame:frame];
                 FBProfilePictureView *myPic = [[FBProfilePictureView alloc]
                                                    initWithFrame:profile];
                 UILabel *myName = [[UILabel alloc]
                                    initWithFrame:label];
                 myPic.profileID = user.id;
                 myName.text = user.name;
                 [temp addSubview:myPic];
                 [temp addSubview:myName];
                 [self.scrollView addSubview:temp];
                 [self.locationManager startUpdatingLocation];
                 y += 1;
             }
         }];
        [[FBRequest requestForMyFriends] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary *result, NSError *error){
             if (!error) {
                 NSArray* friends = [result objectForKey:@"data"];
                 for (NSDictionary<FBGraphUser>* friend in friends) {
                     NSString *userid = friend.id;
                     CGRect frame = CGRectMake(10, 75 + y * 110, width - 20, 100);
                     UIView *temp = [[UIView alloc] initWithFrame:frame];
                     CGFloat check = (float) self.highestmatch;
                     CGFloat count = 0;
                     NSLog(@"%d", [self.counter count]);
                     if ([self.counter objectForKey:userid] != nil) {
                         count = [[self.counter valueForKey:(NSString*)friend.id] floatValue];
                     } else {
                         continue;
                     }
                     NSLog(@"%f, %f", count, check);
                     CGFloat compatability = 0;
                     compatability = count / check;
                     if (compatability > .6) {
                         if (self.green) {
                             temp.backgroundColor = [UIColor greenColor];
                         } else {
                             continue;
                         }
                     } else if (compatability > .2) {
                         if (self.yellow) {
                             temp.backgroundColor = [UIColor yellowColor];
                         } else {
                             continue;
                         }
                     } else {
                         if (self.red) {
                             temp.backgroundColor = [UIColor redColor];
                         } else {
                             continue;
                         }
                     }
                     FBProfilePictureView *friendPic = [[FBProfilePictureView alloc]
                                                    initWithFrame:profile];
                     friendPic.profileID = friend.id;
                     UILabel *friendName = [[UILabel alloc] initWithFrame:label];
                     friendName.tag = -1;
                     UILabel *percentage = [[UILabel alloc] initWithFrame:label2];
                     friendName.tag = -2;
                     percentage.text = [NSString stringWithFormat:@"uC rate: %2.f %%", compatability*100];
                     friendName.text = friend.name;
                     UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(getPersonal:)];
                     [doubleTap setNumberOfTapsRequired:2];
                     [doubleTap setNumberOfTouchesRequired:1];
                     temp.tag = [friend.id intValue];
                     [temp addGestureRecognizer:doubleTap];
                     [temp addSubview:friendPic];
                     [temp addSubview:friendName];
                     [temp addSubview:percentage];
                     [self.scrollView addSubview:temp];
                     y += 1;
                     [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 75 + y*110)];
                }
             }
             for (UIView *view in [self.view subviews]) {
                 if ([view isKindOfClass:[UISwitch class]]) {
                     [self.view bringSubviewToFront:view];
                 }
             }
         }];
    }
}


-(void)getPersonal:(UIGestureRecognizer*) gesture
{
    NSString* string = [NSString stringWithFormat:@"%d", gesture.view.tag];
    NSString *friends_interest = [string stringByAppendingString:@"/interests"];
    NSString *friends_likes = [string stringByAppendingString:@"/likes"];
    NSString *friends_music = [string stringByAppendingString:@"/music"];
    NSString *friends_movies = [string stringByAppendingString:@"/movies"];
    NSString *friends_books = [string stringByAppendingString:@"/books"];
    //[self addItemWith:friends_interest];
    [self addItemWith:friends_likes];
//    [self addItemWith:friends_music];
//    [self addItemWith:friends_movies];
//    [self addItemWith:friends_books];
}

-(void) addItemWith:(NSString *) friendInterest
{
    [FBRequestConnection startWithGraphPath:friendInterest completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSLog(@"%@", error);
             return;
         }
         for (UIView *view in [self.view subviews]) {
             if (![view isKindOfClass:[UISwitch class]]) {
                 [view removeFromSuperview];
             }
         }
         NSInteger y = 100;
         NSArray *collection = (NSArray *)[result data];
         for (NSDictionary *interest in collection) {
             NSString *idnum = interest[@"id"];
             NSString *name = interest[@"name"];
             if ([self.checker objectForKey:idnum] != nil) {
                 NSLog(@"hit");
                 UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 250, 25)];
                 label.text = name;
                 [self.view addSubview:label];
                 [self.view bringSubviewToFront:label];
                 y += 25;
             }
         }
     }];
}

-(void)redraw:(id)sender
{
    [self findHighestMatch];
    [self storeIDAndPersonalities];
}

-(void)refresh:(id)Sender
{
    [self findHighestMatch];
    [self storeIDAndPersonalities];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logoutButtonWasPressed:(id)Sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}

/* LOCATION MANAGER DELEGATE METHODS */
-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    if (!oldLocation ||
        (oldLocation.coordinate.latitude != newLocation.coordinate.latitude &&
         oldLocation.coordinate.longitude != newLocation.coordinate.longitude)) {
        //add code for triggering view controller update
            double latti = newLocation.coordinate.latitude;
            double longi = newLocation.coordinate.longitude;
            NSLog(@"Got Location: %f, %f", latti, longi);
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
   // NSLog(@"%@ fellow humans", error);
}

/* END LOCATION MANAGER DELEGATE METHODS */




-(void)sessionStateChanged:(NSNotification *)notification
{
    if (self.highestmatch == 0) {
        [self createMyLikeHash];
        [self createCounterHash];
    } else {
        [self findHighestMatch];
        [self storeIDAndPersonalities];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (FBSession.activeSession.isOpen && (self.highestmatch == 0)) {
        [self createMyLikeHash];
        [self createCounterHash];
    }
    
    if (FBSession.activeSession.isOpen) {
        [self findHighestMatch];
        [self storeIDAndPersonalities];
    }
}

@end
