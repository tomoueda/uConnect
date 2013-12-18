//
//  UCViewModel.h
//  UConnect
//
//  Created by Tomo Ueda on 12/18/13.
//  Copyright (c) 2013 Tomo Ueda. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 The header file for the Model object.
*/
@interface UCViewModel : NSObject

/* The checker is a dictionary that has your interests stored.
    Main used to check membership when iterating through my friend's interests.
    The key is stored as the Facebook ID number, and the value is stored as the name of object.*/
@property (strong) NSMutableDictionary *likeHash;
    
    /* The counter is a dictionary that stores my friend's Facebook ID as the key and the number of overlapping interests as the value. */
@property (strong) NSMutableDictionary *counter;
    
/* The following three booleans will indicate whether to display the compatability level.
    Green for 60% or higher. Yellow for 60%-20% or higher. Red for 20%-0%. */
@property BOOL green;
@property BOOL yellow;
@property BOOL red;
    
/* The highest match is an integer that stores the highest number of overlapping interest of a single friend. */
@property NSInteger highestmatch;

/* My public methods */
- (void) findHighestMatch;
- (void) createCounterHash;
- (void) createMyLikeHash;
- (id) counterNumberAt: (id) aKey;


@end
