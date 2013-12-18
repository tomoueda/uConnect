//
//  UCLoginViewController.m
//  UConnect
//
//  Created by Tomo Ueda on 12/10/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import "UCLoginViewController.h"
#import "UCAppDelegate.h"

@interface UCLoginViewController ()
-(IBAction)performLogin:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation UCLoginViewController
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)performLogin:(id)sender
{
    [self.spinner startAnimating];
    UCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}

-(void)loginFailed
{
    [self.spinner stopAnimating];
}

@end
