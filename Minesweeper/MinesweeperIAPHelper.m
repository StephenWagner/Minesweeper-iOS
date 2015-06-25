//
//  MinesweeperIAPHelper.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/18/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "MinesweeperIAPHelper.h"

@interface MinesweeperIAPHelper()
@end

@implementation MinesweeperIAPHelper

+(MinesweeperIAPHelper*)sharedInstance{
    static dispatch_once_t once;
    static MinesweeperIAPHelper *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithConsumableProducts:[MinesweeperIAPHelper consumableProducts] andNonConsumableProducts:nil];
    });
    
    return sharedInstance;
}

+(NSSet*)consumableProducts {
    static dispatch_once_t once;
    static NSSet *productNames;
    
    dispatch_once(&once, ^{
        productNames = [NSSet setWithArray: @[@"com.smwagner.minesweeper.emptySpaceMiniPack",
                                              @"com.smwagner.minesweeper.minedHintsMiniPack",
                                              @"com.smwagner.minesweeper.emptySpaceMedPack",
                                              @"com.smwagner.minesweeper.minedHintsMedPack",
                                              @"com.smwagner.minesweeper.emptySpaceLargePack",
                                              @"com.smwagner.minesweeper.minedHintsLargePack",
                                              @"com.smwagner.minesweeper.warWinnerBundle"]];
    });
    
    return productNames;
}

-(NSDictionary*)productValues{
    if (_productValues) {
        _productValues = @{ @"com.smwagner.minesweeper.emptySpaceMiniPack": @20,
                            @"com.smwagner.minesweeper.minedHintsMiniPack": @20,
                             @"com.smwagner.minesweeper.emptySpaceMedPack": @50,
                             @"com.smwagner.minesweeper.minedHintsMedPack": @50,
                           @"com.smwagner.minesweeper.emptySpaceLargePack": @100,
                           @"com.smwagner.minesweeper.minedHintsLargePack": @100,
                               @"com.smwagner.minesweeper.warWinnerBundle": @1000};
    }
    return _productValues;
}


@end
