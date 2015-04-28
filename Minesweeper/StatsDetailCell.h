//
//  StatsDetailCell.h
//  Minesweeper
//
//  Created by Stephen Wagner on 4/28/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *averageWinTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *winPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesPlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesWonLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestWinStreakLabel;
@property (weak, nonatomic) IBOutlet UILabel *longestLoseStreakLabel;

@end
