//
//  ConnectionViewController.m
//  BleTrainerControl
//
//  Created by William Minol on 28/08/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import "ConnectionViewController.h"

#import "AppDelegate.h"

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

@synthesize peripheralSelected;


#define NB_SECTIONS 14

#define SECTION_PAGE_16 2
#define NB_ROWS_SECTION_PAGE_16 6
#define ROW_PAGE_16_EQUIPMENT_TYPE 0
#define ROW_PAGE_16_ELAPSED_TIME 1
#define ROW_PAGE_16_DISTANCE_TRAVELED 2
#define ROW_PAGE_16_SPEED 3
#define ROW_PAGE_16_HEART_RATE 4
#define ROW_PAGE_16_VIRTUAL_SPEED 5


#define SECTION_PAGE_17 3
#define NB_ROWS_SECTION_PAGE_17 3
#define ROW_PAGE_17_CYCLE_LENGTH 0
#define ROW_PAGE_17_INCLINE 1
#define ROW_PAGE_17_RESISTANCE_LEVEL 2


#define SECTION_PAGE_25 4
#define NB_ROWS_SECTION_PAGE_25 4
#define ROW_PAGE_25_UPDATE_EVENT_COUNT 0
#define ROW_PAGE_25_INSTANTANEOUS_CADENCE 1
#define ROW_PAGE_25_ACCUMULATED_POWER 2
#define ROW_PAGE_25_INSTANTANEOUS_POWER 3


#define SECTION_PAGE_54 9
#define NB_ROWS_SECTION_PAGE_54 2
#define ROW_PAGE_54_MAXIMUM_RESISTANCE 0
#define ROW_PAGE_54_SUPPORTED_MODE 1


#define SECTION_PAGE_55 10
#define NB_ROWS_SECTION_PAGE_55 5
#define ROW_PAGE_55_USER_WEIGHT 0
#define ROW_PAGE_55_BICYCLE_WHEEL_DIAMETER_OFFSET 1
#define ROW_PAGE_55_BICYCLE_WEIGHT 2
#define ROW_PAGE_55_BICYCLE_WHEEL_DIAMETER 3
#define ROW_PAGE_55_GEAR_RATIO 4


#define SECTION_PAGE_71 11
#define NB_ROWS_SECTION_PAGE_71 4
#define ROW_PAGE_71_LAST_RECEIVED_COMMAND_ID 0
#define ROW_PAGE_71_SEQUENCE 1
#define ROW_PAGE_71_COMMAND_STATUS 2
#define ROW_PAGE_71_DATA 3


#define SECTION_PAGE_80 12
#define NB_ROWS_SECTION_PAGE_80 3
#define ROW_PAGE_80_HW_REVISION 0
#define ROW_PAGE_80_MANUFACTURER_ID 1
#define ROW_PAGE_80_MODEL_NUMBER 2


#define SECTION_PAGE_81 13
#define NB_ROWS_SECTION_PAGE_81 3
#define ROW_PAGE_81_SW_REVISION_SUPPLEMENTAL 0
#define ROW_PAGE_81_SW_REVISION_MAIN 1
#define ROW_PAGE_81_SERIAL_NUMBER 2




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    if(peripheralSelected != nil)
        self.title = peripheralSelected.name;
    
    [dataPagesTableView setDelegate:self];
    [dataPagesTableView setDataSource:self];
    
    
    Utils *utils = [[[Utils alloc] init] autorelease];
    NSArray *buttonsArray = [NSArray arrayWithObjects:trackResistanceButton, windResistanceButton, basicResistanceButton, targetPowerButton, calibrationButton, requestPage54Button, requestPage55Button, nil];
    for(UIButton *btn in buttonsArray)
    {
        [btn setBackgroundImage:[utils imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[utils imageWithColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]] forState:UIControlStateNormal];
    }
}




