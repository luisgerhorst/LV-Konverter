//
//  LGServiceDirectory.m
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

#import "LGServiceDirectory.h"
#import "LGOrdinalNumber.h"
#import "LGStack.h"
#import "LGSet.h"
#import "LGServiceGroup.h"
#import "LGService.h"
#import "LGMutableOrdinalNumber.h"
#import "LGOrdinalNumberScheme.h"
#import "NSArray+LGCSVParser.h"
#import "LGErrors.h"
#import "LGNode.h"

#import "LGErrors.h"


NSString * const LGErrorDomain = @"com.Luis-Gerhorst.LV-Konverter.ErrorDomain";

// Range 0 -> 99.

// Final, will be presented to the user directly.

NSInteger const LGInvalidFieldCount = 0;
NSInteger const LGInvalidStructureUnregularDepth = 1;
NSInteger const LGInvalidStructureGroupUnderService = 2;
NSInteger const LGInvalidStructureServiceUnderService = 3;
NSInteger const LGInvalidStructureGroupInServiceLayer = 4;
NSInteger const LGInvalidStructureServiceInGroupLayer = 5;
NSInteger const LGServiceDirectoryStringTooLong = 6;

// Summarize in LGErrors.

NSInteger const LGUnrecognizeableLine = 7;
NSString * const LGUnrecognizeableLine_LineIndexKey = @"lineIndex";

NSInteger const LGUnrecognizeableLineWithOrdinalNumber = 8;
NSString * const LGUnrecognizeableLineWithOrdinalNumber_LineIndexKey = @"lineIndex";
NSString * const LGUnrecognizeableLineWithOrdinalNumber_OrdinalNumberKey = @"ordinalNumber";

NSInteger const LGDeadFieldsWithTextInServiceTextChunkLine = 9;
NSString * const LGDeadFieldsWithTextInServiceTextChunkLine_LineIndexKey = @"lineIndex";


// Functions

BOOL isEmpty(NSString *string) {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [string length] == 0;
}

