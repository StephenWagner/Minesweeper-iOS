//
//  SettingsTableViewController.m
//  Minesweeper
//
//  Created by Stephen Wagner on 4/11/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Constants.h"

@interface SettingsTableViewController()

@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *quickOpenSwitch;
@property (weak, nonatomic) IBOutlet UISlider *pressDurationSlider;

@end


@implementation SettingsTableViewController

-(void)viewDidLoad{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    self.difficultyLabel.text = [defaults stringForKey:keyDifficulty];
    self.vibrateSwitch.on = [defaults boolForKey:keyVibrate];
    self.quickOpenSwitch.on = [defaults boolForKey:keyQuickOpen];
    self.pressDurationSlider.value = [defaults floatForKey:keyPressLength];
}

-(void)viewWillDisappear:(BOOL)animated {
    
}


- (IBAction)toggleSwitch:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.vibrateSwitch) {
        [defaults setBool:self.vibrateSwitch.on forKey:keyVibrate];
    }else if (sender == self.quickOpenSwitch) {
        [defaults setBool:self.quickOpenSwitch.on forKey:keyQuickOpen];
    }
    
    [defaults synchronize];
}

//touch up inside event-- will only fire when done sliding
- (IBAction)sliderChanged:(UISlider *)sender {
    NSLog(@"slider changed");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.pressDurationSlider.value forKey:keyPressLength];
    [defaults synchronize];
}



@end
