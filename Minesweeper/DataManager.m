//
//  DataManager.m
//  Minesweeper
//
//  Created by Stephen Wagner on 4/19/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"

@interface DataManager()

@property UIManagedDocument *document;

@end


@implementation DataManager

+ (instancetype)sharedInstance
{
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init{
    if ([super init]) {
        //do something?
    }
    return self;
}

-(BOOL)saveGame:(GameBoard *)gameBoard{
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:gameBoard forKey:keySavedGame];
    [archiver finishEncoding];
    NSString *gameFilePath = [self gameBoardDataPath];

    //returns YES if it wrote properly, otherwise returns NO
    return [data writeToFile:gameFilePath atomically:YES];
}

-(GameBoard *)loadGame{
    NSString *savedGamePath = [self gameBoardDataPath];
    NSMutableData *data = [[NSMutableData alloc]initWithContentsOfFile:savedGamePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    GameBoard *gameBoard = [unarchiver decodeObjectForKey:keySavedGame];
    
    return gameBoard;
}

-(BOOL)saveStats: (NSDictionary *)stats{
    NSLog(@"%@", stats);
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"GameStats"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@)",keyDifficulty , [stats objectForKey:keyDifficulty]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (!objects) {
        NSLog(@"Core Data didn't load");
    }
    
    NSLog(@"%@", objects);
    
    NSManagedObject *statsObject;

    //if it exists, set the first item as the managed object (should only return 1), else create it
    if ([objects count] > 0) {
        statsObject = [objects objectAtIndex:0];
    }else {
        statsObject = [NSEntityDescription insertNewObjectForEntityForName:@"GameStats" inManagedObjectContext:context];
        [statsObject setValue:[stats valueForKey:keyDifficulty] forKey:keyDifficulty];

        if ([keyDifficulty isEqualToString:@"Easy"]) {
            [statsObject setValue:[NSNumber numberWithInteger:0] forKey:keySortOrder];
        }else if ([keyDifficulty isEqualToString:@"Normal"]) {
            [statsObject setValue:[NSNumber numberWithInteger:1] forKey:keySortOrder];
        }else if ([keyDifficulty isEqualToString:@"Hard"]){
            [statsObject setValue:[NSNumber numberWithInteger:2] forKey:keySortOrder];
        }
    }

    /*
     When a game ends, need to record:
     0. Difficulty?? (easy, normal, or hard?)
     1. Game played++
     2. exploration percentage
     3. Win?
        a. losing streak stopped/ current win streak++
            1. if current win streak is longest, current win streak = longest win streak
        b. games won++
        c. average win time
        d. faster than 3rd fastest time?
            1. adjust the fastest times
     4. Loss? (didn't finish the game counts as a loss)
        a. winning streak stopped/ current losing streak++
            1. if current losing streak is longest, current lose streak = longest lose streak
        b. games lost++
     5.win percentage
     */
    
    //1. games played++
    NSInteger numInt = [[statsObject valueForKey:keyGamesPlayed]integerValue];
    numInt++;
    [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyGamesPlayed];
    
    //2. exploration percentage
    float objectFloat = [[statsObject valueForKey:keyExplorationPercent]floatValue];
    float statsFloat = [[stats valueForKey:keyPercentDone]floatValue];
    if (objectFloat) {
        statsFloat = (objectFloat + statsFloat) / 2;
    }
    [statsObject setValue:[NSNumber numberWithFloat:statsFloat] forKey:keyExplorationPercent];
    
    //3. Game Won
    if ([[stats valueForKey:keyGameWon]boolValue]) {
        //a. losing streak stopped/ current win streak++
        [statsObject setValue:[NSNumber numberWithInt:0] forKey:keyCurrentLoseStreak];
        numInt = [[statsObject valueForKey:keyCurrentWinStreak]integerValue];
        numInt++;
        [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyCurrentWinStreak];
        //1. if current win streak is longest, current win streak = longest win streak
        if (numInt > [[statsObject valueForKey:keyLongestWinStreak]integerValue]) {
            [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyLongestWinStreak];
        }
        
        //b. games won++
        numInt = [[statsObject valueForKey:keyGamesWon]integerValue];
        numInt++;
        [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyGamesWon];
        
        //c. average win time
        double statsDouble = [[stats valueForKey:keyTime]doubleValue];
        double objectDouble = [[statsObject valueForKey:keyAverageWinTime]doubleValue];
        if (objectDouble) {
            statsDouble = (objectDouble + statsDouble) / 2;
        }
        [statsObject setValue:[NSNumber numberWithDouble:statsDouble] forKey:keyAverageWinTime];
        
        //d. faster than 3rd fastest time?
        statsDouble = [[stats valueForKey:keyTime]doubleValue];
        objectDouble = [[statsObject valueForKey:keyThirdFastest]doubleValue];
        
        //if the stats don't exist, then make all three the fastest times
        if (!objectDouble) {
            [statsObject setValue:[NSNumber numberWithDouble:statsDouble] forKey:keyThirdFastest];
            [statsObject setValue:[NSNumber numberWithDouble:statsDouble] forKey:keySecondFastest];
            [statsObject setValue:[NSNumber numberWithDouble:statsDouble] forKey:keyFastest];
        }
        
        if (statsDouble < objectDouble) {
            //1. adjust the fastest times
            double third = statsDouble;
            double second = [[statsObject valueForKey:keySecondFastest]doubleValue];
            double first = [[statsObject valueForKey:keyFastest]doubleValue];
            double temp;
            
            if (third < second) {
                temp = third;
                third = second;
                second = temp;
            }
            if (second < first) {
                temp = second;
                second = first;
                first = temp;
            }
            
            [statsObject setValue:[NSNumber numberWithDouble:first] forKey:keyFastest];
            [statsObject setValue:[NSNumber numberWithDouble:second] forKey:keySecondFastest];
            [statsObject setValue:[NSNumber numberWithDouble:third] forKey:keyThirdFastest];
        }
        
    }else {  //4. Game Lost
        //a. winning streak stopped/ current losing streak++
        [statsObject setValue:[NSNumber numberWithInteger:0] forKey:keyCurrentWinStreak];
        numInt = [[statsObject valueForKey:keyCurrentLoseStreak]integerValue];
        numInt++;
        [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyCurrentLoseStreak];
        //1. if current losing streak is longest, current lose streak = longest lose streak
        if (numInt > [[statsObject valueForKey:keyLongestLoseStreak]integerValue]) {
            [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyLongestLoseStreak];
        }
        
        //b. games lost++
        numInt = [[statsObject valueForKey:keyGamesLost]integerValue];
        numInt++;
        [statsObject setValue:[NSNumber numberWithInteger:numInt] forKey:keyGamesLost];
    }
    
    //5. win percentage
    objectFloat = [[statsObject valueForKey:keyGamesWon]floatValue]*100 / [[statsObject valueForKey:keyGamesPlayed]floatValue];
    [statsObject setValue:[NSNumber numberWithFloat:objectFloat] forKey:keyWinPercent];
    
    if ([context save:&error]) {
        NSLog(@"stats: %@", statsObject);
        return YES;
    }
    
    NSLog(@"error saving context: %@", [error localizedDescription]);
    
    return NO;
}

