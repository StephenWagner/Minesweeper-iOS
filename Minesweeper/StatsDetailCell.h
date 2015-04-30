//
//  StatsDetailCell.h
//  Minesweeper
//
//  Created by Stephen Wagner on 4/28/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface StatsDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fastestTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondFastestLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdFastestLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageWinTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *winPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *explorePercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesWonLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestWinStreakLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestLoseStreakLabel;

-(void)setAllLabels: (NSManagedObject*)statsObject;
@end
