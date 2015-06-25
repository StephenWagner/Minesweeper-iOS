//
//  MinesweeperIAPHelper.h
//  Minesweeper
//
//  Created by Stephen Wagner on 6/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"

@interface MinesweeperIAPHelper : IAPHelper

@property (strong, nonatomic) NSDictionary *productValues;
+(MinesweeperIAPHelper*)sharedInstance;
+(NSSet*)consumableProducts;
@end
