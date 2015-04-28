//
//  Cell.m
//  Minesweeper
//
//  Created by Stephen Wagner on 3/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "Cell.h"
#import "Constants.h"

@interface Cell()

//@property (nonatomic) BOOL mined;
//@property (nonatomic) BOOL hidden;
//@property (nonatomic) BOOL flagged;
//@property (nonatomic) BOOL blown;
//@property (nonatomic) int minesClose;
//@property (strong, nonatomic) UIImage *image;
//@property (strong, nonatomic) NSString *buttonTitle;

@end


@implementation Cell

-(instancetype)init{
    return [self initWithImageName:@"CellHidden"];
}

-(instancetype)initWithImageName: (NSString*)imgName{
    if(self = [super init]){
        self.mined = NO;
        self.hidden = YES;
        self.flagged = NO;
        self.minesClose = 0;
        self.blown = NO;
        self.image = [UIImage imageNamed:imgName];
        self.buttonTitle = @"";
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeBool:self.mined forKey:keyMined];
    [encoder encodeBool:self.hidden forKey:keyHidden];
    [encoder encodeBool:self.flagged forKey:keyFlagged];
    [encoder encodeBool:self.blown forKey:keyBlown];
    [encoder encodeInt:self.minesClose forKey:keyMinesClose];
    [encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:keyImage];
    [encoder encodeObject:self.buttonTitle forKey:keyButtonTitle];
}

- (instancetype)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        self.mined = [decoder decodeBoolForKey:keyMined];
        self.hidden = [decoder decodeBoolForKey:keyHidden];
        self.flagged = [decoder decodeBoolForKey:keyFlagged];
        self.minesClose = [decoder decodeIntForKey:keyMinesClose];
        self.blown = [decoder decodeBoolForKey:keyBlown];
        self.image = [UIImage imageWithData:[decoder decodeObjectForKey:keyImage]];
        self.buttonTitle = [decoder decodeObjectForKey:keyButtonTitle];
    }
    return self;
}

@end
