//
//  BTLEManager.m
//  KinomapTrainer
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

#import "BTLEManager.h"

@implementation BTLEManager

@synthesize btleManagerDelegate;
@synthesize centralManager, scanningState, discoveredPeripheralArray, peripheralSelected;

-(id)init
{
    if(self = [super init])
    {
        //Scanning state
        scanningState = BTLE_SCANNING_STATE_STOPPED;
        
        //Array of discovered peripheral
        discoveredPeripheralArray = [[NSMutableArray alloc] init];
        
        //Init central manager
        if([centralManager respondsToSelector:@selector(initWithDelegate:queue:options:)])
            centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        else
            centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    return self;
}


-(void)startScanning
{
    [self startScanningWithServicesUUIDArray:nil];
}

-(void)startScanningWithServicesUUIDArray:(NSArray *)servicesUUIDArray
{
    if(scanningState == BTLE_SCANNING_STATE_STOPPED)
    {
        scanningState = BTLE_SCANNING_STATE_STARTED;
        
        //Options to not allow duplicate peripheral
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
        
        //Start scanning
        [centralManager scanForPeripheralsWithServices:servicesUUIDArray options:options];
    }
}

-(void)stopScanning
{
    if(scanningState == BTLE_SCANNING_STATE_STARTED)
    {
        scanningState = BTLE_SCANNING_STATE_STOPPED;
        
        //Stop scanning
        [centralManager stopScan];
    }
}


-(void)retrievePeripheralAndConnectWithUUID:(NSString *)peripheralUUID
{
    if(peripheralUUID != nil)
    {
        if([centralManager respondsToSelector:@selector(retrievePeripheralsWithIdentifiers:)])
        {
            NSArray *peripheralsRetrievedArray = [centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:[[[NSUUID alloc] initWithUUIDString:peripheralUUID] autorelease]]];
            
            if([peripheralsRetrievedArray count] != 0)
            {
                CBPeripheral *peripheral = [peripheralsRetrievedArray objectAtIndex:0];
                
                NSLog(@"Peripheral retrieved: %@ - UUID : %@", peripheral.name, [peripheral.identifier UUIDString]);
                
                if(peripheral != nil)
                {
                    peripheralSelected = [peripheral copy];
                    
                    //Connect peripheral
                    [centralManager connectPeripheral:peripheralSelected options:nil];
                }
            }
        }
    }
}

-(void)disconnectPeripheral
{
    needToBeDisconnected = TRUE;
    
    if([peripheralSelected respondsToSelector:@selector(state)])
    {
        if(peripheralSelected.state != CBPeripheralStateDisconnected)
        {
            //Connect the peripheral
            [centralManager cancelPeripheralConnection:peripheralSelected];
        }
    }
}



-(void)writeValue:(NSData *)data toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)writeType
{
    if(peripheralSelected  == nil)
        NSLog(@"peripheralSelected nil");
    
    if(characteristic  == nil)
        NSLog(@"characteristic nil");
    
    if(peripheralSelected != nil && characteristic != nil)
    {
        [peripheralSelected writeValue:data forCharacteristic:characteristic type:writeType];
    }
}

-(void)writeValue:(NSData *)data toCharacteristicUUIDString:(NSString *)characteristicUUIDString
{
    NSLog(@"Sx : %@", [data description]);
    
    if(peripheralSelected != nil)
    {
        CBCharacteristic *characteristicToWrite = nil;
        
        for(CBService *service in peripheralSelected.services)
        {
            for(CBCharacteristic *characteristic in service.characteristics)
            {
                NSString *characteristicUUID = nil;
                if([characteristic.UUID respondsToSelector:@selector(UUIDString)])
                    characteristicUUID = [characteristic.UUID UUIDString];
                else
                    characteristicUUID = [[[NSString alloc] initWithData:characteristic.UUID.data encoding:NSUTF8StringEncoding] autorelease];
                
                if(characteristicUUID != nil && [characteristicUUID isEqualToString:characteristicUUIDString])
                {
                    characteristicToWrite = characteristic;
                    break;
                }
            }
            if(characteristicToWrite != nil)
                break;
        }
            
        if(characteristicToWrite != nil)
            [self writeValue:data toCharacteristic:characteristicToWrite type:CBCharacteristicWriteWithResponse];
    }
}


-(void)addPeripheralToArray:(CBPeripheral *)peripheral
{
    BOOL UuidIsNil = FALSE;
    
    if([peripheral respondsToSelector:@selector(identifier)])
    {
        if([peripheral.identifier UUIDString] == nil)
            UuidIsNil = TRUE;
    }
    
    //Check if the peripheral UUID is not nil befor adding it
    if(UuidIsNil == FALSE)
    {
        BOOL alreadyInArray = FALSE;
        for (CBPeripheral *peripheralInArray in discoveredPeripheralArray)
        {
            if([peripheral isEqual:peripheralInArray])
            {
                alreadyInArray = TRUE;
                break;
            }
        }
        
        if(alreadyInArray == FALSE)
        {
            //Add peripheral to the array
            [discoveredPeripheralArray addObject:peripheral];
        }
    }
}


////////////////////////////////
//Central Manager delegate
////////////////


//When central manager state changes
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //NSLog(@"centralManagerDidUpdateState:");
    
    NSString *stateString = @"";
    
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOff:
            stateString = @"POWERED OFF";
            break;
        case CBCentralManagerStatePoweredOn:
            stateString = @"POWERED ON";
            break;
        case CBCentralManagerStateResetting:
            stateString = @"RESETTING";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"UNAUTHORIZED";
            break;
        case CBCentralManagerStateUnknown:
            stateString = @"UNKNOWN";
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"UNSUPPORTED";
            break;
        default:
            stateString = @"OTHER";
            break;
    }
    
    NSLog(@"Central Manager State : %@", stateString);
}

