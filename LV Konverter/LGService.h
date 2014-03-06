//
//  LGService.h
//  csvToD83
//
//  Created by Luis Gerhorst on 16.12.13.
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
#import "LGNode.h"

@class LGServiceType;
@class LGErrors;


extern NSInteger const LGServiceUnitTooLong;
extern NSString * const LGServiceUnitTooLong_OrdinalNumberKey;

extern NSInteger const LGServiceTitleTooLong;
extern NSString * const LGServiceTitleTooLong_OrdinalNumberKey;


@interface LGService : LGNode <LGNodeInherting> {
    
    // Beginn einer Teilleistung
    float quantity; // MENGE
    NSString *unit; // EINHEIT
    LGServiceType *type; // contains POSART1, POSART2 and POSTYP
    
    // Kurztext
    NSString *title; // KURZTEXT
    
    // Langtext
    NSMutableString *text; // LANGTEXT
    
}

- (id)initWithTitle:(NSString *)aTitle
         ofQuantity:(float)aQuantity
             inUnit:(NSString *)aUnit
  withCSVTypeString:(NSString *)typeString
             errors:(LGErrors *)errors;
- (void)appendTextChunk:(NSString *)textChunk;
- (void)trimText;

- (NSString *)title;

@end
