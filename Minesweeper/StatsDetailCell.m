//
//  StatsDetailCell.m
//  Minesweeper
//
//  Created by Stephen Wagner on 4/28/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "StatsDetailCell.h"
#import "Constants.h"

@interface StatsDetailCell()

@end


@implementation StatsDetailCell

-(void)setAllLabels: (NSManagedObject*)statsObject{    
    self.fastestTimeLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keyFastest]floatValue]];
    self.secondFastestLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keySecondFastest] floatValue]];
    self.thirdFastestLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keyThirdFastest] floatValue]];
    self.averageWinTimeLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keyAverageWinTime] floatValue]];
    self.winPercentageLabel.text = [NSString stringWithFormat:@"%f%%", [[statsObject valueForKey:keyWinPercent] floatValue]];
    self.explorePercentLabel.text = [NSString stringWithFormat:@"%f%%", [[statsObject valueForKey:keyExplorationPercent] floatValue]];
    self.gamesPlayedLabel.text = [NSString stringWithFormat:@"%ld", (long)[[statsObject valueForKey:keyGamesPlayed] integerValue]];
    self.gamesWonLabel.text = [NSString stringWithFormat:@"%ld", (long)[[statsObject valueForKey:keyGamesWon] integerValue]];
    self.longestWinStreakLabel.text = [NSString stringWithFormat:@"%ld", (long)[[statsObject valueForKey:keyLongestWinStreak] integerValue]];
    self.longestLoseStreakLabel.text = [NSString stringWithFormat:@"%ld", (long)[[statsObject valueForKey:keyLongestLoseStreak] integerValue]];
}

@end
