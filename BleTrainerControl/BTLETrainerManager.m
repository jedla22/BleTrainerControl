//
//  BTLETrainerManager.m
//  BleTrainerControl
//
//  Created by William Minol on 27/08/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import "BTLETrainerManager.h"

/**
 * Extending public interface by "private" methods
 */
@interface BTLETrainerManager()

/**
 * @brief Computation of checksum that is used to validate data message.Checksum is computed by recursively XOR of each single bytes in message with temporary result. At each step XOR is saved to temp result, that is used in next step to be XOR with next message byte.
 *
 * @param NSData *data : NSData consrtucted from message bytes (does noe include cheksum byte)
 * @return NSUInteger : computed checksum (in fact this should be unsigned char)
 */
-(NSUInteger)computeChecksum:(NSData *)data;

@end

@implementation BTLETrainerManager

@synthesize calibrationStarted;

//Page 1
@synthesize zeroOffsetCalibrationResponse, zeroOffsetResponse, spinDownCalibrationResponse, spinDownTimeResponseSeconds, temperatureResponseDegC;
//Page 2
@synthesize zeroOffsetCalibrationStatus, speedCondition, spinDownCalibrationStatus, temperatureCondition, targetSpinDownTimeSeconds, targetSpeedKmH, currentTemperatureDegC;
//Page 16
@synthesize equipmentTypeString, equipmentType, elapsedTimeSeconds, speedKmH, distanceTraveledMeters, heartRateBPM, virtualSpeed;
//Page 17
@synthesize cycleLengthM, inclinePercent, resistanceLevelPercent;
//Page 25
@synthesize accumulatedPowerW, updateEventCount, powerW, cadenceRPM;
//Page 48
@synthesize totalResistancePercent;
//Page 49
@synthesize targetPowerW;
//Page 50
@synthesize windSpeedKmH, windResistanceCoefficientKgM, draftingFactor;
//Page 51
@synthesize gradePercent, rollingResistanceCoefficient;
//Page 54
@synthesize maximumResistanceN, supportedMode;
//Page 55
@synthesize userWeightKg, bicycleWeightKg, bicycleWheelDiameterM, bicycleWheelDiameterOffsetMm, gearRatio;
//Page 71
@synthesize lastReceivedCommandID, sequence, commandStatus, commandStatusString, dataString;
//Page 80
@synthesize hwRevision, manufacturerID, modelNumber;
//Page 81
@synthesize serialNumber, swRevisionMain, swRevisionSupplemental;


#define DEFAULT_CIRCUMFERENCE_MM 2000.0

-(id)init
{
    if(self = [super init])
    {
        manager = [[BTLEManager alloc] init];
        [manager setBtleManagerDelegate:self];
        
        utils = [[Utils alloc] init];
        
        [self resetAllData];
    }
    
    return self;
}

-(void)startScanningAll
{
    //Scan for primary service of cycleops powerbeam bluetooth
    [manager startScanningWithServicesUUIDArray:nil];
}

-(void)startScanning
{
    //Scan for primary service of cycleops powerbeam bluetooth
    [manager startScanningWithServicesUUIDArray:[NSArray arrayWithObjects:[CBUUID UUIDWithString:TACX_FEC_PRIMARY_SERVICE], [CBUUID UUIDWithString:TACX_VORTEX_PRIMARY_SERVICE], nil]];
}

-(void)stopScanning
{
    //Stop scanning
    [manager stopScanning];
}


-(void)connectWithUUID:(NSString *)UUIDToConnect
{
    [manager retrievePeripheralAndConnectWithUUID:UUIDToConnect];
}

-(void)disconnect
{
    [manager disconnectPeripheral];
}


