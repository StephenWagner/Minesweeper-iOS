//
//  HintsPopUpViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/22/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "HintsPopUpViewController.h"

@interface HintsPopUpViewController ()
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *minedHintsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyHintsLabel;
@property (weak, nonatomic) IBOutlet UIButton *minedSpaceHintBtn;
@property (weak, nonatomic) IBOutlet UIButton *emptySpaceHintsBtn;
@property (weak, nonatomic) IBOutlet UIButton *buyHintsBtn;

@end

@implementation HintsPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.buyHintsBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
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

@end
