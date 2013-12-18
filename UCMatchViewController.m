//
//  UCMatchViewController.m
//  UConnect
//
//  Created by Tomo Ueda on 12/13/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import "UCMatchViewController.h"
#import "UCAppDelegate.h"

@interface UCMatchViewController ()

@end

@implementation UCMatchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

@synthesize numMatch = _numMatch;
@synthesize idNum = _idNum;
@synthesize items = _items;
@synthesize friendName = _friendName;

-(void)refresh:(UIButton*)sender
{
    [self reloadData];
    self.title = self.friendName;
}

-(void)addItemtoItems:(NSString *)item
{
    [self.items insertObject:item atIndex:[self.items count]];
}

-(void)reloadData
{
    NSInteger y = 15;
    for (NSString *string in _items) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 25)];
        [self.view addSubview:label];
        y += 25;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Refresh"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(refresh:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Go Back"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(goBack:)];
    self.title = self.friendName;
}
-(void)goBack:(UIButton *)sender
{
    UCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
