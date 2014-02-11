//
//  LGServiceDirectory.m
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

#import "LGServiceDirectory.h"
#import "LGOrdinalNumber.h"
#import "LGStack.h"
#import "LGSet.h"
#import "LGServiceGroup.h"
#import "LGService.h"
#import "LGMutableOrdinalNumber.h"
#import "LGOrdinalNumberScheme.h"
#import "NSArray+LGCSVParser.h"

BOOL isEmpty(NSString *string) {
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [trimmed length] == 0;
}

NSString *removeSpaces(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@implementation LGServiceDirectory

/*
 * Reads a csv with a specific structure and return a object structure
 */
+ (LGServiceDirectory *)serviceDirectoryWithCSVString:(NSString *)csvString
{
    
    NSArray *array = [NSArray arrayWithCSVString:csvString];
    
    LGServiceDirectory *serviceDirectory = [[LGServiceDirectory alloc] init];
    
    LGStack *stack = [[LGStack alloc] init]; // Stack that contains current parent of each node layer.
    [stack push:serviceDirectory];
    
    for (NSArray *line in array) {
        
        if ([line count] < 5) @throw [NSException exceptionWithName:@"LGServiceDirectoryInvalidTableStructure" reason:[NSString stringWithFormat:@"Invalid array. Table must have at least 5 collumns."] userInfo:nil];
        
        LGOrdinalNumber_Type ordinalNumberType;
        LGOrdinalNumber *ordinalNumber = [[LGOrdinalNumber alloc] initWithCSVString:line[0] type:&ordinalNumberType];
        
        // Todo: Improve detection, save warnings/errors.
        
        // Service Group:
        if (ordinalNumber &&
            ordinalNumberType == LGOrdinalNumber_Type_Group &&
            !isEmpty(line[1])) { // Has a title.
            
            if ([[stack objectOnTop] class] == [LGService class]) [[stack objectOnTop] trimText]; // Finished previous service.
            
            LGServiceGroup *group = [[LGServiceGroup alloc] initWithTitle:line[1]];
            
            NSUInteger toPop = [stack heigth] - [ordinalNumber depth];
            [stack pop:toPop];
            [[stack objectOnTop] appendChild:group];
            [stack push:group];
            
        // Service:
        } else if (ordinalNumber &&
                   ordinalNumberType == LGOrdinalNumber_Type_Service && // Ordinal number of a service.
                   !isEmpty(line[1]) && // Has title.
                   [line[2] floatValue] > 0 && // Quantity > 0
                   !isEmpty(line[3]) && [line[3] length] <= 4) { // Has unit with valid length.
            
            if ([[stack objectOnTop] class] == [LGService class]) [[stack objectOnTop] trimText]; // finished previous service
            
            LGService *service = [[LGService alloc] initWithTitle:line[1] ofQuantity:[line[2] floatValue] inUnit:line[3] withCSVTypeString:line[4]];
            
            NSUInteger toPop = [stack heigth] - [ordinalNumber depth]; // maybe you have to pop another service first
            [stack pop:toPop];
            [[stack objectOnTop] appendChild:service];
            [stack push:service];
            
        // Service Text Chunk:
        } else if ([[stack objectOnTop] class] == [LGService class]) { // parent is service
            
            [[stack objectOnTop] appendTextChunk:line[1]];
        
        }
        
    }
    
    if ([[stack objectOnTop] class] == [LGService class]) [[stack objectOnTop] trimText]; // finished last service
    
    if (![serviceDirectory layersValid]) @throw [NSException exceptionWithName:@"LGInvalidLayers" reason:@"Each service must have the same number of parent layers" userInfo:nil];
    
    return serviceDirectory;
}

- (id)init
{
    self = [super init];
    if (self) {
        client = @"";
        project = @"";
        description = @"";
        date = [NSDate date];
    }
    return self;
}

// Accessors

- (void)setProject:(NSString *)aProjectTitle
{
    project = aProjectTitle;
}

- (void)setDescription:(NSString *)aServiceDirectoryDescription
{
    description = aServiceDirectoryDescription;
}

- (void)setClient:(NSString *)aClientName
{
    client = aClientName;
}

- (void)setDate:(NSDate *)aDate
{
    date = aDate;
}

// D83

- (NSString *)d83String
{
    
    NSArray *sets = [self d83Sets];
    
    NSMutableString *d83String = nil;
    NSUInteger setNumber = 1;
    for (LGSet *set in sets) {
        if (!d83String) d83String = [NSMutableString stringWithFormat:@"%@", [set stringForSetNumber:setNumber]];
        else [d83String appendFormat:@"\n%@", [set stringForSetNumber:setNumber]];
        setNumber++;
    }
    
    return d83String;
    
}

- (NSArray *)d83Sets
{
    NSMutableArray *sets = [NSMutableArray array];
    
    [sets addObject:[self d83Set00]];
    [sets addObject:[self d83Set01]];
    [sets addObject:[self d83Set02]];
    [sets addObject:[self d83Set03]];
    
    LGMutableOrdinalNumber *ordinalNumber = [[LGMutableOrdinalNumber alloc] init]; // Internally created array with a zero.
    LGOrdinalNumberScheme *ordinalNumberScheme = [[LGOrdinalNumberScheme alloc] initWithMaxChildCounts:[self maxChildCounts]];
    
    // Own children are at the top.
    for (LGNode *child in children) {
        [ordinalNumber next];
        [sets addObjectsFromArray:[child d83SetsWithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber ofScheme:ordinalNumberScheme]];
    }
    
    [sets addObject:[self d83Set99]];
    
    return sets;
}

// Sets

- (LGSet *)d83Set00 // 00 Eröffnungssatz Leistungsverzeichnis
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:00];
    [set setString:@"83" range:NSMakeRange(10, 2)]; // DP
    [set setString:@"L" range:NSMakeRange(12, 1)]; // KURZLANG
    [set setString:[self d83Data74] range:NSMakeRange(62, 9)]; // OZMASKE
    [set setString:@"90" range:NSMakeRange(71, 2)]; // VERSDTA
    return set;
}

- (LGSet *)d83Set01 // 01 Information Leistungsverzeichnis
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:01];
    
    [set setCutString:description range:NSMakeRange(2,40)]; // LVBEZ
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    [set setString:dateString range:NSMakeRange(42,8)]; // LVDATUM
    
    return set;
}

- (LGSet *)d83Set02 // 02 Information Projekt
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:02];
    
    [set setCutString:project range:NSMakeRange(2,60)]; // PROBEZ
    
    return set;
}

- (LGSet *)d83Set03 // 03 Information Auftraggeber
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:03];
    [set setCutString:client range:NSMakeRange(2,60)]; // AGBEZ
    return set;
}

- (LGSet *)d83Set99 // 99 Abschlußsatz Leistungsverzeichnis
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:99];
    
    [set setInteger:[self d83Data9] range:NSMakeRange(69,5)]; // ANZTEIL
    
    return set;
}

// Data

- (NSString *)d83Data74 // 74 - OZMASKE - Maske zur OZ-Interpretation
{
    return [[[LGOrdinalNumberScheme alloc] initWithMaxChildCounts:[self maxChildCounts]] d83Data74];
}

- (NSUInteger)d83Data9 // 9 - ANZTEIL - Anzahl der Teilleistungen im Leistungsverzeichnis
{
    return [super servicesCount];
}

// Other

- (NSString *)description
{
    return @"<ServiceDirectory>";
}

@end