-(void)viewWillAppear:(BOOL)animated
{
    if(isDisplayingModalView == FALSE)
    {
        if(peripheralSelected != nil)
        {
            [self connect];
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Device doesn't exist" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease];
            [alert show];
            
            [self.navigationController popViewControllerAnimated:TRUE];
        }
        
        getDataTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshData) userInfo:nil repeats:TRUE];
    }
    else
    {
        isDisplayingModalView = FALSE;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(isDisplayingModalView == FALSE)
    {
        [self disconnect];
        
        if(getDataTimer != nil)
        {
            //Stop discovery timer
            if([getDataTimer isValid] == TRUE)
                [getDataTimer invalidate];
            
            getDataTimer = nil;
        }
    }
}

-(void)connect
{
    if(peripheralSelected != nil)
    {
        if([peripheralSelected respondsToSelector:@selector(identifier)])
            [appDelegate.btleTrainerManager connectWithUUID:[peripheralSelected.identifier UUIDString]];
    }
}

-(void)disconnect
{
    if(peripheralSelected != nil)
    {
        [appDelegate.btleTrainerManager disconnect];
    }
}

-(void)refreshData
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
    {
        [statusValueLabel setText:@"Connected"];
        [statusValueLabel setTextColor:[UIColor greenColor]];
        
        
    }
    else
    {
        //Try to reconnect
        [self connect];
        
        [statusValueLabel setText:@"Disconnected"];
        [statusValueLabel setTextColor:[UIColor redColor]];
    }
    
    [dataPagesTableView reloadData];
}




//TABLE VIEW DELEGATE

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NB_SECTIONS;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_PAGE_16:
            return NB_ROWS_SECTION_PAGE_16;
            break;
        case SECTION_PAGE_17:
            return NB_ROWS_SECTION_PAGE_17;
            break;
        case SECTION_PAGE_25:
            return NB_ROWS_SECTION_PAGE_25;
            break;
        case SECTION_PAGE_54:
            return NB_ROWS_SECTION_PAGE_54;
            break;
        case SECTION_PAGE_55:
            return NB_ROWS_SECTION_PAGE_55;
            break;
        case SECTION_PAGE_71:
            return NB_ROWS_SECTION_PAGE_71;
            break;
        case SECTION_PAGE_80:
            return NB_ROWS_SECTION_PAGE_80;
            break;
        case SECTION_PAGE_81:
            return NB_ROWS_SECTION_PAGE_81;
            break;
        default:
            break;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case SECTION_PAGE_16:
            return @"Page 16 - General FE data";
            break;
        case SECTION_PAGE_17:
            return @"Page 17 - General settings";
            break;
        case SECTION_PAGE_25:
            return @"Page 25 - Specific trainer";
            break;
        case SECTION_PAGE_54:
            return @"Page 54 - FE capabilities";
            break;
        case SECTION_PAGE_55:
            return @"Page 55 - User configuration";
            break;
        case SECTION_PAGE_71:
            return @"Page 71 - Command status";
            break;
        case SECTION_PAGE_80:
            return @"Page 80 - Manufacturer's identification";
            break;
        case SECTION_PAGE_81:
            return @"Page 81 - Product information";
            break;
        default:
            break;
    }
    
    return @"";
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    [view setTintColor:[UIColor darkGrayColor]];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
}

