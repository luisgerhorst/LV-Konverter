//
//  LGOrdinalNumber.m
//  csvToD83
//
//  Created by Luis Gerhorst on 17.12.13.
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

#import "LGOrdinalNumber.h"
#import "LGOrdinalNumberProtected.h"

@implementation LGOrdinalNumber

// Mostly called when using a LGMutableOrdinalNumber, has to be incremented before usage.
- (id)init
{
    self = [super init];
    if (self) {
        _ordinalNumber = [NSArray arrayWithObject:@(0)];
    }
    return self;
}

- (id)initWithCSVString:(NSString *)string
{
    self = [super init];
    if (self) {
        
        // Convert:
        NSArray *strings = [string componentsSeparatedByString:@"."];
        NSMutableArray *numbers = [NSMutableArray array];
        for (NSString *s in strings) {
            [numbers addObject:@((NSUInteger)[s integerValue])]; // get unsigned int from string and put into array
        }
        
        // Fix:
        if ([[numbers objectAtIndex:[numbers count]-1] integerValue] == 0) [numbers removeLastObject]; // Remove 0 at end caused by dot at the end of the string.
        self.ordinalNumber = numbers;
        
        // Validate:
        if ([self.ordinalNumber count] == 0) return nil;
        for (NSUInteger i = 0; i < [self.ordinalNumber count]; i++) { // Each number ...
            if ([[self.ordinalNumber objectAtIndex:i] integerValue] > 0) continue; // ... must be larger then 0.
            return nil;
        }
        
    }
    return self;
}

- (id)initWithOrdinalNumber:(LGOrdinalNumber *)inputOrdinalNumber
{
    self = [super init];
    if (self) {
        self.ordinalNumber = [inputOrdinalNumber arrayValue];
    }
    return self;
}

- (NSUInteger)depth
{
    return [self.ordinalNumber count];
}

- (NSUInteger)numberForPosition:(NSUInteger)position
{
    return [[self.ordinalNumber objectAtIndex:position] unsignedIntegerValue];
}

- (NSString *)stringValue
{
    NSMutableString *string = [NSMutableString string];
    for (NSNumber *number in self.ordinalNumber) {
        [string appendString:[number stringValue]];
        [string appendString:@"."];
    }
    [string replaceCharactersInRange:NSMakeRange([string length]-1, 1) withString:@""];
    return string;
}

- (NSString *)description
{
    return [self stringValue];
}

@end
