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

#pragma mark - ADBannerView Delagate Methods
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"bannerViewDidLoadAd using separate Delegate");
    if (banner.hidden) {
        NSLog(@"banner was hidden");
        banner.hidden = NO;
        [self stopTimer];
        [banner.superview bringSubviewToFront:banner];
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"didFailtoReceiveAdWithError in separate Delegate, error: %@", error);
    if (!banner.hidden) {
        banner.hidden = YES;
        [self.adPlaceholderLabel.superview bringSubviewToFront:self.adPlaceholderLabel];
        [self.adPlaceholderLabel setAttributedText:[self adPlaceholderAttributedString]];
    }
}


#pragma mark - When BannerView failed to receive ad
#define adPlaceholderString @"ads go here"

-(NSAttributedString*) getColoredStringForIAdPlaceholder{
    self.whichString = (self.whichString + 1) % 4;
    NSRange range = NSMakeRange(0, self.adPlaceholderAttributedString.length);
    UIColor *color;
    
    switch (self.whichString) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor greenColor];
            break;
        case 3:
            color = [UIColor yellowColor];
            break;
        default:
            color = [UIColor redColor];
    }
    
    [self.adPlaceholderAttributedString addAttribute:NSForegroundColorAttributeName
                                               value:color
                                               range:range];

    return self.adPlaceholderAttributedString;
}

-(NSMutableAttributedString*)adPlaceholderAttributedString{
    if (!_adPlaceholderAttributedString) {
        NSRange range = NSMakeRange(0, adPlaceholderString.length);
        _adPlaceholderAttributedString = [[NSMutableAttributedString alloc]initWithString:adPlaceholderString];
        [_adPlaceholderAttributedString addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] range:range];
    }
    
    return _adPlaceholderAttributedString;
}

-(void)startTimer{
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeLabel) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer{
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

-(void)changeLabel{
    [self.adPlaceholderLabel setAttributedText:[self adPlaceholderAttributedString]];
}

-(UILabel*)adPlaceholderLabel{
    if (!_adPlaceholderLabel) {
        _adPlaceholderLabel = [[UILabel alloc]initWithFrame:self.adBanner.frame];
        [_adBanner.superview addSubview:self.adPlaceholderLabel];
        _adPlaceholderLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _adPlaceholderLabel;
}
@end

