//
//  LGMutableOrdinalNumber.m
//  csvToD83
//
//  Created by Luis Gerhorst on 24.12.13.
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

#import "LGMutableOrdinalNumber.h"
#import "LGOrdinalNumber.h"
#import "LGOrdinalNumberProtected.h"


@implementation LGMutableOrdinalNumber

- (void)layerUp {
    NSMutableArray *location = [NSMutableArray arrayWithArray:self.ordinalNumber];
    
    [location removeLastObject];
    
    self.ordinalNumber = location;
}

// starts at 0, must be incremented before generating first string
- (void)layerDown
{
    NSMutableArray *location = [NSMutableArray arrayWithArray:self.ordinalNumber];
    
    [location addObject:[NSNumber numberWithUnsignedInteger:0]];
    
    self.ordinalNumber = location;
}

- (void)next
{
    NSMutableArray *location = [NSMutableArray arrayWithArray:self.ordinalNumber];
    
    NSUInteger lastIndex = [location count]-1;
    NSNumber *lastIncremented = [NSNumber numberWithUnsignedInteger:[[location objectAtIndex:lastIndex] unsignedIntegerValue] + 1];
    [location replaceObjectAtIndex:lastIndex withObject:lastIncremented];
    
    self.ordinalNumber = location;
}

@end
