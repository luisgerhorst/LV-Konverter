//
//  LGOrdinalNumberScheme.m
//  csvToD83
//
//  Created by Luis Gerhorst on 27/01/14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import "LGOrdinalNumberScheme.h"
#import "LGOrdinalNumber.h"

NSUInteger digitsCount(NSInteger i) {
    return i > 0 ? (NSUInteger)log10((double)i) + 1 : 1;
}

@implementation LGOrdinalNumberScheme

- (id)initWithMaxChildCounts:(NSArray *)maxChildCounts
{
    self = [super init];
    if (self) {
        
        /*
         maxChildCounts:
         - the layer befor the layer with 0 is the max number of Service
         - each layer before the layer with services is a group layer
         - array of NSNumbers
         */
        
        // Remove leading zero:
        NSMutableArray *mutableMaxChildCounts = [NSMutableArray arrayWithArray:maxChildCounts];
        [mutableMaxChildCounts removeLastObject];
        maxChildCounts = mutableMaxChildCounts;
        
        // Transform maxChildCount array to digitCount array:
        NSMutableArray *s = [NSMutableArray array];
        for (NSNumber *maxChildCount in maxChildCounts) [s addObject:[NSNumber numberWithUnsignedInteger:digitsCount([maxChildCount unsignedIntegerValue])]];
        
        scheme = s;
        
    }
    return self;
}

- (NSString *)d83Data73OfOrdinalNumber:(LGOrdinalNumber *)ordinalNumber // 73 - OZ - Ordnungszahl
{
    NSMutableString *ordinalNumberString = [NSMutableString string];
    
    NSUInteger locationCount = [ordinalNumber depth];
    NSUInteger locationIndex = 0;
    for (NSNumber *digitsObject in scheme) { // For each layer in scheme ...
        NSUInteger digits = [digitsObject unsignedIntegerValue];
        NSString *string;
        if (locationIndex < locationCount) { // If location is afterwards, insert number.
            string = [NSString stringWithFormat:@"%lu", [ordinalNumber numberForPosition:locationIndex]]; // Convert int to string.
            while ([string length] < digits) string = [NSString stringWithFormat:@"0%@", string]; // Fill up with zeros (before the number).
        } else { // If location is before, insert spaces.
            string = @"";
            while ([string length] < digits) string = [NSString stringWithFormat:@"%@ ", string]; // Fill up with spaces.
        }
        [ordinalNumberString appendString:string]; // Add chunk to final string.
        locationIndex++;
    }
    
    return ordinalNumberString;
}

- (NSString *)d83Data74 // 74 - OZMASKE - Maske zur OZ-Interpretation
{
    NSMutableString *string = [NSMutableString string];
    
    // Groups:
    NSUInteger groupDepth = 1;
    for (NSUInteger i = 0; i < [scheme count] - 1; i++) {
        NSUInteger digits = [[scheme objectAtIndex:i] unsignedIntegerValue];
        for (NSUInteger i = 0; i < digits; i++) [string appendFormat:@"%lu", (unsigned long)groupDepth];
        groupDepth++;
    }
    
    // Services:
    NSUInteger serviceDigits = [[scheme objectAtIndex:[scheme count] - 1] unsignedIntegerValue];
    for (NSUInteger i = 0; i < serviceDigits; i++) [string appendString:@"P"];
    
    // Zeros
    while ([string length] < 9) [string appendString:@"0"];
    
    // Validate
    if ([string length] != 9) @throw [NSException exceptionWithName:@"d83Date74" reason:@"Resulting data element if too long" userInfo:nil];
    
    return string;
}

@end
