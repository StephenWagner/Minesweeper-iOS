//
//  CellButton.h
//  Minesweeper
//
//  Created by Stephen Wagner on 3/21/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cell.h"
#import "GameBoard.h"

@interface CellButton : UIButton

@property (weak, nonatomic) Cell *cell;
@property NSInteger row;
@property NSInteger col;

-(instancetype)init;
-(instancetype)initWithCell: (Cell*)cell row:(NSInteger)row andCol:(NSInteger)col;
-(void)animateCellButton;

@end
