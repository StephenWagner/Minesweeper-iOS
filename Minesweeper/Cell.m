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

@end


@implementation Cell

-(instancetype)initWithRow:(NSInteger)row andCol:(NSInteger)col {
    return [self initWithImageName:@"CellHidden" andRow:row andCol:col];
}

-(instancetype)initWithImageName: (NSString*)imgName andRow:(NSInteger)row andCol:(NSInteger)col{
    if(self = [super init]){
        self.mined = NO;
        self.hidden = YES;
        self.flagged = NO;
        self.minesClose = 0;
        self.blown = NO;
        self.image = [UIImage imageNamed:imgName];
        self.buttonTitle = @"";
        self.row = row;
        self.col = col;
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
