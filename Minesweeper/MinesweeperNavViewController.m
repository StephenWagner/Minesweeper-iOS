//
//  MinesweeperNavViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/7/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "MinesweeperNavViewController.h"
#import "MainWindowViewController.h"

@interface MinesweeperNavViewController ()

@end

@implementation MinesweeperNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSUInteger)supportedInterfaceOrientations{
    NSUInteger supported;
    if ([self.visibleViewController isMemberOfClass:[MainWindowViewController class]]) {
        supported = UIInterfaceOrientationMaskPortrait;
    }else{
        supported = UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
    return supported;
}

@end