-(void)resetAllData
{
    calibrationStarted = FALSE;
    
    //Page 1
    zeroOffsetCalibrationResponse = -1;
    spinDownCalibrationResponse = -1;
    temperatureResponseDegC = -1;
    zeroOffsetResponse = -1;
    spinDownTimeResponseSeconds = -1;
    
    //Page 2
    zeroOffsetCalibrationStatus = -1;
    spinDownCalibrationStatus = -1;
    temperatureCondition = -1;
    speedCondition = -1;
    currentTemperatureDegC = -1;
    targetSpeedKmH = -1;
    targetSpinDownTimeSeconds = -1;
    
    //Page 16
    elapsedTimeSeconds = 0.0;
    distanceTraveledMeters = 0;
    speedKmH = 0.0;
    heartRateBPM = 0;
    equipmentType = 0;
    equipmentTypeString = nil;
    virtualSpeed = FALSE;
    
    //Page 17
    cycleLengthM = 0.0;
    inclinePercent = 0.0;
    resistanceLevelPercent = 0.0;
    
    //Page 25
    updateEventCount = 0;
    cadenceRPM = 0;
    accumulatedPowerW = 0;
    powerW = 0;
    
    //Page 48
    totalResistancePercent = 0.0;
    
    //Page 49
    targetPowerW = 0.0;
    
    //Page 50
    windResistanceCoefficientKgM = 0.0;
    windSpeedKmH = 0.0;
    draftingFactor = 0.0;
    
    //Page 51
    gradePercent = 0.0;
    rollingResistanceCoefficient = 0.0;
    
    //Page 54
    maximumResistanceN = 0;
    supportedMode = nil;
    
    //Page 55
    userWeightKg = 0.0;
    bicycleWheelDiameterOffsetMm = 0;
    bicycleWeightKg = 0.0;
    bicycleWheelDiameterM = 0.0;
    gearRatio = 0.0;
    
    //Page 71
    lastReceivedCommandID = 0;
    sequence = 0;
    commandStatus = 0;
    commandStatusString = nil;
    dataString = nil;
    
    //Page 80
    hwRevision = 0;
    manufacturerID = 0;
    modelNumber = 0;
    
    //Page 81
    swRevisionSupplemental = 0;
    swRevisionMain = 0;
    serialNumber = 0;
}




-(NSMutableArray *)getDiscoveredPeripheralArray
{
    return manager.discoveredPeripheralArray;
}

-(NSInteger)getScanningState
{
    return manager.scanningState;
}

-(BOOL)isConnected
{
    if(manager.peripheralSelected != nil)
    {
        if([manager.peripheralSelected respondsToSelector:@selector(state)])
        {
            if(manager.peripheralSelected.state == CBPeripheralStateConnected)
                return TRUE;
            else
                return FALSE;
        }
    }
    else
        return FALSE;
    
    return FALSE;
}






//BTLE Manager delegate

