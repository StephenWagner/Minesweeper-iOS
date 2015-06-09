//
//  DifficultyTableViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 4/26/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "DifficultyTableViewController.h"
#import "Constants.h"

@implementation DifficultyTableViewController

-(void)viewDidLoad {
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.selected = YES;
    
    NSArray *difficulty;
    if ([cell.textLabel.text isEqualToString:@"Normal"]) {
        difficulty = [[NSArray alloc]initWithObjects:@16, @16, @40, nil];
        
    } else if ([cell.textLabel.text isEqualToString: @"Easy"]){
        
        difficulty = [[NSArray alloc]initWithObjects:@9, @9, @10, nil];
    } else {
        
        difficulty = [[NSArray alloc]initWithObjects:@30, @16, @99, nil];
    }
    
    NSLog(@"%@", cell.textLabel.text);
    NSLog(@"%@", difficulty);
    [[NSUserDefaults standardUserDefaults]setValue:difficulty forKey:keyDifficulty];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selected = NO;
}

@end
