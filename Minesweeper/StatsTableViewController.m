//
//  StatsTableViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 4/26/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "StatsTableViewController.h"
#import "DataManager.h"
#import "AppDelegate.h"

@interface StatsTableViewController()

//@property (weak, nonatomic) IBOutlet UILabel *easyFirstLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easySecondLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easyThirdLabel;
//
//@property (weak, nonatomic) IBOutlet UILabel *easyAverageWinTimeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easyWinPercentageLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easyGamesPlayedLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easyGamesWonLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easyLongestWinningStreakLabel;
//@property (weak, nonatomic) IBOutlet UILabel *easyLongestLosingStreakLabel;

@end


@implementation StatsTableViewController

-(void)viewDidLoad {
    DataManager *manager = [DataManager sharedInstance];
    NSArray *objects = [manager getAllStats];
    
    NSLog(@"number of objects in array: %ld", [objects count]);
    
    NSLog(@"first stats objects: %@", objects[0]);
    
    NSManagedObject *statsObject;
    for (int i = 0; i < [objects count]; i++) {
        statsObject = objects[i];
        
        if ([[statsObject valueForKey:keyDifficulty] isEqualToString:@"Easy"]) {
//            self.easyFirstLabel.text = [statsObject valueForKey:keyFastest];
//            self.easySecondLabel.text = [statsObject valueForKey:keySecondFastest];
//            self.easyThirdLabel.text = [statsObject valueForKey:keyThirdFastest];
//            self.easyAverageWinTimeLabel.text = [NSString stringWithFormat:@"%f",[[statsObject valueForKey:keyAverageWinTime] doubleValue]];
//            self.easyWinPercentageLabel.text = [NSString stringWithFormat:@"%f%%", [[statsObject valueForKey:keyWinPercent] floatValue]];
//            self.easyGamesPlayedLabel.text = [statsObject valueForKey:keyGamesPlayed];
//            self.easyGamesWonLabel.text = [statsObject valueForKey:keyGamesWon];
//            self.easyLongestWinningStreakLabel.text = [statsObject valueForKey:keyLongestWinStreak];
//            self.easyLongestLosingStreakLabel.text = [statsObject valueForKey:keyLongestLoseStreak];
        }
    }
    
}

@end
