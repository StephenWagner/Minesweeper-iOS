//
//  GameStats.h
//  Minesweeper
//
//  Created by Stephen Wagner on 4/27/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GameStats : NSManagedObject

@property (nonatomic, retain) NSNumber * gamesWon;
@property (nonatomic, retain) NSNumber * gamesLost;
@property (nonatomic, retain) NSNumber * winPercentage;
@property (nonatomic, retain) NSNumber * averageWinTime;
@property (nonatomic, retain) NSNumber * longestWinStreak;
@property (nonatomic, retain) NSNumber * longestLoseStreak;
@property (nonatomic, retain) NSNumber * explorationPercentage;
@property (nonatomic, retain) NSNumber * currentWinStreak;
@property (nonatomic, retain) NSNumber * currentLoseStreak;
@property (nonatomic, retain) NSString * difficulty;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * gamesPlayed;
@property (nonatomic, retain) NSNumber * fastestWin;
@property (nonatomic, retain) NSNumber * secondFastestWin;
@property (nonatomic, retain) NSNumber * thirdFastestWin;

@end
