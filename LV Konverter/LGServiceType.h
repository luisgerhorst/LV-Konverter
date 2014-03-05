//
//  LGServiceType.h
//  csvToD83
//
//  Created by Luis Gerhorst on 20.12.13.
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Luis Gerhorst
 
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

@class LGErrors;


// Error codes.

extern NSInteger const LGInvalidServiceType;
extern NSString * const LGInvalidServiceType_ServiceTitleKey;


typedef NS_ENUM(NSInteger, LGServiceType_KIND1) { // POSART1
    LGServiceType_KIND1_N, // N - Normalposition
    LGServiceType_KIND1_G, // G
    LGServiceType_KIND1_A, // A
    LGServiceType_KIND1_S // S - Stundenlohnarbeiten
};

typedef NS_ENUM(NSInteger, LGServiceType_KIND2) { // POSART2
    LGServiceType_KIND2_N, // N - Normalposition
    LGServiceType_KIND2_E, // E - Bedarfsposition ohne Gesamtbetrag
    LGServiceType_KIND2_M // M - Bedarfsposition mit Gesamtbetrag
};

typedef NS_ENUM(NSInteger, LGServiceType_TYPE) { // POSTYP
    LGServiceType_TYPE_N, // N - Normalposition
    LGServiceType_TYPE_L // L
};


@interface LGServiceType : NSObject {
    LGServiceType_KIND1 kind1; // for POSART1
    LGServiceType_KIND2 kind2; // for POSART2
    LGServiceType_TYPE type; // for POSTYP
}

- (id)initWithCSVString:(NSString *)kind2String forServiceWithUnit:(NSString *)unit error:(NSError **)error;
- (NSString *)d83Data787980;

@end
