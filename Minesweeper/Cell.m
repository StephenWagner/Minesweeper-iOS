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
        self.questionMarked = NO;
        self.minesClose = 0;
        self.blown = NO;
        self.image = [UIImage imageNamed:imgName];
        self.label = @"";
        self.row = row;
        self.col = col;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    /*
     @property (nonatomic) BOOL mined;
     @property (nonatomic) BOOL hidden;
     @property (nonatomic) BOOL flagged;
     @property (nonatomic) BOOL blown;
     @property (nonatomic) int minesClose;
     @property (strong, nonatomic) UIImage *image;
     @property (strong, nonatomic) NSString *buttonTitle;
     @property NSInteger row;
     @property NSInteger col;
     */
    [encoder encodeBool:self.mined forKey:keyMined];
    [encoder encodeBool:self.hidden forKey:keyHidden];
    [encoder encodeBool:self.flagged forKey:keyFlagged];
    [encoder encodeBool:self.blown forKey:keyBlown];
    [encoder encodeInt:self.minesClose forKey:keyMinesClose];
    [encoder encodeObject:UIImagePNGRepresentation(self.image) forKey:keyImage];
    [encoder encodeObject:self.label forKey:keyCellLabel];
    [encoder encodeInteger:self.row forKey:keyRow];
    [encoder encodeInteger:self.col forKey:keyCol];
}

- (instancetype)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        /*
         @property (nonatomic) BOOL mined;
         @property (nonatomic) BOOL hidden;
         @property (nonatomic) BOOL flagged;
         @property (nonatomic) BOOL blown;
         @property (nonatomic) int minesClose;
         @property (strong, nonatomic) UIImage *image;
         @property (strong, nonatomic) NSString *buttonTitle;
         @property NSInteger row;
         @property NSInteger col;
         */
        self.mined = [decoder decodeBoolForKey:keyMined];
        self.hidden = [decoder decodeBoolForKey:keyHidden];
        self.flagged = [decoder decodeBoolForKey:keyFlagged];
        self.blown = [decoder decodeBoolForKey:keyBlown];
        self.minesClose = [decoder decodeIntForKey:keyMinesClose];
        self.image = [UIImage imageWithData:[decoder decodeObjectForKey:keyImage]];
        self.label = [decoder decodeObjectForKey:keyCellLabel];
        self.row = [decoder decodeIntegerForKey:keyRow];
        self.col = [decoder decodeIntegerForKey:keyCol];
    }
    return self;
}

@end
