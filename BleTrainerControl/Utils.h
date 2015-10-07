//
//  Utils.h
//  BleTrainerControl
//
//  Created by William Minol on 27/08/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

-(NSString *)getHexaStringFromData:(NSData *)data;
-(NSString *)getBinaryFromHexa:(NSString *)hexa;
-(NSInteger)getDecimalFromBinary:(NSString *)binary;
-(NSInteger)getDecimalFromHexa:(NSString *)hexa;
-(NSString *)getHexaFromBinary:(NSString *)binary;
-(NSString *)XORBetweenBinary:(NSString *)binary1 andBinary:(NSString *)binary2;

-(UIImage *)imageWithColor:(UIColor *)color;

@end
