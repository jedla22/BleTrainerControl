//
//  CalibrationViewController.m
//  BleTrainerControl
//
//  Created by William Minol on 04/09/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import "CalibrationViewController.h"

#import "AppDelegate.h"

@interface CalibrationViewController ()

@end

@implementation CalibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
