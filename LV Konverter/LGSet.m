//
//  LGSet.m
//  csvToD83
//
//  Created by Luis Gerhorst on 21.12.13.
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

#import "LGSet.h"

@implementation LGSet

- (id)init
{
    self = [super init];
    if (self) {
        string = [NSMutableString string];
        for (int i = 0; i < 74; i++) [string appendString:@" "];
    }
    return self;
}

// shortcuts:

- (void)setType:(NSUInteger)aInt
{
    [self setInteger:aInt range:NSMakeRange(0, 2)];
}

- (void)setString:(NSString *)s range:(NSRange)range // Nicht-numerisch, werden mit Lehrzeichen aufgefüllt. String muss kürzer als range.length sein.
{
    NSData *ASCIIData = [s dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *ASCIIString = [[NSString alloc] initWithData:ASCIIData encoding:NSASCIIStringEncoding];
    if ([ASCIIString length] > range.length) @throw [NSException exceptionWithName:@"LGSet_SetStringForRange" reason:[NSString stringWithFormat:@"String \"%@\" in ASCII-Encoding has more than %lu characters.", s, (unsigned long)range.length] userInfo:nil];
    while ([ASCIIString length] < range.length) ASCIIString = [NSString stringWithFormat:@"%@ ", ASCIIString];
    [string replaceCharactersInRange:range withString:ASCIIString];
}

- (void)setInteger:(NSUInteger)number range:(NSRange)range // Numerisch, werden mit Nullen vor Zahl aufgefüllt.
{
    NSString *s = [NSString stringWithFormat:@"%lu", (unsigned long)number];
    while ([s length] < range.length) s = [NSString stringWithFormat:@"0%@", s];
    [self setString:s range:range];
}

- (void)setFloat:(float)floatNumber range:(NSRange)range comma:(NSUInteger)comma
{
    // split
    NSUInteger integerNumber = floor(floatNumber);
    float decimalNumber = floatNumber - integerNumber;
    
    // decimal portion
    NSMutableString *decimalStringFormat = [[NSMutableString alloc] initWithString:@"%."];
    [decimalStringFormat appendFormat:@"%lu", (long unsigned)comma];
    [decimalStringFormat appendString:@"f"];
    NSString *decimalFullString = [[NSString alloc] initWithFormat:decimalStringFormat, decimalNumber];
    NSString *decimalString = [decimalFullString substringFromIndex:2]; // Has right length.
    
    [self setInteger:integerNumber range:NSMakeRange(range.location, range.length - comma)];
    [self setString:decimalString range:NSMakeRange(range.location + (range.length - comma), comma)];
}

- (BOOL)setCutString:(NSString *)s range:(NSRange)range
{
    NSString *cutString = s;
    if ([s length] > range.length) cutString = [s substringToIndex:range.length];
    [self setString:cutString range:range];

    if ([s length] > range.length) return YES;
    else return NO;
}

- (NSString *)stringForSetNumber:(NSUInteger)number
{
    
    if (number > 999999) @throw [NSException exceptionWithName:@"LGSet_StringForSetNumber" reason:@"Set number can not have more then 6 digits" userInfo:nil];
    
    // generate string starting with zeros and number at end
    NSString *setNumberString = [NSString stringWithFormat:@"%lu", (unsigned long)number];
    while ([setNumberString length] < 6) setNumberString = [NSString stringWithFormat:@"0%@", setNumberString];
    
    // return string + setNumber
    return [NSString stringWithFormat:@"%@%@", string, setNumberString];
    
}

- (NSString *)description
{
    return [self stringForSetNumber:0];
}

@end