//For iOS 6
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Background color
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:0.5]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    //Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        //Init cell
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //Background color
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:0.5]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    }
    else
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    }
    
    
    //Background color label
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    
    
    //No indicator
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    //No selection
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    
    switch (indexPath.section)
    {
        case SECTION_PAGE_16:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_16_EQUIPMENT_TYPE:
                {
                    [cell.textLabel setText:@"Equipment type"];
                    if(appDelegate.btleTrainerManager.equipmentTypeString != nil)
                        [cell.detailTextLabel setText:appDelegate.btleTrainerManager.equipmentTypeString];
                    else
                        [cell.detailTextLabel setText:@"-"];
                }
                    break;
                case ROW_PAGE_16_ELAPSED_TIME:
                {
                    [cell.textLabel setText:@"Elapsed time"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li seconds", (long)appDelegate.btleTrainerManager.elapsedTimeSeconds]];
                }
                    break;
                case ROW_PAGE_16_DISTANCE_TRAVELED:
                {
                    [cell.textLabel setText:@"Distance traveled"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li m", (long)appDelegate.btleTrainerManager.distanceTraveledMeters]];
                }
                    break;
                case ROW_PAGE_16_SPEED:
                {
                    [cell.textLabel setText:@"Speed"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.1f km/h", appDelegate.btleTrainerManager.speedKmH]];
                }
                    break;
                case ROW_PAGE_16_HEART_RATE:
                {
                    [cell.textLabel setText:@"Heart rate"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li BPM", (long)appDelegate.btleTrainerManager.heartRateBPM]];
                }
                    break;
                case ROW_PAGE_16_VIRTUAL_SPEED:
                {
                    [cell.textLabel setText:@"Virtual speed"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", appDelegate.btleTrainerManager.virtualSpeed? @"True":@"False"]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_17:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_17_CYCLE_LENGTH:
                {
                    [cell.textLabel setText:@"Cycle length"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2f m", appDelegate.btleTrainerManager.cycleLengthM]];
                }
                    break;
                case ROW_PAGE_17_INCLINE:
                {
                    [cell.textLabel setText:@"Incline"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2f %%", appDelegate.btleTrainerManager.inclinePercent]];
                }
                    break;
                case ROW_PAGE_17_RESISTANCE_LEVEL:
                {
                    [cell.textLabel setText:@"Resistance level"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.1f %%", appDelegate.btleTrainerManager.resistanceLevelPercent]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_25:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_25_UPDATE_EVENT_COUNT:
                {
                    [cell.textLabel setText:@"Update event count"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.updateEventCount]];
                }
                    break;
                case ROW_PAGE_25_INSTANTANEOUS_CADENCE:
                {
                    [cell.textLabel setText:@"Instantaneous cadence"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li RPM", (long)appDelegate.btleTrainerManager.cadenceRPM]];
                }
                    break;
                case ROW_PAGE_25_ACCUMULATED_POWER:
                {
                    [cell.textLabel setText:@"Accumulated power"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li W", (long)appDelegate.btleTrainerManager.accumulatedPowerW]];
                }
                    break;
                case ROW_PAGE_25_INSTANTANEOUS_POWER:
                {
                    [cell.textLabel setText:@"Instantaneous power"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li W", (long)appDelegate.btleTrainerManager.powerW]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_54:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_54_MAXIMUM_RESISTANCE:
                {
                    [cell.textLabel setText:@"Maximum resistance"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li N", (long)appDelegate.btleTrainerManager.maximumResistanceN]];
                }
                    break;
                case ROW_PAGE_54_SUPPORTED_MODE:
                {
                    [cell.textLabel setText:@"Supported mode(s)"];
                    if(appDelegate.btleTrainerManager.supportedMode != nil)
                        [cell.detailTextLabel setText:appDelegate.btleTrainerManager.supportedMode];
                    else
                        [cell.detailTextLabel setText:@"-"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_55:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_55_USER_WEIGHT:
                {
                    [cell.textLabel setText:@"User weight"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.0f kg", appDelegate.btleTrainerManager.userWeightKg]];
                }
                    break;
                case ROW_PAGE_55_BICYCLE_WHEEL_DIAMETER_OFFSET:
                {
                    [cell.textLabel setText:@"Bicycle wheel diameter offset"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li mm", (long)appDelegate.btleTrainerManager.bicycleWheelDiameterOffsetMm]];
                }
                    break;
                case ROW_PAGE_55_BICYCLE_WEIGHT:
                {
                    [cell.textLabel setText:@"Bicycle weight"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2f kg", appDelegate.btleTrainerManager.bicycleWeightKg]];
                }
                    break;
                case ROW_PAGE_55_BICYCLE_WHEEL_DIAMETER:
                {
                    [cell.textLabel setText:@"Bicycle wheel diameter"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2f m", appDelegate.btleTrainerManager.bicycleWheelDiameterM]];
                }
                    break;
                case ROW_PAGE_55_GEAR_RATIO:
                {
                    [cell.textLabel setText:@"Gear ratio"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2f", appDelegate.btleTrainerManager.gearRatio]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_71:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_71_LAST_RECEIVED_COMMAND_ID:
                {
                    [cell.textLabel setText:@"Last received command ID"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Page %li", (long)appDelegate.btleTrainerManager.lastReceivedCommandID]];
                }
                    break;
                case ROW_PAGE_71_SEQUENCE:
                {
                    [cell.textLabel setText:@"Sequence"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.sequence]];
                }
                    break;
                case ROW_PAGE_71_COMMAND_STATUS:
                {
                    [cell.textLabel setText:@"Command status"];
                    if(appDelegate.btleTrainerManager.commandStatusString != nil)
                        [cell.detailTextLabel setText:appDelegate.btleTrainerManager.commandStatusString];
                    else
                        [cell.detailTextLabel setText:@"-"];
                }
                    break;
                case ROW_PAGE_71_DATA:
                {
                    [cell.textLabel setText:@"Data"];
                    if(appDelegate.btleTrainerManager.dataString != nil)
                        [cell.detailTextLabel setText:appDelegate.btleTrainerManager.dataString];
                    else
                        [cell.detailTextLabel setText:@"-"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_80:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_80_HW_REVISION:
                {
                    [cell.textLabel setText:@"HW revision"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.hwRevision]];
                }
                    break;
                case ROW_PAGE_80_MANUFACTURER_ID:
                {
                    [cell.textLabel setText:@"Manufacturer ID"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.manufacturerID]];
                }
                    break;
                case ROW_PAGE_80_MODEL_NUMBER:
                {
                    [cell.textLabel setText:@"Model number"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.modelNumber]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case SECTION_PAGE_81:
        {
            switch (indexPath.row)
            {
                case ROW_PAGE_81_SW_REVISION_SUPPLEMENTAL:
                {
                    [cell.textLabel setText:@"SW revision supplemental"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.swRevisionSupplemental]];
                }
                    break;
                case ROW_PAGE_81_SW_REVISION_MAIN:
                {
                    [cell.textLabel setText:@"SW revision main"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.swRevisionMain]];
                }
                    break;
                case ROW_PAGE_81_SERIAL_NUMBER:
                {
                    [cell.textLabel setText:@"Serial number"];
                    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%li", (long)appDelegate.btleTrainerManager.serialNumber]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



-(IBAction)onBasicResistance:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
    {
        BasicResistanceViewController *basicResistanceViewController = [[[BasicResistanceViewController alloc] init] autorelease];
        [self openModalWithRootViewlController:basicResistanceViewController];
    }
}

-(IBAction)onTargetPower:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
    {
        TargetPowerViewController *targetPowerViewController = [[[TargetPowerViewController alloc] init] autorelease];
        [self openModalWithRootViewlController:targetPowerViewController];
    }
}

-(IBAction)onWindResistance:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
    {
        WindResistanceViewController *windResistanceViewController = [[[WindResistanceViewController alloc] init] autorelease];
        [self openModalWithRootViewlController:windResistanceViewController];
    }
}

-(IBAction)onTrackResistance:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
    {
        TrackResistanceViewController *trackResistanceViewController = [[[TrackResistanceViewController alloc] init] autorelease];
        [self openModalWithRootViewlController:trackResistanceViewController];
    }
}




//Calibration
-(IBAction)onCalibration:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
    {
        SpinDownCalibrationViewController *spinDownCalibrationViewController = [[[SpinDownCalibrationViewController alloc] init] autorelease];
        [self openModalWithRootViewlController:spinDownCalibrationViewController];
    }
}




-(void)openModalWithRootViewlController:(UIViewController *)rootViewController
{
    isDisplayingModalView = TRUE;
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    [navController.navigationBar setTranslucent:FALSE];
    if([navController.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        [navController.navigationBar setBarTintColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
        [navController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:76./255. green:164./255. blue:223./255. alpha:1.0]];
    }
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentViewController:navController animated:TRUE completion:nil];
}



//Request page
-(IBAction)requestPage54:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
        [appDelegate.btleTrainerManager sendRequestPage:54];
}

-(IBAction)requestPage55:(id)sender
{
    if(appDelegate.btleTrainerManager.isConnected == TRUE)
        [appDelegate.btleTrainerManager sendRequestPage:55];
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
