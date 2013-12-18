//
//  UCCommonViewController.h
//  UConnect
//
//  Created by Tomo Ueda on 12/13/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCCommonViewController : UIViewController

@property (nonatomic) NSInteger numMatch;
@property (nonatomic) NSInteger idNum;
@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSString *friendName;

-(void)setNumMatch:(NSInteger)numMatch;
-(void)setIdNum:(NSInteger)idNum;
-(void)addItemtoItems:(NSString *)item;
-(void)setFriendName:(NSString *)FriendName;

@end
