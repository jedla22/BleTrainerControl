//
//  Utils.m
//  BleTrainerControl
//
//  Created by William Minol on 27/08/2015.
//  Copyright (c) 2015 Kinomap. All rights reserved.
//

#import "Utils.h"

@implementation Utils

-(NSString *)getHexaStringFromData:(NSData *)data
{
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    if (!dataBuffer)
    {
        return @"";
    }
    else
    {
        NSUInteger dataLength  = [data length];
        NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
        
        for (int i = 0; i < dataLength; ++i)
            [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
        
        return [NSString stringWithString:hexString];
    }
}



-(NSString *)getBinaryFromHexa:(NSString *)hexa
{
    NSMutableString *binary = [[NSMutableString alloc] initWithString:@""];
    
    NSMutableArray *arrayNumbersToTest = [[NSMutableArray alloc] init];
    
    NSInteger number = 1;
    //4 bits by characters
    for (NSInteger i = 0; i < [hexa length] * 4; i++)
    {
        if(i==0)
            number = 1;
        else
            number *= 2;
        
        [arrayNumbersToTest addObject:[NSString stringWithFormat:@"%li", (long)number]];
    }
    
    arrayNumbersToTest = [[[arrayNumbersToTest reverseObjectEnumerator] allObjects] mutableCopy];

    unsigned int decimal = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexa];
    [scanner scanHexInt:&decimal];
    
    for (NSString *nbString in arrayNumbersToTest)
    {
        NSInteger numberToTest = [nbString integerValue];
        
        if(decimal >= numberToTest)
        {
            decimal -= numberToTest;
            [binary appendString:@"1"];
        }
        else
            [binary appendString:@"0"];
    }
    
    return binary;
}

-(NSInteger)getDecimalFromBinary:(NSString *)binary
{
    NSString *hexa = [self getHexaFromBinary:binary];
    
    NSInteger decimal = 0;
    unsigned int decimalInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexa];
    [scanner scanHexInt:&decimalInt];
    decimal = decimalInt;
    
    return decimal;
}

-(NSInteger)getDecimalFromHexa:(NSString *)hexa
{
    NSInteger decimal = 0;
    unsigned int decimalInt = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexa];
    [scanner scanHexInt:&decimalInt];
    decimal = decimalInt;
    
    return decimal;
}

-(NSString *)getHexaFromBinary:(NSString *)binary
{
    NSMutableString *hexa = [[NSMutableString alloc] initWithString:@""];
    
    NSMutableArray *arrayNumbersToTest = [[NSMutableArray alloc] init];
    
    NSInteger number = 1;
    for (NSInteger i=0; i<[binary length]; i++)
    {
        if(i==0)
            number = 1;
        else
            number *= 2;
        
        [arrayNumbersToTest addObject:[NSString stringWithFormat:@"%li", (long)number]];
    }
    
    arrayNumbersToTest = [[[arrayNumbersToTest reverseObjectEnumerator] allObjects] mutableCopy];
    
    NSInteger decimal = 0;
    for (NSInteger i = 0; i < [binary length]; i++)
    {
        if ([[binary substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"])
            decimal += [[arrayNumbersToTest objectAtIndex:i] integerValue];
    }
    
    hexa = [[NSString stringWithFormat:@"%02lX", (long)decimal] mutableCopy];
    
    return hexa;
}

-(NSString *)XORBetweenBinary:(NSString *)binary1 andBinary:(NSString *)binary2
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    
    for (NSInteger i = 0; i < [binary1 length]; i++)
    {
        if ([[binary1 substringWithRange:NSMakeRange(i, 1)] isEqual:[binary2 substringWithRange:NSMakeRange(i, 1)]] == TRUE)
            [result appendString:@"0"];
        else
            [result appendString:@"1"];
    }
    
    return result;
}


@end
