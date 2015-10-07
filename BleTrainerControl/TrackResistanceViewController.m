//
//  TrackResistanceViewController.m
//  BleTrainerControl
//
//  Created by William Minol on 03/09/2015.
//  Copyright (c) 2015 Tacx B.V. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "TrackResistanceViewController.h"

#import "AppDelegate.h"

@interface TrackResistanceViewController ()

@end

@implementation TrackResistanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //[gradeSlider setMinimumValue:-200.0];
    //[gradeSlider setMaximumValue:200.0];
    
    [maxRangeSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"maxRangeTrackResistance"]];
    
    [self onMaxRangeSwitchValueChanged:maxRangeSwitch];
    
    [coefficentOfRollingResistanceSlider setMinimumValue:0.0];
    [coefficentOfRollingResistanceSlider setMaximumValue:0.0127];
    
    
    //Default values
    [gradeSlider setValue:0.0];
    [coefficentOfRollingResistanceSlider setValue:0.0033];
    
    //Display values
    [self onSliderValueChanged:gradeSlider];
    [self onSliderValueChanged:coefficentOfRollingResistanceSlider];
    
    
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(onCloseButton:)] autorelease]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onCloseButton:(id)sender
{
    [super dismissViewControllerAnimated:TRUE completion:nil];
}

-(IBAction)onSendButton:(id)sender
{
    //Send grade for track resistance mode
    float gradeValue = gradeSlider.value;
    float coefficentOfRollingResistanceValue = coefficentOfRollingResistanceSlider.value;
    
    [appDelegate.btleTrainerManager sendTrackResistanceWithGrade:gradeValue rollingResistanceCoefficient:coefficentOfRollingResistanceValue];
}


-(IBAction)onSliderValueChanged:(id)sender
{
    if([sender isEqual:gradeSlider])
        [gradeValueLabel setText:[NSString stringWithFormat:@"%0.2f %%", gradeSlider.value]];
    
    if([sender isEqual:coefficentOfRollingResistanceSlider])
        [coefficentOfRollingResistanceValueLabel setText:[NSString stringWithFormat:@"%0.4f", coefficentOfRollingResistanceSlider.value]];
}


-(IBAction)onMaxRangeSwitchValueChanged:(id)sender
{
    if(maxRangeSwitch.on == TRUE)
    {
        [gradeSlider setMinimumValue:-200.0];
        [gradeSlider setMaximumValue:200.0];
    }
    else
    {
        [gradeSlider setMinimumValue:-20.0];
        [gradeSlider setMaximumValue:20.0];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:maxRangeSwitch.on forKey:@"maxRangeTrackResistance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
