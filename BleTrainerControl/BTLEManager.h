//
//  BTLEManager.h
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "BTLEConstants.h"

@protocol BTLEManagerDelegate;

@interface BTLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    id <BTLEManagerDelegate> btleManagerDelegate;
    
    CBCentralManager *centralManager;
    NSInteger scanningState;
    NSMutableArray *discoveredPeripheralArray;
    
    CBPeripheral *peripheralSelected;
    
    BOOL needToBeDisconnected;
    
    //NSMutableArray *characteristicsArrayForPeripheral;
}

@property (nonatomic, assign) id <BTLEManagerDelegate> btleManagerDelegate;

@property (nonatomic, retain) CBCentralManager *centralManager;
@property (nonatomic) NSInteger scanningState;
@property (nonatomic, retain) NSMutableArray *discoveredPeripheralArray;
@property (nonatomic, retain) CBPeripheral *peripheralSelected;

-(void)startScanning;
-(void)startScanningWithServicesUUIDArray:(NSArray *)servicesUUIDArray;
-(void)stopScanning;

-(void)addPeripheralToArray:(CBPeripheral *)peripheral;

-(void)retrievePeripheralAndConnectWithUUID:(NSString *)peripheralUUID;
-(void)disconnectPeripheral;

-(void)writeValue:(NSData *)data toCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)writeType;
-(void)writeValue:(NSData *)data toCharacteristicUUIDString:(NSString *)characteristicUUIDString;

@end


@protocol BTLEManagerDelegate

@optional
-(void)peripheralIsConnected:(BOOL)isConnected;
-(void)characteristicIsDiscovered:(CBCharacteristic *)characteristic;
-(void)dataReceivedFromPeripheral:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end