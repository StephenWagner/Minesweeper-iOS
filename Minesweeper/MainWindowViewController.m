//
//  ViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 3/9/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "MainWindowViewController.h"
//#import "CellButton.h"
#import "GameBoard.h"
#import "Constants.h"
#import <AudioToolbox/AudioServices.h>
#import "DataManager.h"
#import "AdBannerDelegate.h"
#import "HintPopUpMenuView.h"

@interface MainWindowViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numberOfMinesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *StartNewGameButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *hintBarButton;
@property (strong, nonatomic) UIView *buttonView;
@property (strong, nonatomic) GameBoard *gameBoard;
@property (strong, nonatomic) UIImageView *splashView;
@property (strong, nonatomic) NSMutableArray *buttonArray;
@property BOOL wantEmptySpaceHint;
@property BOOL wantMinedSpaceHint;
@property BOOL loadingGame;
@property (strong, nonatomic) HintPopUpMenuView *menuPopUpView;

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
    
    [self.numberOfMinesLabel setFont: [UIFont fontWithName:@"DBLCDTempBlack" size:25]];
    [self.timerLabel setFont: [UIFont fontWithName:@"DBLCDTempBlack" size:25]];

    self.adBanner.backgroundColor = [UIColor lightGrayColor];
    self.adBanner.delegate = self;

    DataManager *dataManager = [DataManager sharedInstance];
    self.gameBoard = [dataManager loadGame];

    if (self.gameBoard != nil) {
        [self makeBoardUiAfterModelIsSet];
    }else{
        [self pressedNewGameButton:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self makeBoardAppearance];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.gameBoard.elapsedTime > 0 && !self.gameBoard.gameOver && ![self.gameBoard winner]) {
        [self.gameBoard startTimerWithOffset:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.gameBoard stopTimer];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)note {
    NSLog(@"app will resign active");
    self.splashView = [[UIImageView alloc]initWithFrame:[self.view frame]];
    [self.splashView setImage:[UIImage imageNamed:@"CellHidden"]];
    [self.view addSubview:self.splashView];
    [self.view bringSubviewToFront:self.splashView];
    
//    [self.buttonView setHidden:YES];
    [self.scrollView setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)appDidEnterBackground:(NSNotification*)note{
    [self.gameBoard stopTimer];

    NSLog(@"app did enter background");
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
#define buttonSize 60
#define buttonOffset 30
//makes the game board
-(void)makeBoardUiAfterModelIsSet{
    NSArray *boardSettings = [[NSUserDefaults standardUserDefaults] objectForKey:keyDifficulty];
    NSInteger numRows = [boardSettings[0] integerValue];
    NSInteger numCol = [boardSettings[1] integerValue];
    self.buttonArray = [[NSMutableArray alloc]initWithCapacity:numRows];
    
    for (int i=0; i < numRows; i++) {
        self.buttonArray[i] = [[NSMutableArray alloc]initWithCapacity:numCol];
    }

    NSInteger row;
    NSInteger col;
    
    for (NSArray *array in self.gameBoard.board) {
        for (Cell *cell in array) {
            row = cell.row;
            col = cell.col;
            
            UIButton *btn = [[UIButton alloc]init];
            self.buttonArray[row][col] = btn;

            [self.buttonView addSubview:btn];
            [btn setFrame:CGRectMake(col*buttonSize+buttonOffset, row*buttonSize+buttonOffset, buttonSize, buttonSize)];
            [btn setBackgroundImage:cell.image forState:UIControlStateNormal];
            [btn setUserInteractionEnabled:!_gameBoard.gameOver];
            [self setButtonTitleTextAndColorUsingCell:cell];
            [btn addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpress:)];
            longPress.minimumPressDuration = [[[NSUserDefaults standardUserDefaults]objectForKey:keyPressLength] floatValue];
            
            [btn addGestureRecognizer:longPress];
            btn.adjustsImageWhenHighlighted = NO;
            
            [self.gameBoard.board[row][col] addObserver:self forKeyPath:keyImage options:NSKeyValueObservingOptionNew context:nil];
            [self.gameBoard.board[row][col] addObserver:self forKeyPath:keyButtonTitle options:NSKeyValueObservingOptionNew context:nil];
            
            }
    }
    
    [self.gameBoard addObserver:self forKeyPath:keyTotalFlags options:NSKeyValueObservingOptionNew context:nil];
    [self.gameBoard addObserver:self forKeyPath:keyTime options:NSKeyValueObservingOptionNew context:nil];
    [self.gameBoard addObserver:self forKeyPath:keyGameOver options:NSKeyValueObservingOptionNew context:nil];

    [self makeBoardAppearance];
}

-(void)makeBoardAppearance{
    [self.scrollView addSubview:self.buttonView];
    CGFloat scale = self.scrollView.zoomScale;
    float width = scale*(self.gameBoard.totalColumns*buttonSize+(2*buttonOffset));
    float height = scale*(self.gameBoard.totalRows*buttonSize+(2*buttonOffset));
    self.buttonView.frame = CGRectMake(0, 0, width, height);
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=2.5;
    self.scrollView.contentSize = self.buttonView.frame.size;
    [self.scrollView setBackgroundColor:[UIColor darkGrayColor]];
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    self.numberOfMinesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gameBoard.totMines - self.gameBoard.totFlags];
    self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gameBoard.time];

}

