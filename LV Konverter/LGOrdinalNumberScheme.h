//
//  LGOrdinalNumberScheme.h
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

#import <Foundation/Foundation.h>

@class LGOrdinalNumber;

@interface LGOrdinalNumberScheme : NSObject
{
    // Array of NSNumbers indicating how many digits to use for each layer when generating the OZMASKE
    NSArray *scheme;
}

- (id)initWithMaxChildCounts:(NSArray *)maxChildCounts;

- (NSString *)d83Data73OfOrdinalNumber:(LGOrdinalNumber *)ordinalNumber;
- (NSString *)d83Data74;

@end