-(void)dataReceivedFromPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != nil)
    {
        NSLog(@"Characteristic value error : %@", [error description]);
    }
    else
    {
        NSString *characteristicUUID = @"";
        if([characteristic.UUID respondsToSelector:@selector(UUIDString)])
            characteristicUUID = [characteristic.UUID UUIDString];
        else
            characteristicUUID = [[[NSString alloc] initWithData:characteristic.UUID.data encoding:NSUTF8StringEncoding] autorelease];
        
        
        NSData *data = characteristic.value;
        
        if(data != nil)
        {
            NSString *hexaString = [utils getHexaStringFromData:data];
            
            //////////////////////////////////
            //ONLY TO LOG HEXA DATA RECEIVED
            ////////////////////////
#ifdef DEBUG
            NSMutableString *mutableString = [[NSMutableString alloc] initWithString:@""];
            for(NSInteger i = 0; i < hexaString.length; i+=2)
            {
                [mutableString appendString:[hexaString substringWithRange:NSMakeRange(i, 2)]];
                [mutableString appendString:@" "];
            }
            NSLog(@"Rx : %@", mutableString);
#endif
            ////////////////////////
            //ONLY TO LOG HEXA DATA RECEIVED
            //////////////////////////////////
            
            
            NSScanner *scanner = nil;
            
            //Read characteristic
            if([characteristicUUID isEqualToString:TACX_FEC_READ_CHARACTERISTIC])
            {
                if([hexaString length] >= 8)
                {
                    NSString *syncHexaString = [hexaString substringWithRange:NSMakeRange(0, 2)];
                    NSString *lengthHexaString = [hexaString substringWithRange:NSMakeRange(2, 2)];
                    //NSString *typeHexaString = [hexaString substringWithRange:NSMakeRange(4, 2)];
                    //NSString *channelHexaString = [hexaString substringWithRange:NSMakeRange(6, 2)];
                    
                    unsigned int dataLength = 0;
                    scanner = [NSScanner scannerWithString:lengthHexaString];
                    [scanner scanHexInt:&dataLength];
                    //length - 1 to have the correct data length
                    dataLength -= 1;
                    
                    //Start always with 0xA4
                    if([[syncHexaString uppercaseString] isEqualToString:@"A4"])
                    {
                        //If there is all the data
                        if([hexaString length] >= 8 + 2 * dataLength)
                        {
                            //Hexadecimal string of the FE-C data
                            NSString *dataHexString = [hexaString substringWithRange:NSMakeRange(8, 2 * dataLength)];
                            
                            //8 bytes so 16 characters
                            if([dataHexString length] == 16)
                            {
                                NSString *pageNumberHexaString = [dataHexString substringWithRange:NSMakeRange(0, 2)];
                                NSInteger pageNumber = [utils getDecimalFromHexa:pageNumberHexaString];
                                
                                NSLog(@"Page number : %li (0x%@)", (long)pageNumber, pageNumberHexaString);
                                if(pageNumber == 240)
                                    NSLog(@"Page 240 : %@", hexaString);
                                
                                
                                //Page 1 ==> Calibration request and response
                                if(pageNumber == 1)
                                {
                                    calibrationStarted = FALSE;
                                    
                                    //Page 2
                                    zeroOffsetCalibrationStatus = -1;
                                    spinDownCalibrationStatus = -1;
                                    temperatureCondition = -1;
                                    speedCondition = -1;
                                    currentTemperatureDegC = -1;
                                    targetSpeedKmH = -1;
                                    targetSpinDownTimeSeconds = -1;
                                    
                                    //Calibration response
                                    NSString *calibrationResponseHexaString = [dataHexString substringWithRange:NSMakeRange(2, 2)];
                                    NSString *calibrationResponseBinaryString = [utils getBinaryFromHexa:calibrationResponseHexaString];
                                    spinDownCalibrationResponse = [[calibrationResponseBinaryString substringWithRange:NSMakeRange(0, 1)] integerValue];
                                    zeroOffsetCalibrationResponse = [[calibrationResponseBinaryString substringWithRange:NSMakeRange(1, 1)] integerValue];
                                    
                                    //Temperature response
                                    NSString *temperatureResponseHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                    if([temperatureResponseHexaString isEqualToString:@"FF"])
                                        temperatureResponseDegC = -1;
                                    else
                                        temperatureResponseDegC = [utils getDecimalFromHexa:temperatureResponseHexaString] * 0.5 - 25.0;
                                    
                                    //Zero offset response
                                    NSString *zeroOffsetResponseHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(10, 2)], [dataHexString substringWithRange:NSMakeRange(8, 2)]];
                                    if([zeroOffsetResponseHexaString isEqualToString:@"FFFF"])
                                        zeroOffsetResponse = -1;
                                    else
                                        zeroOffsetResponse = [utils getDecimalFromHexa:zeroOffsetResponseHexaString];
                                    
                                    //Spin down time response
                                    NSString *spinDownTimeResponseHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(14, 2)], [dataHexString substringWithRange:NSMakeRange(12, 2)]];
                                    if([spinDownTimeResponseHexaString isEqualToString:@"FFFF"])
                                        spinDownTimeResponseSeconds = -1;
                                    else
                                        spinDownTimeResponseSeconds = [utils getDecimalFromHexa:spinDownTimeResponseHexaString];
                                    
                                    
                                }
                                
                                //Page 2 ==> Calibration in progress
                                if(pageNumber == 2)
                                {
                                    //Calibration status
                                    NSString *calibrationStatusHexaString = [dataHexString substringWithRange:NSMakeRange(2, 2)];
                                    NSString *calibrationStatusBinaryString = [utils getBinaryFromHexa:calibrationStatusHexaString];
                                    spinDownCalibrationStatus = [[calibrationStatusBinaryString substringWithRange:NSMakeRange(0, 1)] integerValue];
                                    zeroOffsetCalibrationStatus = [[calibrationStatusBinaryString substringWithRange:NSMakeRange(1, 1)] integerValue];
                                    
                                    
                                    //Calibration conditions
                                    NSString *calibrationConditionsHexaString = [dataHexString substringWithRange:NSMakeRange(4, 2)];
                                    NSString *calibrationConditionsBinaryString = [utils getBinaryFromHexa:calibrationConditionsHexaString];
                                    speedCondition = [[calibrationConditionsBinaryString substringWithRange:NSMakeRange(0, 2)] integerValue];
                                    temperatureCondition = [[calibrationConditionsBinaryString substringWithRange:NSMakeRange(2, 2)] integerValue];
                                    
                                    
                                    //Current temperature
                                    NSString *currentTemperatureHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                    if([currentTemperatureHexaString isEqualToString:@"FF"])
                                        currentTemperatureDegC = -1;
                                    else
                                        currentTemperatureDegC = [utils getDecimalFromHexa:currentTemperatureHexaString] * 0.5 - 25.0;
                                    
                                    //Target speed
                                    NSString *targetSpeedHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(10, 2)], [dataHexString substringWithRange:NSMakeRange(8, 2)]];
                                    if([targetSpeedHexaString isEqualToString:@"FFFF"])
                                        targetSpeedKmH = -1;
                                    else
                                        targetSpeedKmH = [utils getDecimalFromHexa:targetSpeedHexaString] * 0.001 * 3.6;
                                    
                                    //Target spin-don time
                                    NSString *targetSpinDownHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(14, 2)], [dataHexString substringWithRange:NSMakeRange(12, 2)]];
                                    if([targetSpinDownHexaString isEqualToString:@"FFFF"])
                                        targetSpinDownTimeSeconds = -1;
                                    else
                                        targetSpinDownTimeSeconds = [utils getDecimalFromHexa:targetSpinDownHexaString] / 1000.0;
                                        
                                }
                                
                                //Page 16 ==> General FE data page
                                if(pageNumber == 16)
                                {
                                    //Hexadecimal string
                                    NSString *capabilitiesHexaString = [dataHexString substringWithRange:NSMakeRange(14, 2)];
                                    
                                    //Capabilities and FE state binary string
                                    NSString *capabilitiesBinaryString = [utils getBinaryFromHexa:capabilitiesHexaString];
                                    
                                    //Binary string for each capability
                                    NSString *hrDataSourceBinaryString = [capabilitiesBinaryString substringWithRange:NSMakeRange(0, 2)];
                                    NSString *distanceTraveledEnabledBinaryString = [capabilitiesBinaryString substringWithRange:NSMakeRange(2, 1)];
                                    NSString *virtualSpeedFlagBinaryString = [capabilitiesBinaryString substringWithRange:NSMakeRange(3, 1)];
                                    //NSString *feStateBinaryString = [capabilitiesBinaryString substringWithRange:NSMakeRange(4, 3)];
                                    //NSString *lapToggleBitBinaryString = [capabilitiesBinaryString substringWithRange:NSMakeRange(7, 1)];
                                    //Value for each capability
                                    NSInteger hrDataSourceValue = [utils getDecimalFromBinary:hrDataSourceBinaryString];
                                    NSInteger distanceTraveledEnabledValue = [utils getDecimalFromBinary:distanceTraveledEnabledBinaryString];
                                    NSInteger virtualSpeedFlagValue = [utils getDecimalFromBinary:virtualSpeedFlagBinaryString];
                                    //NSInteger feStateValue = [utils getDecimalFromBinary:feStateBinaryString];
                                    //NSInteger lapToggleBitValue = [utils getDecimalFromBinary:lapToggleBitBinaryString];
                                    
                                    //Virtual speed
                                    virtualSpeed = virtualSpeedFlagValue;
                                    
                                    //Equipment type
                                    NSString *equipmentTypeHexaString = [dataHexString substringWithRange:NSMakeRange(2, 2)];
                                    //Binary string
                                    NSString *equipmentTypeBinaryString = [[utils getBinaryFromHexa:equipmentTypeHexaString] substringWithRange:NSMakeRange(3, 5)];
                                    //New hexa string
                                    NSString *newEquipmentTypeHexaString = [utils getHexaFromBinary:equipmentTypeBinaryString];
                                    //Value
                                    equipmentType = [utils getDecimalFromHexa:newEquipmentTypeHexaString];
                                    //String
                                    switch (equipmentType)
                                    {
                                        case 16:
                                            equipmentTypeString = @"(Default) General";
                                            break;
                                        case 19:
                                            equipmentTypeString = @"Treadmill";
                                            break;
                                        case 20:
                                            equipmentTypeString = @"Elliptical";
                                            break;
                                        case 21:
                                            equipmentTypeString = @"Stationary Bike";
                                            break;
                                        case 22:
                                            equipmentTypeString = @"Rower";
                                            break;
                                        case 23:
                                            equipmentTypeString = @"Climber";
                                            break;
                                        case 24:
                                            equipmentTypeString = @"Nordic Skier";
                                            break;
                                        case 25:
                                            equipmentTypeString = @"Trainer";
                                            break;
                                        default:
                                            equipmentTypeString = @"";
                                            break;
                                    }
                                    
                                    //Elapsed time
                                    NSString *elapsedTimeHexaString = [dataHexString substringWithRange:NSMakeRange(4, 2)];
                                    elapsedTimeSeconds = [utils getDecimalFromHexa:elapsedTimeHexaString] * 0.25;
                                    
                                    //Distance traveled
                                    if(distanceTraveledEnabledValue != 0)
                                    {
                                        NSString *distanceTraveledHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                        distanceTraveledMeters = [utils getDecimalFromHexa:distanceTraveledHexaString];
                                    }
                                    
                                    //Speed
                                    NSString *speedHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(10, 2)], [dataHexString substringWithRange:NSMakeRange(8, 2)]];
                                    speedKmH = [utils getDecimalFromHexa:speedHexaString] * 0.001 * 3.6; // * 0.001 (m/s) * 3.6 (km/h)
                                    
                                    //Heart rate
                                    if(hrDataSourceValue != 0)
                                    {
                                        NSString *heartRateHexaString = [dataHexString substringWithRange:NSMakeRange(12, 2)];
                                        heartRateBPM = [utils getDecimalFromHexa:heartRateHexaString];
                                    }
                                }
                                
                                
                                //Page 17 ==> General settings
                                if(pageNumber == 17)
                                {
                                    //Cycle length
                                    NSString *cycleLengthHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                    cycleLengthM = [utils getDecimalFromHexa:cycleLengthHexaString] * 0.01;
                                    
                                    //Incline
                                    NSString *inclineHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(10, 2)], [dataHexString substringWithRange:NSMakeRange(8, 2)]];
                                    inclinePercent = [utils getDecimalFromHexa:inclineHexaString] * 0.01;
                                    
                                    //Resistance level
                                    NSString *resistanceLevelHexaString = [dataHexString substringWithRange:NSMakeRange(12, 2)];
                                    resistanceLevelPercent = [utils getDecimalFromHexa:resistanceLevelHexaString] * 0.5;
                                }
                                
                                
                                //Page 25 ==> Specific trainer data page
                                if(pageNumber == 25)
                                {
                                    //NSString *flagsHexaString = [dataHexString substringWithRange:NSMakeRange(14, 2)];
                                    //NSInteger feState = [utils getDecimalFromBinary:[[utils getBinaryFromHexa:flagsHexaString] substringWithRange:NSMakeRange(0, 3)]];
                                    
                                    //Update event count
                                    NSString *updateEventCountHexaString = [dataHexString substringWithRange:NSMakeRange(2, 2)];
                                    updateEventCount = [utils getDecimalFromHexa:updateEventCountHexaString];
                                    
                                    //Instantaneous cadence
                                    NSString *instantaneousCadenceHexaString = [dataHexString substringWithRange:NSMakeRange(4, 2)];
                                    cadenceRPM = [utils getDecimalFromHexa:instantaneousCadenceHexaString];
                                    
                                    //Accumulated power
                                    NSString *accumulatedPowerHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(8, 2)], [dataHexString substringWithRange:NSMakeRange(6, 2)]];
                                    accumulatedPowerW = [utils getDecimalFromHexa:accumulatedPowerHexaString];
                                    
                                    //Instantaneous power
                                    NSString *instantaneousPowerMSBHexaString = [dataHexString substringWithRange:NSMakeRange(10, 2)];
                                    NSString *instantaneousPowerLSBAndTrainerStatusHexaString = [dataHexString substringWithRange:NSMakeRange(12, 2)];
                                    //Binary
                                    NSString *instantaneousPowerMSBBinaryString = [utils getBinaryFromHexa:instantaneousPowerMSBHexaString];
                                    NSString *instantaneousPowerLSBAndTrainerStatusBinaryString = [utils getBinaryFromHexa:instantaneousPowerLSBAndTrainerStatusHexaString];
                                    NSString *instantaneousPowerBinaryString = [NSString stringWithFormat:@"%@%@", [instantaneousPowerLSBAndTrainerStatusBinaryString substringWithRange:NSMakeRange(4, 4)], instantaneousPowerMSBBinaryString];
                                    //Hexa
                                    NSString *instantaneousPowerHexaString = [utils getHexaFromBinary:instantaneousPowerBinaryString];
                                    //Value
                                    powerW = [utils getDecimalFromHexa:instantaneousPowerHexaString];
                                    
                                    /*
                                    //Trainer status
                                    //Binary
                                    NSString *trainerStatusBinaryString = [NSString stringWithFormat:@"%@%@", [instantaneousPowerLSBAndTrainerStatusBinaryString substringWithRange:NSMakeRange(0, 4)], instantaneousPowerMSBBinaryString];*/
                                }
                                
                                
                                //Page 48 ==> Basic resistance
                                if(pageNumber == 48)
                                {
                                    //Total resistance
                                    NSString *totalResistanceHexaString = [dataHexString substringWithRange:NSMakeRange(14, 2)];
                                    totalResistancePercent = [utils getDecimalFromHexa:totalResistanceHexaString] * 0.5;
                                }
                                
                                //Page 49 ==> Target power
                                if(pageNumber == 49)
                                {
                                    //Target power
                                    NSString *targetPowerHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(14, 2)], [dataHexString substringWithRange:NSMakeRange(12, 2)]];
                                    targetPowerW = [utils getDecimalFromHexa:targetPowerHexaString] * 0.25;
                                }
                                
                                //Page 50 ==> Wind resistance
                                if(pageNumber == 50)
                                {
                                    //Wind resistance coefficient
                                    NSString *windResistanceCoefficientHexaString = [dataHexString substringWithRange:NSMakeRange(10, 2)];
                                    windResistanceCoefficientKgM = [utils getDecimalFromHexa:windResistanceCoefficientHexaString] * 0.01;
                                    
                                    //Wind speed
                                    NSString *windSpeedHexaString = [dataHexString substringWithRange:NSMakeRange(12, 2)];
                                    windSpeedKmH = [utils getDecimalFromHexa:windSpeedHexaString] - 127.0;
                                    
                                    //Drafting factor
                                    NSString *draftingFactorHexaString = [dataHexString substringWithRange:NSMakeRange(14, 2)];
                                    draftingFactor = [utils getDecimalFromHexa:draftingFactorHexaString] * 0.01;
                                }
                                
                                //Page 51 ==> Track resistance
                                if(pageNumber == 51)
                                {
                                    //Grade
                                    NSString *gradeHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(12, 2)], [dataHexString substringWithRange:NSMakeRange(10, 2)]];
                                    gradePercent = [utils getDecimalFromHexa:gradeHexaString] * 0.01;
                                    
                                    //Rolling resistance coefficient
                                    NSString *rollingResistanceHexaString = [dataHexString substringWithRange:NSMakeRange(12, 2)];
                                    rollingResistanceCoefficient = [utils getDecimalFromHexa:rollingResistanceHexaString] * (5 * pow(10, -5));
                                }
                                
                                
                                //Page 54 ==> FE capabilities (on demand)
                                if(pageNumber == 54)
                                {
                                    //Maximum resistance
                                    NSString *maximumResistanceHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(12, 2)], [dataHexString substringWithRange:NSMakeRange(10, 2)]];
                                    maximumResistanceN = [utils getDecimalFromHexa:maximumResistanceHexaString];
                                    
                                    //Capabilities
                                    NSString *capabilitiesHexaString = [dataHexString substringWithRange:NSMakeRange(14, 2)];
                                    //Binary
                                    NSString *capabilitiesbinaryString = [utils getBinaryFromHexa:capabilitiesHexaString];
                                    //Values
                                    BOOL basicResistanceModeSupported = [[capabilitiesbinaryString substringWithRange:NSMakeRange(7, 1)] boolValue];
                                    BOOL targetPowerModeSupported = [[capabilitiesbinaryString substringWithRange:NSMakeRange(6, 1)] boolValue];
                                    BOOL simulationModeSupported = [[capabilitiesbinaryString substringWithRange:NSMakeRange(5, 1)] boolValue];
                                    supportedMode = [[NSString stringWithFormat:@"Basic resistance : %@ - Target power : %@ - Simulation : %@", basicResistanceModeSupported?@"true":@"false", targetPowerModeSupported?@"true":@"false", simulationModeSupported?@"true":@"false"] retain];
                                }
                                
                                //Page 55 ==> User configuration (on demand)
                                if(pageNumber == 55)
                                {
                                    //User weight
                                    NSString *userWeightHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(4, 2)], [dataHexString substringWithRange:NSMakeRange(2, 2)]];
                                    userWeightKg = [utils getDecimalFromHexa:userWeightHexaString] * 0.01;
                                    
                                    //Hexa
                                    NSString *bicycleWheelDiameterOffsetAndWeightLSBHexaString = [dataHexString substringWithRange:NSMakeRange(8, 2)];
                                    NSString *bicycleWeightMSBHexaString = [dataHexString substringWithRange:NSMakeRange(10, 2)];
                                    //Binary
                                    NSString *bicycleWheelDiameterOffsetAndWeightLSBBinaryString = [utils getBinaryFromHexa:bicycleWheelDiameterOffsetAndWeightLSBHexaString];
                                    NSString *bicycleWeightMSBBinaryString = [utils getBinaryFromHexa:bicycleWeightMSBHexaString];
                                    
                                    //Bicycle wheel diameter offset
                                    NSString *bicycleWheelDiameterOffsetBinaryString = [bicycleWheelDiameterOffsetAndWeightLSBBinaryString substringWithRange:NSMakeRange(4, 4)];
                                    bicycleWheelDiameterOffsetMm = [utils getDecimalFromBinary:bicycleWheelDiameterOffsetBinaryString];
                                    
                                    //Bicycle weight
                                    NSString *bicycleWeightBinaryString = [NSString stringWithFormat:@"%@%@", bicycleWeightMSBBinaryString, [bicycleWheelDiameterOffsetAndWeightLSBBinaryString substringWithRange:NSMakeRange(0, 4)]];
                                    bicycleWeightKg = [utils getDecimalFromBinary:bicycleWeightBinaryString] * 0.05;
                            
                                    //Bicycle wheel diameter
                                    NSString *bicycleWheelDiameterHexaString = [dataHexString substringWithRange:NSMakeRange(12, 2)];
                                    bicycleWheelDiameterM = [utils getDecimalFromHexa:bicycleWheelDiameterHexaString] * 0.01;
                                    
                                    //Gear ratio
                                    NSString *gearRatioHexaString = [dataHexString substringWithRange:NSMakeRange(14, 2)];
                                    gearRatio = [utils getDecimalFromHexa:gearRatioHexaString] * 0.03;
                                }
                                
                                //Page 70 ==> Request data
                                if(pageNumber == 70)
                                {
                                    
                                }
                                
                                //Page 71 ==> Command status
                                if(pageNumber == 71)
                                {
                                    //Last received command ID
                                    NSString *lastReceivedCommandIDHexaString = [dataHexString substringWithRange:NSMakeRange(2, 2)];
                                    lastReceivedCommandID = [utils getDecimalFromHexa:lastReceivedCommandIDHexaString];
                                    
                                    //Sequence #
                                    NSString *sequenceHexaString = [dataHexString substringWithRange:NSMakeRange(4, 2)];
                                    sequence = [utils getDecimalFromHexa:sequenceHexaString];
                                    
                                    //Command status
                                    NSString *commandStatusHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                    commandStatus = [utils getDecimalFromHexa:commandStatusHexaString];
                                    
                                    switch (commandStatus) {
                                        case 0:
                                            commandStatusString = @"Pass";
                                            break;
                                        case 1:
                                            commandStatusString = @"Fail";
                                            break;
                                        case 2:
                                            commandStatusString = @"Not supported";
                                            break;
                                        case 3:
                                            commandStatusString = @"Rejected";
                                            break;
                                        case 4:
                                            commandStatusString = @"Pending";
                                            break;
                                        case 255:
                                            commandStatusString = @"Uninitialized";
                                            break;
                                        default:
                                            commandStatusString = @"Reserved";
                                            break;
                                    }
                                    
                                    //Data
                                    dataString = [[dataHexString substringWithRange:NSMakeRange(8, 8)] retain];
                                }
                                
                                //Page 80 ==> Manufacturer's identification
                                if(pageNumber == 80)
                                {
                                    //HW revision
                                    NSString *hwRevisionHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                    hwRevision = [utils getDecimalFromHexa:hwRevisionHexaString];
                                    
                                    //Manufacturer ID
                                    NSString *manufacturerIDHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(10, 2)], [dataHexString substringWithRange:NSMakeRange(8, 2)]];
                                    manufacturerID = [utils getDecimalFromHexa:manufacturerIDHexaString];
                                    
                                    //Model number
                                    NSString *modelNumberHexaString = [NSString stringWithFormat:@"%@%@", [dataHexString substringWithRange:NSMakeRange(14, 2)], [dataHexString substringWithRange:NSMakeRange(12, 2)]];
                                    modelNumber = [utils getDecimalFromHexa:modelNumberHexaString];
                                }
                                
                                //Page 81 ==> Product information
                                if(pageNumber == 81)
                                {
                                    //SW revision supplemental
                                    NSString *swRevisionSupplementalHexaString = [dataHexString substringWithRange:NSMakeRange(4, 2)];
                                    swRevisionSupplemental = [utils getDecimalFromHexa:swRevisionSupplementalHexaString];
                                    
                                    //SW revision main
                                    NSString *swRevisionMainHexaString = [dataHexString substringWithRange:NSMakeRange(6, 2)];
                                    swRevisionMain = [utils getDecimalFromHexa:swRevisionMainHexaString];
                                    
                                    //Serial number
                                    NSString *serialNumberHexaString = [NSString stringWithFormat:@"%@%@%@%@", [dataHexString substringWithRange:NSMakeRange(14, 2)], [dataHexString substringWithRange:NSMakeRange(12, 2)], [dataHexString substringWithRange:NSMakeRange(10, 2)], [dataHexString substringWithRange:NSMakeRange(8, 2)]];
                                    serialNumber = [utils getDecimalFromHexa:serialNumberHexaString];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)peripheralIsConnected:(BOOL)isConnected
{
    if(isConnected == FALSE)
        [self resetAllData];
}

