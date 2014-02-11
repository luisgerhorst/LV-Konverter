//
//  LGServiceGroup.m
//  csvToD83
//
//  Created by Luis Gerhorst on 16.12.13.
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

#import "LGServiceGroup.h"
#import "LGMutableOrdinalNumber.h"
#import "LGSet.h"
#import "LGOrdinalNumberScheme.h"

@implementation LGServiceGroup

- (id)init
{
    @throw [NSException exceptionWithName:@"LGServiceGroupInitialization" reason:@"Use initWithTitle:, not init" userInfo:nil];
}

- (id)initWithTitle:(NSString *)string
{
    self = [super init];
    if (self) {
        title = string;
        type = LGServiceGroup_TYPE_N;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Group: %@>", title];
}

// Overwriting LGNode:

// D83

- (NSArray *)d83SetsWithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme
{
    NSMutableArray *sets = [NSMutableArray array];
    [sets addObject:[self d83Set11WithOrdinalNumber:ordinalNumber ofScheme:ordinalNumberScheme]];
    [sets addObject:[self d83Set12]];
    
    // put your own children one layer under you
    LGMutableOrdinalNumber *childrenOrdinalNumber = [[LGMutableOrdinalNumber alloc] initWithOrdinalNumber:ordinalNumber];
    [childrenOrdinalNumber layerDown];
    for (LGNode *child in children) {
        [childrenOrdinalNumber next]; // remeber: each new layer starts at 0
        [sets addObjectsFromArray: [child d83SetsWithOrdinalNumber:(LGOrdinalNumber *)childrenOrdinalNumber ofScheme:ordinalNumberScheme]];
    }
    
    [sets addObject:[self d83Set31WithOrdinalNumber:ordinalNumber ofScheme:ordinalNumberScheme]];

    return sets;
}

// Sets

- (LGSet *)d83Set11WithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme // 11 - Beginn einer LV-Gruppe
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:11];
    [set setString:[ordinalNumberScheme d83Data73OfOrdinalNumber:ordinalNumber] range:NSMakeRange(2, 9)]; // OZ
    [set setString:[self d83Data67] range:NSMakeRange(11, 1)]; // LVGRART
    return set;
}

- (LGSet *)d83Set12 // 12 - Bezeichnung der LV-Gruppe
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:12];
    [set setCutString:title range:NSMakeRange(2, 40)]; // LVGRBEZ todo: cut to avoid error
    return set;
}

- (LGSet *)d83Set31WithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme // 31 - Ende der LV-Gruppe
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:31];
    [set setString:[ordinalNumberScheme d83Data73OfOrdinalNumber:ordinalNumber] range:NSMakeRange(2, 9)]; // OZ
    return set;
}

// Data

- (NSString *)d83Data67 // 67 - LVGRART - Art der LV-Gruppe (as string)
{
    switch (type) {
        case LGServiceGroup_TYPE_N:
            return @"N";
        case LGServiceGroup_TYPE_G:
            return @"G";
        case LGServiceGroup_TYPE_A:
            return @"A";
    }
}

@end
