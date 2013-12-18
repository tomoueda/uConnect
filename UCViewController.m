//
//  UCViewController.m
//  UConnect
//
//  Created by Tomo Ueda on 12/10/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import "UCViewController.h"
#import "UCAppDelegate.h"
#import "UCViewModel.h"
#import <FacebookSDK/FacebookSDK.h>


@interface UCViewController ()

@end

@implementation UCViewController
@synthesize scrollView = _scrollView;
@synthesize viewModel = _viewModel;

/** Once the Views have been loaded, we set the two navigation buttons.
    Logout which allows us to logout of Facebook.
    Refresh which refreshes the page with the current data.
    We set up our notification center for state changes, and instantiate our Model. **/
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
                                              action:@selector(redraw:)];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:SCSessionStateChangedNotification
     object:nil];
    self.viewModel = [[UCViewModel alloc] init];
}

/** These are the switches for each of the different colors.
    On Value change, the booleans are changed, and the switch also changes values.
    We also refresh the board to automatically filter the colors. **/
-(IBAction)switchRed:(UISwitch*)sender
{
    [self.viewModel setRed:![self.viewModel red]];
    [sender setOn:[self.viewModel red]];
    [self.viewModel findHighestMatch];
    [self drawMeAndFriends];
}

-(IBAction)switchYellow:(UISwitch*)sender
{
    [self.viewModel setYellow:![self.viewModel yellow]];
    [sender setOn:[self.viewModel yellow]];
    [self.viewModel findHighestMatch];
    [self drawMeAndFriends];
}

-(IBAction)switchGreen:(UISwitch*)sender
{
    [self.viewModel setGreen:![self.viewModel green]];
    [sender setOn:[self.viewModel green]];
    [self.viewModel findHighestMatch];
    [self drawMeAndFriends];
}
/************************** END SWITCHES ********************************/

/** This function clears all views (retains the switches).
    Reallocates space for a new scrollView. **/
- (void) clearAndRestoreScrollView
{
    for (UIView *view in [self.view subviews]) {
        if (![view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    [self.scrollView setScrollEnabled:YES];
}

/** Draws from data in the ViewModel. Iterates through friends to hash their 
    check for their compatability. 
    Compatability is calculated as follows: current count / highest count. 
    GOAL: REDUCE THE NUMBER OF LINES IN THIS FUNCTION!!!!**/
- (void) drawMeAndFriends
{
    __block NSInteger y = 0;
    [self clearAndRestoreScrollView];
    CGFloat width = self.scrollView.bounds.size.width;
    CGRect profile = CGRectMake(10, 10, 56, 73);
    CGRect label = CGRectMake(75, 0, 140, 50);
    CGRect label2 = CGRectMake(75, 50, 140, 50);
    /** This session is to simply draw myself. **/
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
                 y += 1;
             }
         }];
        /** This is where we draw our friends. **/
        [[FBRequest requestForMyFriends] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary *result, NSError *error){
             if (!error) {
                 NSArray* friends = [result objectForKey:@"data"];
                 for (NSDictionary<FBGraphUser>* friend in friends) {
                     NSString *userid = friend.id;
                     CGRect frame = CGRectMake(10, 75 + y * 110, width - 20, 100);
                     UIView *temp = [[UIView alloc] initWithFrame:frame];
                     CGFloat check = (float) [self.viewModel highestmatch];
                     CGFloat count = 0;
                     if ([[self.viewModel counter] objectForKey:userid] != nil) {
                         count = [[[self.viewModel counter] valueForKey:(NSString*)friend.id] floatValue];
                     } else {
                         continue;
                     }
                     CGFloat compatability = 0;
                     compatability = count / check;
                     if (compatability > .6) {
                         if ([self.viewModel green]) {
                             temp.backgroundColor = [UIColor greenColor];
                         } else {
                             continue;
                         }
                     } else if (compatability > .2) {
                         if ([self.viewModel yellow]) {
                             temp.backgroundColor = [UIColor yellowColor];
                         } else {
                             continue;
                         }
                     } else {
                         if ([self.viewModel red]) {
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

/** When the double-click GESTURE is passed, we parse the gesture view tag off
    and display the common interest of this person.
    GOAL: FIGURE OUT HOW TO DISPLAY ALL OF THEM AT THE SAME TIME!!!!!!!!**/
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

/** The function that finds the common interests and adds it onto our view. **/
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
             if ([[self.viewModel likeHash] objectForKey:idnum] != nil) {
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

/** Finds the highestMatch and redraws the view with the new Highest Match
    to calculate compatability. **/
-(void)redraw:(id)sender
{
    [self.viewModel findHighestMatch];
    [self drawMeAndFriends];
}

/** Default method for memory management. **/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Logs out of Facebook. The SENDER is always the navigational button. **/
- (void)logoutButtonWasPressed:(id)Sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}

/** A function that refreshes the data in our viewModel. **/
- (void) refreshData
{
    [self.viewModel createMyLikeHash];
    [self.viewModel createCounterHash];
}

/** When we receive a NOTIFICATION that the state changed, we try to refresh the board,
    but depending on whether highest match was cached or not. **/
-(void)sessionStateChanged:(NSNotification *)notification
{
    if ([self.viewModel highestmatch] == 0) {
        [self refreshData];
    } else {
        [self redraw:nil];
    }
}

/** When a view is going to appear with ANIMATED, draw the state if there is a FBsession. **/
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (FBSession.activeSession.isOpen && ([self.viewModel highestmatch] == 0)) {
        [self refreshData];
    }
    
    if (FBSession.activeSession.isOpen) {
        [self redraw:nil];
    }
}

@end
