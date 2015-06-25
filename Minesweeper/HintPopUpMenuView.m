//
//  HintPopUpMenuView.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/4/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "HintPopUpMenuView.h"

@interface HintPopUpMenuView()
@property (strong, nonatomic) UIView *menu;
@property (strong, nonatomic) UILabel *menuLabel;
@property NSInteger emptySpaceHintsRemaining;
@property NSInteger minedSpaceHintsRemaining;

@end

@implementation HintPopUpMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype)initWithFrame:(CGRect)frame emptySpaceHintsRemaining:(NSInteger)emptyHints minedSpaceHintsRemaining: (NSInteger)minedHints{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        _emptySpaceHintsRemaining = emptyHints;
        _minedSpaceHintsRemaining = minedHints;
    }
    
    return self;
}

-(void)setup{
    self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeFromSuperview)];
    [self addGestureRecognizer:tapGesture];
}

-(void)animateMenuOnScreen{
    //create menu view
    CGRect menuFrame = CGRectMake(self.frame.size.width*0.10,
                                  self.frame.size.height*0.10,
                                  self.frame.size.width*0.8,
                                  self.frame.size.height*0.8);
    _menu = [[UIView alloc]initWithFrame: CGRectMake(menuFrame.origin.x + menuFrame.size.width/2, menuFrame.origin.y + menuFrame.size.height/2, 0, 0)];
    _menu.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.95];
    _menu.layer.cornerRadius = 10;
    _menu.layer.masksToBounds = YES;
    [self addSubview:_menu];
    
    //animate menu view onto the screen
    [UIView animateWithDuration:0.25
                     animations:^{
                         [_menu setFrame:menuFrame];
                     }
                     completion:^(BOOL finished){
                         [self setLayoutOfHintMenuView: _menu];
                     }];
}

-(void)setLayoutOfHintMenuView:(UIView*)menu {
    //add subviews
    [menu addSubview:self.menuLabel];
    [menu addSubview:self.emptySpaceHintButton];
    [menu addSubview:self.minedSpaceHintButton];
    [menu addSubview:self.buyHintsButton];

    //turn autolayout on
    [self.menuLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.emptySpaceHintButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.minedSpaceHintButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buyHintsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //menuLabel constraints: create and add
    NSLayoutConstraint *menuLabelCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.menuLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:menu attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *menuLabelYConstraint = [NSLayoutConstraint constraintWithItem:self.menuLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationLessThanOrEqual toItem:menu attribute:NSLayoutAttributeTop multiplier:1.0 constant:20];
    [menu addConstraints:@[menuLabelCenterXConstraint, menuLabelYConstraint]];
    
    //emptySpaceHintButton constraints: create and add
    NSLayoutConstraint *emptyHintBtnTopConstraint = [NSLayoutConstraint constraintWithItem:self.emptySpaceHintButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.menuLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:25.0];
    NSLayoutConstraint *emptyHintBtnHrzConstraint = [NSLayoutConstraint constraintWithItem:self.emptySpaceHintButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.menuLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    [menu addConstraints:@[emptyHintBtnTopConstraint, emptyHintBtnHrzConstraint]];
    
    //minedSpaceHintButton constraints: create and add
    NSLayoutConstraint *minedHintBtnTopConstraint = [NSLayoutConstraint constraintWithItem:self.minedSpaceHintButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.menuLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:25.0];
    NSLayoutConstraint *minedHintBtnHrzContraint = [NSLayoutConstraint constraintWithItem:self.minedSpaceHintButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.menuLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [menu addConstraints:@[minedHintBtnTopConstraint, minedHintBtnHrzContraint]];
    
    //buyHintsButton constraints: create and add
    NSLayoutConstraint *buyHintsBtnTopConstraint = [NSLayoutConstraint constraintWithItem:self.buyHintsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.emptySpaceHintButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0];
    NSLayoutConstraint *buyHintsBtnCenterXContraint = [NSLayoutConstraint constraintWithItem:self.buyHintsButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:menu attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [menu addConstraints:@[buyHintsBtnCenterXContraint, buyHintsBtnTopConstraint]];
    
//    //menu constraints: create and add
//    NSLayoutConstraint *menuBottonConstraint = [NSLayoutConstraint constraintWithItem:self.menu attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.emptySpaceHintButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0];
//    
//    [menu addConstraint: menuBottonConstraint];
}

#pragma mark - Custom Setters/Getters

-(UIButton*)emptySpaceHintButton{
    if (!_emptySpaceHintButton) {
        _emptySpaceHintButton = [[UIButton alloc]init];
        [_emptySpaceHintButton setImage:[UIImage imageNamed:@"CellEmptySpaceHint"] forState:UIControlStateNormal];
        [_emptySpaceHintButton sizeToFit];
    }
    
    return _emptySpaceHintButton;
}

-(UIButton*)minedSpaceHintButton{
    if (!_minedSpaceHintButton) {
        _minedSpaceHintButton = [[UIButton alloc]init];
        [_minedSpaceHintButton setImage:[UIImage imageNamed:@"CellMinedSpaceHint"] forState:UIControlStateNormal];
        [_minedSpaceHintButton sizeToFit];
    }
    return _minedSpaceHintButton;
}

-(UIButton*)buyHintsButton{
    if (!_buyHintsButton) {
        _buyHintsButton = [[UIButton alloc]init];
        [_buyHintsButton setTitle:@"Buy Hints" forState:UIControlStateNormal];
        _buyHintsButton.backgroundColor = [UIColor greenColor];
        [_buyHintsButton sizeToFit];
    }
    return _buyHintsButton;
}
-(UILabel*)menuLabel{
    if (!_menuLabel) {
        _menuLabel = [[UILabel alloc]init];
        NSInteger num = self.emptySpaceHintsRemaining;
        
        //top title "Hints Remaining"
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        UIColor *white = [UIColor whiteColor];
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        NSMutableAttributedString *mutAttString = [[NSMutableAttributedString alloc]init];
        NSAttributedString *attString = [[NSAttributedString alloc]initWithString:@"Hints Remaining\n" attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: white}];
        [mutAttString appendAttributedString:attString];
        
        //number of games which still have hints left
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        attString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"No. of games Empty-Space: %ld\nNo. of games Mined-Space: %ld\n\n", (long)num, (long)num] attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName: white}];
        [mutAttString appendAttributedString:attString];
        
        //subheading "Current Game"
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        attString = [[NSAttributedString alloc]initWithString:@"Current Game\n" attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName: paragraphStyle, NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: white}];
        [mutAttString appendAttributedString:attString];
        
        //number of hints which left in current game
        font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        attString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"Empty-Space: %ld\nMined-Space: %ld", (long)self.emptySpaceHintsRemaining, (long)self.minedSpaceHintsRemaining] attributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: font, NSForegroundColorAttributeName: white}];
        [mutAttString appendAttributedString:attString];
        
        //set the text in the uilabel
        
        _menuLabel.attributedText = mutAttString;
        _menuLabel.numberOfLines = 0;
        [_menuLabel sizeToFit];
    }
    return _menuLabel;
}

@end
