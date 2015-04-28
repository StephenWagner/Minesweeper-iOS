//
//  CellButton.m
//  Minesweeper
//
//  Created by Stephen Wagner on 3/21/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "CellButton.h"
#import "Constants.h"
#import "GameBoard.h"

@interface CellButton()

@end

@implementation
CellButton

-(instancetype)init{
    self = [super init];
    UIImage *btnImage = [UIImage imageNamed:@"CellHidded"];
    [self setImage:btnImage forState:UIControlStateNormal];
    
    return self;
}

-(instancetype)initWithCell: (Cell*)cell row:(NSInteger)row andCol:(NSInteger)col{
    self = [self initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.cell = cell;
    self.row = row;
    self.col = col;
    [self setBackgroundImage:self.cell.image forState:UIControlStateNormal];
    [self setTitleTextAndColor:self.cell.buttonTitle];
    self.adjustsImageWhenHighlighted = NO;

    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:keyImage]) {
        [self setBackgroundImage:[change objectForKey:@"new"] forState:UIControlStateNormal];
        //only make it so a button is not enabled when it has been revealed and has no mines close to it
        if (self.cell.minesClose == 0 && !self.cell.hidden) {
            self.userInteractionEnabled = NO;
        }
    }
    
    if ([keyPath isEqualToString:keyButtonTitle]) {
//        [self setTitle:self.cell.buttonTitle forState:UIControlStateNormal];
        [self setTitle:[change objectForKey:@"new"] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];

        [self setTitleTextAndColor:self.cell.buttonTitle];
    }
    
    if ([keyPath isEqualToString:keyGameOver]) {
        self.userInteractionEnabled = NO;
        if ([self.cell mined] && ![self.cell flagged] && !self.cell.blown) {
            [self setImage:[UIImage imageNamed:@"CellBomb"] forState:UIControlStateNormal];
        }
    }
    
//    if ([keyPath isEqualToString:keyExploded]) {
//        Cell *cell = [change objectForKey:@"new"];
//        
//        if (cell) {
//            
//        }
//    }
    
}

-(void)setTitleTextAndColor:(NSString*)title{
    [self setTitle:self.cell.buttonTitle forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
    
    //set color of uibutton label
    switch ([self.cell.buttonTitle integerValue]) {
        case 1:
            [self setTitleColor:[UIColor colorWithRed:0/225.0 green:0/225.0 blue:225/225.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 2:
            [self setTitleColor:[UIColor colorWithRed:15/225.0 green:114/225.0 blue:1/225.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 3:
            [self setTitleColor:[UIColor colorWithRed:251/255.0 green:0/255.0 blue:7/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 4:
            [self setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:113/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 5:
            [self setTitleColor:[UIColor colorWithRed:111/255.0 green:0/255.0 blue:2/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 6:
            [self setTitleColor:[UIColor colorWithRed:14/255.0 green:112/255.0 blue:113/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 7:
            [self setTitleColor:[UIColor colorWithRed:111/255.0 green:0/255.0 blue:113/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 8:
            [self setTitleColor:[UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2 or:(UIImage*)image3{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    NSData *data3 = UIImagePNGRepresentation(image3);
    
    return [data1 isEqual:data2] || [data1 isEqual:data3];
}

-(void)animateCellButton{
    
    if (!self.cell.hidden) {
        return;
    }
    CGRect regFrame = self.frame;
    CGRect newFrame = CGRectMake(self.frame.origin.x - 60, self.frame.origin.y - 60, self.frame.size.width + 120, self.frame.size.height + 120);
    [self.superview bringSubviewToFront:self];
    [self setFrame:newFrame];
    
    [UIView animateWithDuration:0.05f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self setFrame:regFrame];
                     }
                     completion:nil];

}
@end
