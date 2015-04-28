//
//  ViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 3/9/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "MainWindowViewController.h"
#import "CellButton.h"
#import "GameBoard.h"
#import "Constants.h"
#import <AudioToolbox/AudioServices.h>
#import "DataManager.h"

@interface MainWindowViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numberOfMinesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *StartNewGameButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *buttonView;
@property (strong, nonatomic) GameBoard *gameBoard;
@property (strong, nonatomic) UIImageView *splashView;
@property BOOL loadingGame;

@end


@implementation MainWindowViewController

#pragma mark - View and App functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *defaults = @{keyDifficulty: [[NSArray alloc]initWithObjects:@16, @16, @40, nil],
                               keyVibrate: @YES,
                               keyQuickOpen: @YES,
                               keyPortraitLock: @NO,
                               keyPressLength: @0.35};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.buttonView = [[UIView alloc]init];
    [self.adBanner setBackgroundColor: [UIColor darkGrayColor]];
    [self.numberOfMinesLabel setFont: [UIFont fontWithName:@"DBLCDTempBlack" size:25]];
    [self.timerLabel setFont: [UIFont fontWithName:@"DBLCDTempBlack" size:25]];

    DataManager *dataManager = [DataManager sharedInstance];
    self.gameBoard = [dataManager loadGame];

    if (self.gameBoard != nil) {
        NSLog(@"Loaded board Rows: %ld, and Col: %ld", self.gameBoard.totalRows, self.gameBoard.totalColumns);
        [self makeBoard];
    }else{
        [self newGameButtonPressed:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self makeBoardAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)note {
    NSLog(@"app will resign active");
//    self.splashView = [[UIImageView alloc]initWithFrame:[self.view frame]];
//    [self.splashView setImage:[UIImage imageNamed:@"CellHidden"]];
//    [self.view addSubview:self.splashView];
//    [self.view bringSubviewToFront:self.splashView];
    
//    [self.buttonView setHidden:YES];
    [self.scrollView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidEnterBackground:(NSNotification*)note{
    [self.gameBoard stopTimer];

    NSLog(@"app did enter background");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.gameBoard.elapsedTime > 0 && !self.gameBoard.gameOver && ![self.gameBoard winner]) {
        [self.gameBoard startTimerWithOffset:YES];
    }
}

-(void)appDidBecomeActive:(NSNotification*)note {
    NSLog(@"app did become active");
    
    if (self.splashView) {
        [self.splashView removeFromSuperview];
    }
//    [self.buttonView setHidden:NO];
    [self.scrollView setHidden:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    if (self.gameBoard.elapsedTime > 0 && !self.gameBoard.gameOver) {
        [self.gameBoard startTimerWithOffset:YES];
    }

}


-(void)appWillTerminate:(NSNotification*)note {
    NSLog(@"app will terminate");
    
    DataManager *dataManager = [DataManager sharedInstance];
    if (![dataManager saveGame:self.gameBoard]) {
        NSLog(@"game board did NOT save");
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}


#pragma mark - Controller Functions
//makes the game board
-(void)makeBoard{
        
    for (int i = 0; i < self.gameBoard.totalRows; i++) {
        for (int j = 0; j < self.gameBoard.totalColumns; j++) {
            CellButton *btn = [[CellButton alloc]initWithCell:self.gameBoard.board[i][j] row:i andCol:j];
   
            [self.buttonView addSubview:btn];
            [btn setFrame:CGRectMake(j*60+15, i*60+15, 60, 60)];
            [btn addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpress:)];
            longPress.minimumPressDuration = [[[NSUserDefaults standardUserDefaults]objectForKey:keyPressLength] floatValue];
            [btn addGestureRecognizer:longPress];
            
            
            [self.gameBoard.board[i][j] addObserver:btn forKeyPath:keyImage options:NSKeyValueObservingOptionNew context:nil];
            [self.gameBoard.board[i][j] addObserver:btn forKeyPath:keyButtonTitle options:NSKeyValueObservingOptionNew context:nil];
            [self.gameBoard addObserver:btn forKeyPath:keyGameOver options:NSKeyValueObservingOptionNew context:nil];
//            [self.gameBoard addObserver:btn forKeyPath:keyExploded options:NSKeyValueObservingOptionNew context:nil];
            
        }
    }
    
    [self.gameBoard addObserver:self forKeyPath:keyTotalFlags options:NSKeyValueObservingOptionNew context:nil];
    [self.gameBoard addObserver:self forKeyPath:keyTime options:NSKeyValueObservingOptionNew context:nil];

    [self makeBoardAppearance];
}

-(void)makeBoardAppearance{
    [self.scrollView addSubview:self.buttonView];
    self.buttonView.frame = CGRectMake(0, 0, self.gameBoard.totalColumns*60+30, self.gameBoard.totalRows*60+30);
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=2.5;
    self.scrollView.contentSize = self.buttonView.frame.size;
    [self.scrollView setBackgroundColor:[UIColor darkGrayColor]];
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    self.numberOfMinesLabel.text = [NSString stringWithFormat:@"%ld", self.gameBoard.totMines - self.gameBoard.totFlags];
    self.timerLabel.text = [NSString stringWithFormat:@"%ld", self.gameBoard.time];

}

- (IBAction)newGameButtonPressed:(UIButton *)sender {

    [self.gameBoard stopTimer];
    
    if (!self.gameBoard.gameOver && self.gameBoard.elapsedTime > 0) {
        DataManager *manager = [DataManager sharedInstance];
        [manager saveStats:[self statsToSaveWithWinner:NO]];
    }
    self.gameBoard.time = 0;
    self.gameBoard.elapsedTime = 0;
    
    //remove all buttons (remove observers first)
    if (self.buttonView) {
        
        for(CellButton *subview in [self.buttonView subviews]) {
            if ([subview isKindOfClass:[CellButton class]]) {
                [subview.cell removeObserver:subview forKeyPath:keyImage];
                [subview.cell removeObserver:subview forKeyPath:keyButtonTitle];
                [self.gameBoard removeObserver:subview forKeyPath:keyGameOver];
                [subview removeFromSuperview];
            }
        }
        
    }
    
    NSLog(@"done removing cells");

    
    NSArray *boardSettings = [[NSUserDefaults standardUserDefaults]objectForKey:keyDifficulty];
    NSLog(@"%@", boardSettings);
    
    if (!self.gameBoard) {
        self.gameBoard = [[GameBoard alloc]initWithRows:[boardSettings[0] integerValue] andColumns:[boardSettings[1] integerValue] andNumberOfMines:[boardSettings[2] integerValue]];
    }else{
        [self.gameBoard newGameWithNumberOfRows:[boardSettings[0] integerValue] andColumns:[boardSettings[1] integerValue] andMines:[boardSettings[2] integerValue]];
    }
    
    
    [self makeBoard];
}

-(IBAction)cellButtonPressed:(CellButton *)sender {
    
    [self.gameBoard revealWithRow:sender.row andCol:sender.col];
    if (self.gameBoard.time == 0 && self.gameBoard.elapsedTime == 0) {
        [self.gameBoard startTimerWithOffset:NO];
    }
    
    if (self.gameBoard.gameOver) {
        [self endGameAsWinner:NO];
    }else if ([self.gameBoard winner]) {
        [self endGameAsWinner:YES];
    }
}

-(IBAction)longpress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        //check to make sure the longPress came from a CellButton
        if (sender.view.class == [CellButton class]) {
            CellButton *btn = (CellButton *)sender.view;
            [self.gameBoard toggleFlagWithRow:btn.row andColumn:btn.col];
            [btn animateCellButton];
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
    }
}

-(void)endGameAsWinner: (BOOL)winner{
    [self.gameBoard stopTimer];
    
    if (winner) {
        [self.gameBoard setGameOver:YES];
        NSString *winnerString = [NSString stringWithFormat:@"Time: %.3f", self.gameBoard.elapsedTime];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"YOU WIN!" message:winnerString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"New Game", nil];
        [alert show];
    }else if ([[NSUserDefaults standardUserDefaults] boolForKey:keyVibrate]){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    DataManager *manager = [DataManager sharedInstance];
    [manager saveStats:[self statsToSaveWithWinner:winner]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if ([keyPath isEqualToString:keyTime]) {
        self.timerLabel.text = [NSString stringWithFormat:@"%ld", self.gameBoard.time];
        
    }else if ([keyPath isEqualToString:keyTotalFlags]) {
        self.numberOfMinesLabel.text = [NSString stringWithFormat:@"%ld", self.gameBoard.totMines - self.gameBoard.totFlags];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier  isEqual: @"MenuSegue"]){
        [self.gameBoard stopTimer];
    }
}

-(NSDictionary*)statsToSaveWithWinner: (BOOL)winner{
    NSDictionary *statsToSave = @{
                                 keyDifficulty:     [NSString stringWithFormat:@"%@", self.gameBoard.difficulty],
                                 keyGameWon:        [NSNumber numberWithBool:winner],
                                 keyPercentDone:    [NSNumber numberWithFloat:[self.gameBoard getPercentFinished]],
                                 keyTime:           [NSNumber numberWithDouble:[self.gameBoard elapsedTime]]
                                 };
    
    return statsToSave;
}

//Handles the actions when "New Game" is pressed from UIAlert
-(void)alertView: (UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self newGameButtonPressed:[alertView.subviews lastObject]];
    }
}

#pragma mark - UIScrollView Delegate Methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.buttonView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
}

#pragma mark - ADBannerView Delagate Methods
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
    NSLog(@"bannerViewDidLoadAd");
    if (banner.hidden) {
        banner.hidden = NO;
    }
}


-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
    //need some other
    NSLog(@"didFailtoReceiveAdWithError, error: %@", error);
    banner.hidden = YES;
}


@end
