//
//  LGNode.m
//  csvToD83
//
//  Created by Luis Gerhorst on 18.12.13.
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

#import "LGNode.h"
#import "LGService.h"
#import "LGMutableOrdinalNumber.h"

@implementation LGNode

- (id)init
{
    self = [super init];
    if (self) {
        children = [NSMutableArray array];
    }
    return self;
}

// used by LGService to make sure no children are appended to them
- (id)initWithoutChildren
{
    self = [super init];
    return self;
}

- (NSMutableArray *)children
{
    return children;
}

// existing layers must be complete (all their children must be already added)
- (void)appendChild:(LGNode *)aChild
{
    if ([children count] && ([[children objectAtIndex:0] class] != [aChild class])) @throw [NSException exceptionWithName:@"LGBadAddChildCall" reason:[NSString stringWithFormat:@"Node %@ can only contain children of class %@ (not %@)", self, [[children objectAtIndex:0] class], [aChild class]] userInfo:nil]; // if node already has children, new child must be of the same type (can't check for layers equality here because new child might not be complete yet)
    else [children addObject:aChild];
}

- (BOOL)layersValid
{
    NSUInteger layers = [[children objectAtIndex:0] layers];
    for (LGNode *child in children) {
        if ([child layers] != layers) return NO;
    }
    return YES;
}

// recursive stuff:

- (NSUInteger)layers
{
    if (children && [children count])
        return [[children objectAtIndex:0] layers] + 1;
    else
        return 1;
}

/*
 Array with max number of children of each layer
 If has no children returns array with a zero
 needed for efficient OZMASKE
 */
- (NSArray *)maxChildCounts
{
    
    NSMutableArray *childrensMaxCounts;
    for (LGNode *child in children) { // each child
        NSArray *childsMaxCounts = [child maxChildCounts]; // get max child counts
        if (!childrensMaxCounts) childrensMaxCounts = [NSMutableArray arrayWithArray:childsMaxCounts];
        else {
            for (NSUInteger i = 0; i < [childsMaxCounts count]; i++) { // for each layer (under self)
                if ([[childrensMaxCounts objectAtIndex:i] compare:[childsMaxCounts objectAtIndex:i]] == NSOrderedAscending) { // if childs max of layer > max of layer
                    [childrensMaxCounts replaceObjectAtIndex:i withObject:[childsMaxCounts objectAtIndex:i]]; // max of layer = childs max of that layer
                }
            }
        }
    }
    
    // append childrensMaxCounts to own child count array
    NSMutableArray *full = [NSMutableArray arrayWithObject:[NSNumber numberWithInteger:[children count]]];
    [full addObjectsFromArray:childrensMaxCounts];
    
    return full;
}

// recursive with end element LGService
- (NSUInteger)servicesCount
{
    NSUInteger servicesCount = 0;
    for (LGNode *child in children) servicesCount += [child servicesCount];
    return servicesCount;
}

// to be overwritten:

/*
 rules:
 - always make the ordinal number ready for your children, they will directly insert themselves
 - return the ordinal number the same way you got it
 */
- (NSArray *)d83SetsWithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme
{
    @throw [NSException exceptionWithName:@"LGNode_d83SetsForOrdinalNumber" reason:@"Every class inheriting from LGNode has to overwrite the method - (NSArray *)d83SetsWithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme" userInfo:nil];
}

@end