-(void)characteristicIsDiscovered:(CBCharacteristic *)characteristic
{
    
}

//Control data pages
-(void)sendBasicResistance:(float)totalResistancePercentValue
{
    NSInteger totalResistanceValue = (NSInteger)(totalResistancePercentValue / 0.5);
    
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x30; //Page 48
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = 0xFF;
    bytes[10] = 0xFF;
    bytes[11] = totalResistanceValue; //Total resistance
    
    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}

-(void)sendTargetPower:(float)targetPowerWValue
{
    NSInteger targetPowerValue = (NSInteger)(targetPowerWValue / 0.25);
    
    NSString *targetPowerValueHexaString = [NSString stringWithFormat:@"%04lX", (long)targetPowerValue];
    
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x31; //Page 49
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = 0xFF;
    bytes[10] = [utils getDecimalFromHexa:[targetPowerValueHexaString substringWithRange:NSMakeRange(2, 2)]]; //Target power LSB
    bytes[11] = [utils getDecimalFromHexa:[targetPowerValueHexaString substringWithRange:NSMakeRange(0, 2)]]; //Target power MSB
    
//    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}

-(void)sendWindResistanceCoefficient:(float)windResistanceCoefficientKgMValue windSpeed:(float)windSpeedKmHValue draftingFactor:(float)draftingFactorValue
{
    NSInteger windResistanceCoefficientValue = (NSInteger)(windResistanceCoefficientKgMValue / 0.01);
    NSInteger windSpeedValue = (NSInteger)(windSpeedKmHValue + 127.0);
    NSInteger draftingFactValue = (NSInteger)(draftingFactorValue / 0.01);
    
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x32; //Page 50
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = windResistanceCoefficientValue; //Wind resistance coefficient
    bytes[10] = windSpeedValue; //Wind speed
    bytes[11] = draftingFactValue; //Drafting factor
    
    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}

-(void)sendTrackResistanceWithGrade:(float)gradePercentValue rollingResistanceCoefficient:(float)rollingResistanceCoefficientValue
{
    NSInteger gradeValue = (NSInteger)((gradePercentValue + 200.0) / 0.01);
    NSInteger rollingResistanceCoeffValue = (NSInteger)(rollingResistanceCoefficientValue / (5 * pow(10, -5)));
    
    NSString *gradeValueHexaString = [NSString stringWithFormat:@"%04lX", (long)gradeValue];
    
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x33; //Page 51
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = [utils getDecimalFromHexa:[gradeValueHexaString substringWithRange:NSMakeRange(2, 2)]]; //Grade LSB
    bytes[10] = [utils getDecimalFromHexa:[gradeValueHexaString substringWithRange:NSMakeRange(0, 2)]]; //Grade MSB
    bytes[11] = rollingResistanceCoeffValue; //Rolling resistance coefficient
    
    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}



//Calibration request and response
-(void)sendCalibrationRequest:(NSInteger)calibrationRequestValue
{
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x01; //Page 1
    bytes[5] = 0xFF; //Calibration request
    bytes[6] = 0xFF;
    bytes[7] = 0xFF; //Temperature
    bytes[8] = 0xFF; //Zero offset LSB
    bytes[9] = 0xFF; //Zero offset MSB
    bytes[10] = 0xFF; //Spin-down time LSB
    bytes[11] = 0xFF; //Spin-down time MSB
    
    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}




-(void)sendRequestPage:(NSInteger)page
{
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x46; //Page 70
    bytes[5] = 0xFF;
    bytes[6] = 0xFF;
    bytes[7] = 0xFF; //Descriptor byte 1 (0xFF for no value)
    bytes[8] = 0xFF; //Descriptor byte 2 (0xFF for no value)
    bytes[9] = 0x80; //Requested transmission response
    bytes[10] = page; //Requested page number
    bytes[11] = 0x01; //Command type (0x01 for request data page, 0x02 for request ANT-FS session)
    
    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}





-(void)sendCalibrationRequestForSpinDown:(BOOL)forSpinDown forZeroOffset:(BOOL)forZeroOffset
{
    calibrationStarted = TRUE;
    
    //Page 1
    zeroOffsetCalibrationResponse = -1;
    spinDownCalibrationResponse = -1;
    temperatureResponseDegC = -1;
    zeroOffsetResponse = -1;
    spinDownTimeResponseSeconds = -1;
    
    NSInteger calibrationRequestMode = 0;
    if(forSpinDown == TRUE)
        calibrationRequestMode += 128;
    if(forZeroOffset == TRUE)
        calibrationRequestMode += 64;
    
    //Command to send
    unsigned char bytes[13] = {};
    bytes[0] = 0xA4; //Sync
    bytes[1] = 0x09; //Length
    bytes[2] = 0x4F; //Acknowledge message type
    bytes[3] = 0x05; //Channel
    
    //Data
    bytes[4] = 0x01; //Page 1
    bytes[5] = calibrationRequestMode; //Calibration request
    bytes[6] = 0x00;
    bytes[7] = 0xFF;
    bytes[8] = 0xFF;
    bytes[9] = 0xFF;
    bytes[10] = 0xFF;
    bytes[11] = 0xFF;
    
    //Checksum
    bytes[12] = [self computeChecksum:[NSData dataWithBytes:bytes length:12]];
    
    
    //Data value
    NSData* valData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    //Write data for the main characteristic
    [manager writeValue:valData toCharacteristicUUIDString:TACX_FEC_WRITE_CHARACTERISTIC];
}

-(NSUInteger)computeChecksum:(NSData *)data{
    NSUInteger xor = 0;
    const unsigned char *bytes = data.bytes;
    for(int i = 0; i < data.length; i++)
    {
        if (i == 0) {
            xor = bytes[i];
        }
        else {
            xor = (unsigned char)(xor ^ bytes[i]);
        }
    }
    return xor;
}

-(void)dealloc
{
    [manager release];
    
    [utils release];
    
    [super dealloc];
}


@end
