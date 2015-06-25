//
//  AdBannerController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/2/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "AdBannerDelegate.h"

@interface AdBannerDelegate()<ADBannerViewDelegate>

@property NSInteger whichString;
@property (strong, nonatomic) UILabel *adPlaceholderLabel;
@property (nonatomic) NSMutableAttributedString *adPlaceholderAttributedString;
@property (strong, nonatomic) NSTimer *timer;

@end


@implementation AdBannerDelegate

+(instancetype)sharedInstance{
    static AdBannerDelegate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AdBannerDelegate alloc]init];
    });
    return sharedInstance;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
    NSLog(@"bannerViewDidLoadAd");
    if (banner.hidden) {
        banner.hidden = NO;
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
    //need some other
    NSLog(@"didFailtoReceiveAdWithError, error: %@", error);
    banner.hidden = YES;
}

@end