//When a peripheral is discovered
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if([peripheral respondsToSelector:@selector(identifier)])
        NSLog(@"Peripheral discovered : %@ - %@", peripheral.name, [peripheral.identifier UUIDString]);
    
    [self addPeripheralToArray:peripheral];
}


-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [btleManagerDelegate peripheralIsConnected:TRUE];
    
    if([peripheral respondsToSelector:@selector(identifier)])
        NSLog(@"Peripheral connected : %@ - %@", peripheral.name, [peripheral.identifier UUIDString]);
    
    peripheralSelected = [peripheral copy];
    
    [peripheralSelected setDelegate:self];
    [peripheralSelected discoverServices:nil];
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [btleManagerDelegate peripheralIsConnected:FALSE];
    
    peripheralSelected = nil;
    //characteristicSelected = nil;
    
    //S'il est déconnecté alors qu'il ne devrait pas l'être, on le reconnecte
    if(needToBeDisconnected == FALSE)
    {
        if(peripheralSelected != nil)
        {
            //Reconnect peripheral disconnected
            [centralManager connectPeripheral:peripheralSelected options:nil];
        }
    }
    else
        needToBeDisconnected = FALSE;
    
    if([peripheral respondsToSelector:@selector(identifier)])
        NSLog(@"Peripheral disconnected : %@ - %@", peripheral.name, [peripheral.identifier UUIDString]);
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    if([peripheral respondsToSelector:@selector(identifier)])
        NSLog(@"Peripheral failed to connect : %@ - %@ - %@", peripheral.name, [peripheral.identifier UUIDString], [error description]);
}

-(void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    for(CBPeripheral *peripheral in peripherals)
    {
        if([peripheral respondsToSelector:@selector(identifier)])
            NSLog(@"Retrieve connected peripheral : %@ - %@", peripheral.name, [peripheral.identifier UUIDString]);
    }
}

-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    /*for(CBPeripheral *peripheral in peripherals)
    {
        if([peripheral respondsToSelector:@selector(identifier)])
            NSLog(@"Retrieve peripheral : %@ - %@", peripheral.name, [peripheral.identifier UUIDString]);
        else
            NSLog(@"Retrieve peripheral : %@ - %@", peripheral.name, peripheral.UUID);
    }*/
    
    if([peripherals count] != 0)
    {
        CBPeripheral *peripheral = [peripherals objectAtIndex:0];
        
        if(peripheral != nil)
        {
            peripheralSelected = [peripheral copy];
        
            //Connect peripheral
            [centralManager connectPeripheral:peripheralSelected options:nil];
        }
    }
}

////////////////
//Central Manager delegate
////////////////////////////////



////////////////////////////////
//Central Manager delegate
////////////////

-(void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    NSLog(@"peripheralDidUpdateName : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristicsForService : %@", peripheral.name);
    
    for(CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"characteristic discovered : %@ - isNotifying : %i", [characteristic.UUID UUIDString], characteristic.isNotifying);
        
        //Pour s'abonner à la characteristic dès qu'il y a un changement de valeur
        [peripheral setNotifyValue:TRUE forCharacteristic:characteristic];

        /*
        //Si l'UUID existe
        if(mainCharacterisiticUUID != nil)
        {
            if([characteristic.UUID respondsToSelector:@selector(UUIDString)])
            {
                if([[characteristic.UUID UUIDString] isEqual:mainCharacterisiticUUID])
                {
                    characteristicSelected = characteristic;
                    
                    [btleManagerDelegate characteristicIsDiscovered:characteristic];
                }
            }
            else
            {
                if([[[NSString alloc] initWithData:characteristic.UUID.data encoding:NSUTF8StringEncoding] isEqual:mainCharacterisiticUUID])
                {
                    characteristicSelected = characteristic;
                }
            }
        }*/
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"peripheral - didDiscoverDescriptorsForCharacteristic : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"peripheral - didDiscoverIncludedServicesForService : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"peripheral - didDiscoverServices : %@", peripheral.name);
    
    for(CBService *service in peripheral.services)
    {
        NSLog(@"Service UUID : %@", [service.UUID UUIDString]);
        
        [peripheral setDelegate:self];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    NSLog(@"peripheral - didModifyServices : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"peripheral - didReadRSSI : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /*if([characteristic.UUID respondsToSelector:@selector(UUIDString)])
        NSLog(@"peripheral - didUpdateNotificationStateForCharacteristic : %@", [characteristic.UUID UUIDString]);
    else
        NSLog(@"peripheral - didUpdateNotificationStateForCharacteristic : %@", [[NSString alloc] initWithData:characteristic.UUID.data encoding:NSUTF8StringEncoding]);*/
        
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //NSLog(@"dataReceived from characteristic : %@", [characteristic.UUID UUIDString]);
    [btleManagerDelegate dataReceivedFromPeripheral:peripheral withCharacteristic:characteristic error:error];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@"peripheral - didUpdateValueForDescriptor : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"peripheral - didWriteValueForCharacteristic : %@", peripheral.name);
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@"peripheral - didWriteValueForDescriptor : %@", peripheral.name);
}

////////////////
//Peripheral delegate
////////////////////////////////


-(void)dealloc
{
    [centralManager release];
    [discoveredPeripheralArray release];
    
    [super dealloc];
}

@end
