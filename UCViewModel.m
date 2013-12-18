//
//  UCViewModel.m
//  UConnect
//
//  Created by Tomo Ueda on 12/18/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import "UCViewModel.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation UCViewModel

/** My properties synthesized. **/
@synthesize likeHash = _likeHash;
@synthesize counter = _counter;
@synthesize green = _green;
@synthesize yellow = _yellow;
@synthesize red = _red;
@synthesize highestmatch = _highestmatch;

/** My constructor that instantiates my properties.
    The color booleans are automatically set to display. **/
-(id) init {
    if (self = [super init]) {
        self.likeHash = [[NSMutableDictionary alloc] init];
        self.counter = [[NSMutableDictionary alloc] init];
        self.highestmatch = 0;
        self.red = YES;
        self.green = YES;
        self.yellow = YES;
    }
    return self;
}

/** This method fills the Like Hash, with my Facebook interests. **/
- (void) createMyLikeHash
{
    NSString *interests = @"me/interests";
    NSString *books = @"me/books";
    NSString *movies = @"me/movies";
    NSString *music = @"me/music";
    NSString *likes = @"me/likes";
    NSString *games = @"me/games";
    NSString *tvshows = @"me/television";
    [self createMyLikeHashWithFacebookString:interests];
    [self createMyLikeHashWithFacebookString:books];
    [self createMyLikeHashWithFacebookString:movies];
    [self createMyLikeHashWithFacebookString:music];
    [self createMyLikeHashWithFacebookString:likes];
    [self createMyLikeHashWithFacebookString:games];
    [self createMyLikeHashWithFacebookString:tvshows];
}

/** This method takes in a STRING which represent the graph search query from the Facebook API.
    It looks within that string. I'm pretty sure there s a better way to do this all at once using
    StartWithGraphPath parameters, instead of the generic version. **/
-(void)createMyLikeHashWithFacebookString:(NSString *)string;
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
             [self.likeHash setValue:name forKey:idnum];
         }
     }];
    
}


/** This function iterates through all my friends, and constructs string to query their various
    interests. We pass the string through to a function where we compare each interest to my hash table. **/
- (void) createCounterHash
{
    [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSLog(@"%@", error);
             return;
         }
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
             [self createCounterHashFacebookConnectionWithString:friends_interest withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_likes withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_music withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_movies withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_books withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_games withFriend:idnum];
             [self createCounterHashFacebookConnectionWithString:friends_television withFriend:idnum];
         }
     }];
}

/** We iterate through my friend's interests, 
    and for every interest we check for membership in my likeHash. **/
-(void) createCounterHashFacebookConnectionWithString:(NSString*) string
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
             if ([self.likeHash objectForKey:idnum] != nil) {
                 if ([self.counter objectForKey:friendID] == nil) {
                     NSInteger count = 1;
                     [self.counter setValue:[NSNumber numberWithInt:count] forKey:friendID];
                 } else {
                     NSInteger count = [[self.counter valueForKey:friendID] intValue];
                     count += 1;
                     [self.counter setValue:[NSNumber numberWithInt:count] forKey:friendID];
                 }
             }
         }
     }];
}

/** This method finds the highest overlapping interests between me and my friends.
    Once I find this number I set it to self.highestmatch. **/
-(void) findHighestMatch {
    NSArray* counts = [self.counter allValues];
    for (NSInteger i = 0; i < [self.counter count]; i++) {
        if (self.highestmatch < [counts[i] intValue] ) {
            self.highestmatch = [counts[i] intValue];
        }
    }
}

/** This method takes in a ID, and returns the value for the id in our counter. **/
- (id) counterNumberAt: (id) aKey
{
    return [self.counter objectForKey:aKey];
}

@end
