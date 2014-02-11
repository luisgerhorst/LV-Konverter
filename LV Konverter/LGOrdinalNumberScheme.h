//
//  LGOrdinalNumberScheme.h
//  csvToD83
//
//  Created by Luis Gerhorst on 27/01/14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

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
