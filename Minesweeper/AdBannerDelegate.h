//
//  AdBannerController.h
//  Minesweeper
//
//  Created by Stephen Wagner on 6/2/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface AdBannerDelegate : NSObject <ADBannerViewDelegate>

@property (weak, nonatomic) ADBannerView *adBanner;
+(instancetype)sharedInstance;

-(void)bannerViewDidLoadAd:(ADBannerView *)banner;
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
@end