- (IBAction)pressedNewGameButton:(UIButton *)sender {

    [self.gameBoard stopTimer];
    
    if (!self.gameBoard.gameOver && self.gameBoard.elapsedTime > 0) {
        DataManager *manager = [DataManager sharedInstance];
        [manager saveStats:[self statsToSaveWithWinner:NO]];
    }

    [self createNewGameFromScratch];

}

-(void)createNewGameFromScratch{
    self.gameBoard.time = 0;
    self.gameBoard.elapsedTime = 0;
    
    //remove all buttons (remove observers first)
    if (self.buttonView) {
        
        for (NSArray *array in self.gameBoard.board) {
            for (Cell *cell in array) {
                [cell removeObserver:self forKeyPath:keyImage];
                [cell removeObserver:self forKeyPath:keyButtonTitle];
            }
        }
        
        [self.gameBoard removeObserver:self forKeyPath:keyGameOver];
        [self.gameBoard removeObserver:self forKeyPath:keyTotalFlags];
        [self.gameBoard removeObserver:self forKeyPath:keyTime];
        
        
        for(UIButton *subview in [self.buttonView subviews]) {
            if ([subview isMemberOfClass:[UIButton class]]) {
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
    
    
    [self makeBoardUiAfterModelIsSet];
}

-(IBAction)cellButtonPressed:(UIButton *)sender {
    NSArray *coords= [self findWhichButton:sender];
    NSInteger row = [coords[0] integerValue];
    NSInteger col = [coords[1] integerValue];
    
    if (self.wantEmptySpaceHint) {
        Cell *hintCell = [self.gameBoard getSurroundingEmptySpaceHintUsingRow:row andCol:col];
        Cell *pressedCell = self.gameBoard.board[row][col];
        if (hintCell && hintCell != pressedCell) {
            hintCell.image = [UIImage imageNamed:@"CellEmptySpaceHint"];
        }
        [self toggleHint:&_wantEmptySpaceHint];
        return;
    }
    
    if (self.wantMinedSpaceHint) {
        Cell *hintCell = [self.gameBoard getSurroundingMinedSpaceHintUsingRow:row andCol:col];
        Cell *pressedCell = self.gameBoard.board[row][col];
        if (hintCell && hintCell != pressedCell) {
            hintCell.image = [UIImage imageNamed:@"CellMinedSpaceHint"];
        }
        [self toggleHint:&_wantMinedSpaceHint];
        return;
    }
    
    [self.gameBoard revealWithRow:row andCol:col];
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
        //check to make sure the longPress came from a UIButton
        if (sender.view.class == [UIButton class]) {
            UIButton *btn = (UIButton *)sender.view;
            NSArray *coords = [self findWhichButton:btn];
            NSInteger row = [coords[0] integerValue];
            NSInteger col = [coords[1] integerValue];
            Cell *cell = self.gameBoard.board[row][col];
            [self.gameBoard toggleFlagWithRow:row andColumn:col];
            
            [self animateButton:btn withCell:cell];
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
    
    Cell *cell;
    UIButton *btn;
    
    if ([object isMemberOfClass:[Cell class]]) {
        cell = object;
        btn = self.buttonArray[cell.row][cell.col];
    }
    
    if ([keyPath isEqualToString:keyImage]) {
        [btn setBackgroundImage:[change objectForKey:@"new"] forState:UIControlStateNormal];
        
        if (cell.minesClose == 0 && !cell.hidden) {//disable user interaction when it has been revealed and has no mines close to it
            btn.userInteractionEnabled = NO;
        }
    }
    
    if ([keyPath isEqualToString:keyButtonTitle]) {
        [self setButtonTitleTextAndColorUsingCell:cell];
    }
    
    if ([keyPath isEqualToString:keyGameOver]) {
        [self setButtonsForGameOver];
    }


    if ([keyPath isEqualToString:keyTime]) {
        self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gameBoard.time];
        
    }else if ([keyPath isEqualToString:keyTotalFlags]) {
        self.numberOfMinesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gameBoard.totMines - self.gameBoard.totFlags];
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
        [self pressedNewGameButton:[alertView.subviews lastObject]];
    }
}



#pragma mark - CellButton Controller functions

-(NSArray*)findWhichButton: (UIButton *)button{
    NSMutableArray *rtnArray = [[NSMutableArray alloc] initWithCapacity:2];
    
    for (int i = 0; i < self.buttonArray.count; i++){
        NSMutableArray *array = self.buttonArray[i];
        for (int j = 0; j < array.count; j++){
            //when the button is found, set the array items and break out of loop
            if (button == self.buttonArray[i][j]) {
                [rtnArray insertObject:[NSNumber numberWithInt:i] atIndex:0];
                [rtnArray insertObject:[NSNumber numberWithInt:j] atIndex:1];
                break;
            }
        }
    }
    
    return rtnArray;
}

-(void)setButtonsForGameOver{
    if (!self.gameBoard.gameOver) {
        return;
    }
    
    UIButton *btn;
    for (NSArray *array in self.gameBoard.board) {
        for (Cell *cell in array) {
            btn = self.buttonArray[cell.row][cell.col];
            [btn setUserInteractionEnabled:NO];
            if (cell.mined && !cell.flagged && !cell.blown) {
                [btn setImage:[UIImage imageNamed:@"CellBomb"] forState:UIControlStateNormal];
            }
        }
    }
    
}

-(void)setButtonTitleTextAndColorUsingCell:(Cell*)cell {
    UIButton *btn = self.buttonArray[cell.row][cell.col];
    
    [btn setTitle:cell.buttonTitle forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
    
    //set color of uibutton label
    switch ([cell.buttonTitle integerValue]) {
        case 1:
            [btn setTitleColor:[UIColor colorWithRed:0/225.0 green:0/225.0 blue:225/225.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 2:
            [btn setTitleColor:[UIColor colorWithRed:15/225.0 green:114/225.0 blue:1/225.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 3:
            [btn setTitleColor:[UIColor colorWithRed:251/255.0 green:0/255.0 blue:7/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 4:
            [btn setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:113/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 5:
            [btn setTitleColor:[UIColor colorWithRed:111/255.0 green:0/255.0 blue:2/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 6:
            [btn setTitleColor:[UIColor colorWithRed:14/255.0 green:112/255.0 blue:113/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 7:
            [btn setTitleColor:[UIColor colorWithRed:111/255.0 green:0/255.0 blue:113/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        case 8:
            [btn setTitleColor:[UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:100] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

-(void)animateButton: (UIButton*)btn withCell: (Cell*)cell {
    
    if (!cell.hidden) {
        return;
    }

    CGRect regFrame = btn.frame;
    CGRect newFrame = CGRectMake(btn.frame.origin.x - 60, btn.frame.origin.y - 60, btn.frame.size.width + 120, btn.frame.size.height + 120);
    [btn.superview bringSubviewToFront:btn];
    [btn setFrame:newFrame];
    
    [UIView animateWithDuration:0.05f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [btn setFrame:regFrame];
                     }
                     completion:nil];
}


#pragma mark - Hint Functions
- (IBAction)pressedHintButton:(UIBarButtonItem *)sender {
    if (sender.tintColor != NULL) {
        BOOL hint = (self.wantEmptySpaceHint)? self.wantEmptySpaceHint: self.wantMinedSpaceHint;
        [self toggleHint:&hint];
    }else{
        self.menuPopUpView = [[HintPopUpMenuView alloc]initWithFrame:self.scrollView.frame emptySpaceHintsRemaining:self.gameBoard.hintsRemaining];
        [self.view addSubview:self.menuPopUpView];
        [self.menuPopUpView.emptySpaceHintButton addTarget:self action:@selector(emptySpaceHintButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuPopUpView.minedSpaceHintButton addTarget:self action:@selector(minedSpaceHintButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuPopUpView animateMenuOnScreen];        
    }
}

-(void)emptySpaceHintButtonPressed: (UIButton*)sender{
    NSLog(@"emptySpaceHintButtonPressed");
    [self.menuPopUpView removeFromSuperview];
    [self toggleHint:&_wantEmptySpaceHint];
}

-(void)minedSpaceHintButtonPressed: (UIButton*)sender{
    NSLog(@"minedSpaceHintButtonPressed");
    [self.menuPopUpView removeFromSuperview];
    [self toggleHint:&_wantMinedSpaceHint];
}

-(void)toggleHint:(BOOL*)hint{
    if (_hintBarButton.tintColor == NULL) {
        _hintBarButton.tintColor = [UIColor redColor];
        *hint = YES;
    }else{
        _hintBarButton.tintColor = NULL;
        *hint = NO;
    }
}



#pragma mark - UIScrollView Delegate Methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.buttonView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"\nScale: %f\nView: %@", scale, view);
    NSLog(@"Scrollview scale: %f", self.scrollView.zoomScale);
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