NSString *removeSpaces(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


// Private Properties

@interface LGServiceDirectory ()

@property NSDate *date; // LVDATUM - Datum des Leistungsverzeichnisses

@end


// Class Implementation

@implementation LGServiceDirectory

/*
 * Reads a csv with a specific structure and return an object
 */
+ (LGServiceDirectory *)serviceDirectoryWithCSVString:(NSString *)csvString errors:(LGErrors *)errors
{
    NSArray *array = [NSArray arrayWithCSVString:csvString];
    
    LGServiceDirectory *serviceDirectory = [[LGServiceDirectory alloc] init];
    
    LGStack *stack = [[LGStack alloc] init]; // Stack that contains current parent of each node layer.
    [stack push:serviceDirectory];
    
    NSInteger currentLineIndex = -1;
    for (NSArray *line in array) {
        currentLineIndex++;
        
        if ([line count] < 5) {
            [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                  code:LGInvalidFieldCount
                                              userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Die CSV-Datei scheint fehlerhaft zu sein, die %ld. Zeile besteht lediglich aus %lu Feldern bzw. Spalten, es müssten aber mindestens 5 sein (Ordnungszahl, Text, Menge, Einheit und Art).", currentLineIndex+1, (unsigned long)[line count]],
                                                         LGErrorPriorityKey: LGErrorPriorityFatal}]];
            return nil;
        }
        
        LGOrdinalNumber *ordinalNumber = [[LGOrdinalNumber alloc] initWithCSVString:line[0]]; // Returns nil if is no valid ordinal number.
        
        // Service Group:
        if (ordinalNumber &&
            !isEmpty(line[1]) && // Has a title.
            isEmpty(line[2]) && // No quantity.
            isEmpty(line[3]) && // No unit.
            isEmpty(line[4])) { // No type.
            
            if ([[stack objectOnTop] class] == [LGService class]) [[stack objectOnTop] trimText]; // Finished previous service.
            
            LGServiceGroup *group = [[LGServiceGroup alloc] initWithTitle:line[1]];
            
            NSUInteger toPop = [stack heigth] - [ordinalNumber depth];
            [stack pop:toPop];
            NSError *appendChildError = [[stack objectOnTop] appendChild:group];
            if (appendChildError) { // Something with the structure is wrong, you're going to miss a service/group.
                NSInteger code = [appendChildError code];
                NSDictionary *userInfo = [appendChildError userInfo];
                if (code == LGNoChildrenAllowed && [[stack objectOnTop] class] == [LGService class]) { // You tried to add a Group as child of a Service.
                    [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                          code:LGInvalidStructureGroupUnderService
                                                      userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Die LV-Gruppe \"%@\" kann kein Unterpunkt der Teilleistung \"%@\" sein.",
                                                                                             [group title], [[stack objectOnTop] title]],
                                                                 LGErrorPriorityKey: LGErrorPriorityFatal}]];
                } else if (code == LGInvalidChildClass && userInfo[LGInvalidChildClass_ExpectedClassKey] == [LGService class]) { // You tried to add a Group to a Group that already has Services as children.
                    [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                          code:LGInvalidStructureGroupInServiceLayer
                                                      userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Die LV-Gruppe \"%@\" kann kein Unterpunkt der LV-Gruppe \"%@\" sein, da diese berreits Teilleistungen als Unterpunkte hat. Wenn der Ordnungspunkt mit dem Titel \"%@\" keine LV-Gruppe sondern eine Teilleistung ist überprüfen Sie dessen Ordnungszahl.",
                                                                                             [group title], [[stack objectOnTop] title], [group title]],
                                                                 LGErrorPriorityKey: LGErrorPriorityFatal}]];
                } else {
                    @throw [NSException exceptionWithName:@"Unknown error returned by -(NSError *)appendChild:(LGServiceGroup *) call"
                                                   reason:nil
                                                 userInfo:@{@"error": appendChildError,
                                                            @"lineIndex": @(currentLineIndex),
                                                            @"ordinalNumber": ordinalNumber}];
                }
                return nil;
            }
            [stack push:group];
            
        // Service:
        } else if (ordinalNumber &&
                   !isEmpty(line[1]) && // Has title.
                   [line[2] floatValue] > 0 && // Quantity > 0
                   !isEmpty(line[3]) && [line[3] length] <= 4 && // Has unit with valid length.
                   (isEmpty(line[4]) || [@"BG" isEqualToString:removeSpaces(line[4])] || [@"BE" isEqualToString:removeSpaces(line[4])])) { // Has valid type.
            
            if ([[stack objectOnTop] class] == [LGService class]) [[stack objectOnTop] trimText]; // Finish previous service.
            
            LGService *service = [[LGService alloc] initWithTitle:line[1]
                                                       ofQuantity:[line[2] floatValue]
                                                           inUnit:line[3]
                                                withCSVTypeString:line[4]
                                                           errors:errors];
            
            NSUInteger toPop = [stack heigth] - [ordinalNumber depth]; // Maybe you have to pop another service first.
            [stack pop:toPop];
            NSError *appendChildError = [[stack objectOnTop] appendChild:service];
            if (appendChildError) { // Something with the structure is wrong, you're going to miss a service/group. Return nil because continuing after this error will cause other structural errors.
                NSInteger code = [appendChildError code];
                NSDictionary *userInfo = [appendChildError userInfo];
                if (code == LGNoChildrenAllowed && [[stack objectOnTop] class] == [LGService class]) { // You tried to add a Service as child of a Service.
                    [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                         code:LGInvalidStructureServiceUnderService
                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Die Teilleistung \"%@\" kann kein Unterpunkt der Teilleistung \"%@\" sein.",
                                                                                            [service title], [[stack objectOnTop] title]],
                                                                LGErrorPriorityKey: LGErrorPriorityFatal}]];
                } else if (code == LGInvalidChildClass && userInfo[LGInvalidChildClass_ExpectedClassKey] == [LGServiceGroup class]) { // You tried to add a Service to a Group that already has Groups as children.
                    [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                         code:LGInvalidStructureServiceInGroupLayer
                                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Die Teilleistung \"%@\" kann kein Unterpunkt der LV-Gruppe \"%@\" sein, da diese berreits LV-Gruppen als Unterpunkte hat. Überprüfen Sie die Ordnungszahlen der Unterpunkte der LV-Gruppe mit dem Titel \"%@\".", [service title], [[stack objectOnTop] title], [[stack objectOnTop] title]],
                                                                LGErrorPriorityKey: LGErrorPriorityFatal}]];
                } else { // May be thrown if developer invents new classes for example.
                    @throw [NSException exceptionWithName:@"Unknown error returned by appendChild: call."
                                                   reason:nil
                                                 userInfo:@{@"error": appendChildError,
                                                            @"lineIndex": @(currentLineIndex),
                                                            @"ordinalNumber": ordinalNumber}];
                }
                return nil;
            }
            [stack push:service];
            
        // Service Text Chunk:
        } else if (!ordinalNumber && [[stack objectOnTop] class] == [LGService class]) {
            
            [[stack objectOnTop] appendTextChunk:line[1]];
            
            if (!isEmpty(line[0]) || !isEmpty(line[2]) || !isEmpty(line[3]) || !isEmpty(line[4])) {
                [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                     code:LGDeadFieldsWithTextInServiceTextChunkLine
                                                 userInfo:@{LGDeadFieldsWithTextInServiceTextChunkLine_LineIndexKey: @(currentLineIndex)}]];
            }
        
        } else {
            
            if (ordinalNumber) {
                [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                     code:LGUnrecognizeableLineWithOrdinalNumber
                                                 userInfo:@{LGUnrecognizeableLineWithOrdinalNumber_LineIndexKey: @(currentLineIndex),
                                                            LGUnrecognizeableLineWithOrdinalNumber_OrdinalNumberKey: ordinalNumber}]];
            } else if (!(isEmpty(line[0]) && isEmpty(line[1]) && isEmpty(line[2]) && isEmpty(line[3]) && isEmpty(line[4])) && // Line isn't empty, and ...
                       currentLineIndex != 0) { // ... its the not first line.
                [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                     code:LGUnrecognizeableLine
                                                 userInfo:@{LGUnrecognizeableLine_LineIndexKey: @(currentLineIndex)}]];
            }
            
        }
    
    }
    
    if ([[stack objectOnTop] class] == [LGService class]) [[stack objectOnTop] trimText]; // Finish last service.
    
    if (![serviceDirectory layersValid]) {
        [errors addError:[NSError errorWithDomain:LGErrorDomain
                                             code:LGInvalidStructureUnregularDepth
                                         userInfo:@{NSLocalizedDescriptionKey: @"Jede Teilleistung jeder LV-Gruppe muss gleich viele Ebenen an LV-Gruppen über sich haben, d.h. die Ordnungszahlen aller Teilleistungen müssen gleich viele Stellen haben.",
                                                    LGErrorPriorityKey: LGErrorPriorityFatal}]];
        return nil;
    }
                               
    return serviceDirectory;
}

