//
//  GameBoard.h
//  Minesweeper
//
//  Created by Stephen Wagner on 3/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"

@interface GameBoard : NSObject

@property (nonatomic) NSInteger totalRows;
@property (nonatomic) NSInteger totalColumns;
@property (nonatomic) NSInteger totMines;
@property (nonatomic) NSInteger totFlags;
@property (nonatomic) BOOL gameOver;
@property (strong, nonatomic) Cell *exploded;
@property (strong, nonatomic) NSMutableArray* board; //Cells
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger time;
@property NSTimeInterval startTime, endTime, elapsedTime;
@property (nonatomic) NSInteger hintsRemaining;
@property NSString *difficulty;

-(instancetype) init;
-(instancetype) initWithRows: (NSInteger)row andColumns: (NSInteger)col andNumberOfMines: (NSInteger)mines;
-(BOOL) revealWithRow: (NSInteger)row andCol: (NSInteger)col;
-(void) toggleFlagWithRow: (NSInteger)row andColumn: (NSInteger)col;
-(void) newGameWithNumberOfRows: (NSInteger)numRows andColumns: (NSInteger)numCol andMines: (NSInteger)mines;
-(BOOL) winner;
-(void) makeAllMinesFlagged;
-(void)startTimerWithOffset: (BOOL)doOffset;
-(void)stopTimer;
-(float)getPercentFinished;

@end
