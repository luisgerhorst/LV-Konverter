//
//  LGOrdinalNumberScheme.m
//  csvToD83
//
//  Created by Luis Gerhorst on 27/01/14.
/*
 The MIT License (MIT)
 
 Copyright (c) 2014 Luis Gerhorst
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "LGOrdinalNumberScheme.h"
#import "LGOrdinalNumber.h"

NSUInteger digitsCount(NSInteger i) {
    return i > 0 ? (NSUInteger)log10((double)i) + 1 : 1;
}


@interface LGOrdinalNumberScheme ()

// Array of NSNumbers indicating how many digits to use for each layer when generating the OZMASKE
@property (readonly) NSArray *scheme;

@end


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
        
        _scheme = s;
        
    }
    return self;
}

- (NSString *)d83Data73OfOrdinalNumber:(LGOrdinalNumber *)ordinalNumber // 73 - OZ - Ordnungszahl
{
    NSMutableString *ordinalNumberString = [NSMutableString string];
    
    NSUInteger locationCount = [ordinalNumber depth];
    NSUInteger locationIndex = 0;
    for (NSNumber *digitsObject in self.scheme) { // For each layer in scheme ...
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
    for (NSUInteger i = 0; i < [self.scheme count] - 1; i++) {
        NSUInteger digits = [[self.scheme objectAtIndex:i] unsignedIntegerValue];
        for (NSUInteger i = 0; i < digits; i++) [string appendFormat:@"%lu", (unsigned long)groupDepth];
        groupDepth++;
    }
    
    // Services:
    NSUInteger serviceDigits = [[self.scheme objectAtIndex:[self.scheme count] - 1] unsignedIntegerValue];
    for (NSUInteger i = 0; i < serviceDigits; i++) [string appendString:@"P"];
    
    // Zeros
    while ([string length] < 9) [string appendString:@"0"];
    
    // Validate
    if ([string length] != 9) @throw [NSException exceptionWithName:@"d83Date74"
                                                             reason:@"Resulting data element if too long"
                                                           userInfo:nil]; // Error very unlikely to happen.
    
    return string;
}

@end