#pragma mark Common

- (id)init
{
    self = [super init];
    if (self) {
        _client = @"";
        _project = @"";
        _title = @"";
        _date = [NSDate date];
    }
    return self;
}

- (NSString *)description
{
    return @"<ServiceDirectory>";
}

#pragma mark Key-Value Coding

- (BOOL)validateTitle:(id *)title error:(NSError *__autoreleasing *)outError
{
    if (!*title) {
        return YES;
    } else if ([(NSString *)*title length] > 40) {
        *outError = [NSError errorWithDomain:LGErrorDomain
                                        code:LGServiceDirectoryStringTooLong
                                    userInfo:@{NSLocalizedDescriptionKey: @"Der Titel des Leistungsverzeichnisses darf aus maximal 40 Zeichen bestehen."}];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validateProject:(id *)project error:(NSError *__autoreleasing *)outError
{
    NSLog(@"Validating project %@", *project);
    if (!*project) {
        return YES;
    } else if ([(NSString *)*project length] > 60) {
        *outError = [NSError errorWithDomain:LGErrorDomain
                                        code:LGServiceDirectoryStringTooLong
                                    userInfo:@{NSLocalizedDescriptionKey: @"Die Bezeichnung des Projekts darf aus maximal 60 Zeichen bestehen."}];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validateClient:(id *)client error:(NSError *__autoreleasing *)outError
{
    if (!*client) {
        return YES;
    } else if ([(NSString *)*client length] > 60) {
        *outError = [NSError errorWithDomain:LGErrorDomain
                                        code:LGServiceDirectoryStringTooLong
                                    userInfo:@{NSLocalizedDescriptionKey: @"Die Bezeichnung des Auftraggebers darf aus maximal 60 Zeichen bestehen."}];
        return NO;
    } else {
        return YES;
    }
}

- (void)setNilValueForKey:(NSString *)key {
    
    if ([key isEqualToString:@"title"] || [key isEqualToString:@"project"] || [key isEqualToString:@"client"]) {
        [self setValue:@"" forKey:key];
    } else {
        [super setNilValueForKey:key];
    }
}

#pragma mark D83

- (NSString *)d83StringAndErrors:(LGErrors *)errors
{
    NSArray *sets = [self d83SetsAndErrors:errors];
    
    NSMutableString *d83String = nil;
    NSUInteger setNumber = 0;
    for (LGSet *set in sets) {
        setNumber++;
        if (!d83String) d83String = [NSMutableString stringWithFormat:@"%@", [set stringForSetNumber:setNumber]];
        else [d83String appendFormat:@"\n%@", [set stringForSetNumber:setNumber]]; // Error if there are too many sets (max 6 digits).
    }
    
    return d83String;
}

- (NSArray *)d83SetsAndErrors:(LGErrors *)errors
{
    NSMutableArray *sets = [NSMutableArray array];
    
    [sets addObject:[self d83Set00]];
    [sets addObject:[self d83Set01AndErrors:errors]];
    [sets addObject:[self d83Set02AndErrors:errors]];
    [sets addObject:[self d83Set03AndErrors:errors]];
    
    LGMutableOrdinalNumber *ordinalNumber = [[LGMutableOrdinalNumber alloc] init]; // Internally creates an array with a zero.
    LGOrdinalNumberScheme *ordinalNumberScheme = [[LGOrdinalNumberScheme alloc] initWithMaxChildCounts:[self maxChildCounts]];
    
    // Own children are at the top.
    for (LGNode *child in children) {
        [ordinalNumber next];
        [sets addObjectsFromArray:[child d83SetsWithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber
                                                         ofScheme:ordinalNumberScheme
                                                           errors:errors]];
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

- (LGSet *)d83Set01AndErrors:(LGErrors *)errors // 01 Information Leistungsverzeichnis
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:01];
    
    if ([set setCutString:self.title range:NSMakeRange(2,40)]) // LVBEZ, returns YES if string was too long.
        [errors addError:[NSError errorWithDomain:LGErrorDomain
                                             code:LGServiceDirectoryStringTooLong
                                         userInfo:@{NSLocalizedDescriptionKey: @"Der Titel des Leistungsverzeichnisses darf aus maximal 40 Zeichen bestehen.",
                                                    LGErrorPriorityKey: LGErrorPriorityWarning}]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    NSString *dateString = [dateFormatter stringFromDate:self.date];
    [set setString:dateString range:NSMakeRange(42,8)]; // LVDATUM
    
    return set;
}

- (LGSet *)d83Set02AndErrors:(LGErrors *)errors // 02 Information Projekt
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:02];
    // PROBEZ:
    if ([set setCutString:self.project range:NSMakeRange(2,60)]) [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                                                                 code:LGServiceDirectoryStringTooLong
                                                                                             userInfo:@{NSLocalizedDescriptionKey: @"Die Bezeichnung des Projekts darf aus maximal 60 Zeichen bestehen.",
                                                                                                        LGErrorPriorityKey: LGErrorPriorityWarning}]];
    return set;
}

- (LGSet *)d83Set03AndErrors:(LGErrors *)errors // 03 Information Auftraggeber
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:03];
    // AGBEZ:
    if ([set setCutString:self.client range:NSMakeRange(2,60)]) [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                                                                code:LGServiceDirectoryStringTooLong
                                                                                            userInfo:@{NSLocalizedDescriptionKey: @"Die Bezeichnung des Auftraggebers darf aus maximal 60 Zeichen bestehen.",
                                                                                                       LGErrorPriorityKey: LGErrorPriorityWarning}]];
    return set;
}

- (LGSet *)d83Set99 // 99 Abschlußsatz Leistungsverzeichnis
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:99];
    [set setInteger:[self d83Data9] range:NSMakeRange(69,5)]; // ANZTEIL, may cause error.
    return set;
}

// Data

- (NSString *)d83Data74 // 74 - OZMASKE - Maske zur OZ-Interpretation
{
    return [[[LGOrdinalNumberScheme alloc] initWithMaxChildCounts:[self maxChildCounts]] d83Data74]; // May cause error if there are too many services and/or service groups, then the length of the OZMASKE may be too long.
}

- (NSUInteger)d83Data9 // 9 - ANZTEIL - Anzahl der Teilleistungen im Leistungsverzeichnis
{
    return [super servicesCount];
}

@end
