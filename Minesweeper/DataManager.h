//
//  DataManager.h
//  Minesweeper
//
//  Created by Stephen Wagner on 4/19/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoard.h"
#import "Cell.h"
#import "Constants.h"

@interface DataManager : NSObject

+ (instancetype)sharedInstance;
-(BOOL)saveGame:(GameBoard *)gameBoard;
-(GameBoard *)loadGame;
-(BOOL)saveStats: (NSDictionary *)stats;
-(NSArray*)getAllStats;

@end
