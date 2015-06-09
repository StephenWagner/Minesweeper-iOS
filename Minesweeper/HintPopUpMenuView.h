//
//  HintPopUpMenuView.h
//  Minesweeper
//
//  Created by Stephen Wagner on 6/4/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HintPopUpMenuView : UIView

@property (strong, nonatomic) UIButton *emptySpaceHintButton;
@property (strong, nonatomic) UIButton *minedSpaceHintButton;

-(instancetype)initWithFrame:(CGRect)frame emptySpaceHintsRemaining:(NSInteger)emptyHints;
-(void)animateMenuOnScreen;
@end
