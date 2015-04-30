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
#import "StatsDetailCell.h"
#import "GameStats.h"

@interface StatsTableViewController()

@property (weak, nonatomic) DataManager *manager;
//@property (weak, nonatomic) NSArray *objects;

@end


@implementation StatsTableViewController

-(void)viewDidLoad {    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GameStats"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keySortOrder ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:context
                                              sectionNameKeyPath:keyDifficulty
                                              cacheName:nil];
    
    NSError *error;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    
    
    if ([[self.fetchedResultsController sections]count] < 3) {
        DataManager *manager = [DataManager sharedInstance];
        [manager getAllStats];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:fetchRequest
                                         managedObjectContext:context
                                         sectionNameKeyPath:keyDifficulty
                                         cacheName:nil];

    }

    if (!success) {
        NSLog(@"Was not able to fetch for NSFetchedResultsController");
    }else {
        GameStats *statsObject;
        for (int i = 0; i < 3; i++) {
            statsObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            NSLog(@"%@", statsObject.difficulty);
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [self.objects[section] valueForKey:keyDifficulty];
    NSString *returnString = [[[self.fetchedResultsController sections] objectAtIndex:section]name];
    return returnString;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Stats Detail Cell";
    StatsDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
//    NSManagedObject *statsObject = self.objects[indexPath.section];
    GameStats *statsObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (!cell){
        cell = [[StatsDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        [cell setAllLabels:statsObject];
    }

    NSLog(@"fastest: %f", [[statsObject valueForKey:keyFastest]floatValue]);
//    NSLog(@"%@", self.objects[0]);
//    cell.fastestTimeLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keyFastest]floatValue]];
//    cell.secondFastestLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keySecondFastest] floatValue]];
//    cell.thirdFastestLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keyThirdFastest] floatValue]];
//    cell.averageWinTimeLabel.text = [NSString stringWithFormat:@"%f", [[statsObject valueForKey:keyAverageWinTime] floatValue]];
//    cell.winPercentageLabel.text = [NSString stringWithFormat:@"%f%%", [[statsObject valueForKey:keyWinPercent] floatValue]];
//    cell.explorePercentLabel.text = [NSString stringWithFormat:@"%f%%", [[statsObject valueForKey:keyExplorationPercent] floatValue]];
//    cell.gamesPlayedLabel.text = [NSString stringWithFormat:@"%ld", [[statsObject valueForKey:keyGamesPlayed] integerValue]];
//    cell.gamesWonLabel.text = [NSString stringWithFormat:@"%ld", [[statsObject valueForKey:keyGamesWon] integerValue]];
//    cell.longestWinStreakLabel.text = [NSString stringWithFormat:@"%ld", [[statsObject valueForKey:keyLongestWinStreak] integerValue]];
//    cell.longestLoseStreakLabel.text = [NSString stringWithFormat:@"%ld", [[statsObject valueForKey:keyLongestLoseStreak] integerValue]];

    cell.fastestTimeLabel.text = [NSString stringWithFormat:@"%@", statsObject.fastestWin];
    cell.secondFastestLabel.text = [NSString stringWithFormat:@"%@", statsObject.secondFastestWin];
    cell.thirdFastestLabel.text = [NSString stringWithFormat:@"%@", statsObject.thirdFastestWin];
    cell.averageWinTimeLabel.text = [NSString stringWithFormat:@"%@", statsObject.averageWinTime];
    cell.winPercentageLabel.text = [NSString stringWithFormat:@"%@", statsObject.winPercentage];
    cell.explorePercentLabel.text = [NSString stringWithFormat:@"%@", statsObject.explorationPercentage];
    cell.gamesPlayedLabel.text = [NSString stringWithFormat:@"%@", statsObject.gamesPlayed];
    cell.gamesWonLabel.text = [NSString stringWithFormat:@"%@", statsObject.gamesWon];
    cell.longestWinStreakLabel.text = [NSString stringWithFormat:@"%@", statsObject.longestWinStreak];
    cell.longestLoseStreakLabel.text = [NSString stringWithFormat:@"%@", statsObject.longestLoseStreak];
    
    return cell;
}

#pragma mark - NSFetchedResultsController Delegate methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
