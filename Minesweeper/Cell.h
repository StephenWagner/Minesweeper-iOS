//
//  Cell.h
//  Minesweeper
//
//  Created by Stephen Wagner on 3/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Cell : NSObject

@property (nonatomic) BOOL mined;
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL flagged;
@property (nonatomic) BOOL blown;
@property (nonatomic) int minesClose;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *buttonTitle;

-(instancetype)init;
-(instancetype)initWithImageName: (NSString*) imgName;

@end
