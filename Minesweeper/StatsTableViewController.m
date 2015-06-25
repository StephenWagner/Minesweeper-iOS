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
@end


@implementation StatsTableViewController

-(void)viewDidLoad {
    [[self tabBarItem] setSelectedImage:[UIImage imageNamed:@"StatsFilled"]];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GameStats"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keySortOrder ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
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

        success = [self.fetchedResultsController performFetch:&error];
    }

    if (!success) {
        NSLog(@"Was not able to fetch for NSFetchedResultsController");
    }else {
        GameStats *statsObject;
        for (int i = 0; i < 3; i++) {
            statsObject = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            NSLog(@"#####: %d", i);
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections]count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    GameStats *statsObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return statsObject.difficulty;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Stats Detail Cell";
    StatsDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    GameStats *statsObject = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (!cell){
        cell = [[StatsDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.fastestTimeLabel.text = [NSString stringWithFormat:@"%.3f", [statsObject.fastestWin doubleValue]];
    cell.secondFastestLabel.text = [NSString stringWithFormat:@"%.3f", [statsObject.secondFastestWin doubleValue]];
    cell.thirdFastestLabel.text = [NSString stringWithFormat:@"%.3f", [statsObject.thirdFastestWin doubleValue]];
    cell.averageWinTimeLabel.text = [NSString stringWithFormat:@"%.3f", [statsObject.averageWinTime doubleValue]];
    cell.winPercentageLabel.text = [NSString stringWithFormat:@"%.2f%%", [statsObject.winPercentage floatValue]];
    cell.explorePercentLabel.text = [NSString stringWithFormat:@"%.2f%%", [statsObject.explorationPercentage floatValue]];
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
