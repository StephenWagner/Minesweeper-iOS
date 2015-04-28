//
//  MainWindowViewController.h
//  Minesweeper
//
//  Created by Stephen Wagner on 3/9/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface MainWindowViewController : UIViewController <ADBannerViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;

@end