-(NSArray*)getAllStats{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"GameStats"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:keySortOrder ascending:YES]];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (!objects) {
        NSLog(@"Core Data didn't load");
    }
    
    if ([objects count] < 3) {
        NSArray *diffArray = [NSArray arrayWithObjects:@"Easy", @"Normal", @"Hard", nil];
        NSPredicate *predicate;
        for (int i = 0; i < 3; i++) {
            request = [[NSFetchRequest alloc]initWithEntityName:@"GameStats"];
            predicate = [NSPredicate predicateWithFormat:@"(%K = %@)",keyDifficulty , diffArray[i]];
            [request setPredicate:predicate];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:keySortOrder ascending:YES]];
            
            objects = [context executeFetchRequest:request error:&error];
            if (!objects) {
                NSLog(@"Core Data didn't load");
            }
            
            if ([objects count] < 1) {
                NSManagedObject *statsObject;
                statsObject = [NSEntityDescription insertNewObjectForEntityForName:@"GameStats" inManagedObjectContext:context];
                [statsObject setValue:diffArray[i] forKey:keyDifficulty];
                [statsObject setValue:[NSNumber numberWithInteger:i] forKey:keySortOrder];
            }
        }
        
        objects = [context executeFetchRequest:request error:&error];
        if (!objects) {
            NSLog(@"Core Data didn't load");
        }

    }
    
    for (int i = 0; i < objects.count; i++) {
        NSLog(@"%@", [objects[i] valueForKey:keyDifficulty]);
    }
    return objects;
}

-(BOOL)statsDocReady{
    if (self.document.documentState == UIDocumentStateNormal) {
        [self.document managedObjectContext];
    }
    
    return NO;
}

-(BOOL)retrieveStatsEntityArray{
    //needs to be implemented
    return NO;
}

-(NSString *)gameBoardDataPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *dataFile = [paths[0]stringByAppendingPathComponent:@"DataStorage"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dataFile]) {
        NSLog(@"Directory needed to be created");
        NSError *error;
        BOOL success = [fileManager createDirectoryAtPath:dataFile withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            NSLog(@"Did not create directory file: %@", [error localizedDescription]);
        }
    }
    
    dataFile = [dataFile stringByAppendingPathComponent:@"SavedGame"];
    
    if (![fileManager fileExistsAtPath:dataFile]) {
        NSLog(@"File needed to be created");
        NSError *error;
        BOOL success = [fileManager createFileAtPath:dataFile contents:nil attributes:nil];
        if (!success) {
            NSLog(@"Did not create game file: %@", [error localizedDescription]);
        }
    }
    
    return dataFile;
}

-(NSString *)statsDataPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *dataFile = [paths[0]stringByAppendingPathComponent:@"DataStorage"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:dataFile]) {
        NSLog(@"Directory needed to be created");
        NSError *error;
        BOOL success = [fileManager createDirectoryAtPath:dataFile withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            NSLog(@"Did not create directory file: %@", [error localizedDescription]);
        }
    }
    
    dataFile = [dataFile stringByAppendingPathComponent:@"StatsStorage"];
    
    if (![fileManager fileExistsAtPath:dataFile]) {
        NSLog(@"File needed to be created");
        NSError *error;
        BOOL success = [fileManager createFileAtPath:dataFile contents:nil attributes:nil];
        if (!success) {
            NSLog(@"Did not create game file: %@", [error localizedDescription]);
        }
    }
    
    return dataFile;
}


@end
