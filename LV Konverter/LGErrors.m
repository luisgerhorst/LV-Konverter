//
//  LGProblems.m
//  LV Konverter
//
//  Created by Luis Gerhorst on 17.02.14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import "LGErrors.h"

#import "LGServiceDirectory.h"
#import "LGServiceGroup.h"
#import "LGService.h"
#import "LGServiceType.h"

#import "LGOrdinalNumber.h"


// Summarized, range 500 -> 599.

NSInteger const LGUnrecognizeableLineSummarized = 500;
NSInteger const LGUnrecognizeableLineWithOrdinalNumberSummarized = 501;
NSInteger const LGDeadFieldsWithTextInServiceTextChunkLineSummarized = 502;
NSInteger const LGServiceGroupTitleTooLongSummarized = 503;
NSInteger const LGServiceUnitTooLongSummarized = 504;
NSInteger const LGServiceTitleTooLongSummarized = 505;
NSInteger const LGInvalidServiceTypeSummarized = 506;

// Error priorities.

NSString * const LGErrorPriorityKey = @"errorPriority";
NSString * const LGErrorPriorityFatal = @"Fehler";
NSString * const LGErrorPriorityWarning = @"Warnung";


@interface LGErrors ()

@property NSMutableArray *errors;

@end


@implementation LGErrors

- (id)init
{
    self = [super init];
    if (self) {
        _errors = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    return [self.errors description];
}

#pragma mark Modify

- (void)addError:(NSError *)error
{
    [self.errors addObject:error];
}

- (void)addErrors:(LGErrors *)errorsToAdd
{
    [self.errors addObjectsFromArray:[errorsToAdd arrayValue]];
}

- (NSArray *)arrayValue
{
    return self.errors;
}

#pragma mark Access

- (BOOL)errorsExist
{
    if ([self.errors count]) return YES;
    else return NO;
}

NSString *arrayToHumanList(NSArray *array, NSString *singular, NSString *plural) {
    NSUInteger arrayCount = [array count];
    if (!arrayCount) @throw [NSException exceptionWithName:@"LGarrayToHumanListEmptyArray"
                                                    reason:@"The array passed has 0 elements."
                                                  userInfo:nil];
    else if (arrayCount == 1) return [NSString stringWithFormat:singular, array[0]];
    else {
        NSMutableString *humanList = [NSMutableString string];
        for (NSUInteger i = 0; i < arrayCount - 2; i++) {
            [humanList appendString:array[i]];
            [humanList appendString:@", "];
        }
        [humanList appendString:array[arrayCount - 2]];
        [humanList appendString:@" und "];
        [humanList appendString:array[arrayCount - 1]];
        return [NSString stringWithFormat:plural, humanList];
    }
}

- (NSArray *)summarizedErrors
{
    NSMutableArray *summarized = [NSMutableArray array];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary]; // Key: error code as NSNumber, Value: Array with strings.
    for (NSError *error in self.errors) {
        NSInteger errorCode = [error code];
        NSNumber *errorCodeNumber = @(errorCode);
        
        #define createIfNil if (!data[errorCodeNumber]) data[errorCodeNumber] = [NSMutableArray array];
        
        if (LGUnrecognizeableLine == errorCode) {
            createIfNil
            [data[errorCodeNumber] addObject:[@([[error userInfo][LGUnrecognizeableLine_LineIndexKey] unsignedIntegerValue] + 1) stringValue]];
        }
        
        else if (LGUnrecognizeableLineWithOrdinalNumber == errorCode) {
            createIfNil
            NSDictionary *errorUserInfo = [error userInfo];
            [data[errorCodeNumber] addObject:[NSString stringWithFormat:@"%@ (Zeile %lu)",
                                                                        [errorUserInfo[LGUnrecognizeableLineWithOrdinalNumber_OrdinalNumberKey] stringValue],
                                                                        [errorUserInfo[LGUnrecognizeableLineWithOrdinalNumber_LineIndexKey] unsignedIntegerValue]+1]];
        }
        
        else if (LGDeadFieldsWithTextInServiceTextChunkLine == errorCode) {
            createIfNil
            [data[errorCodeNumber] addObject:[@([[error userInfo][LGDeadFieldsWithTextInServiceTextChunkLine_LineIndexKey] unsignedIntegerValue] + 1) stringValue]];
        }
        
        else if (LGServiceGroupTitleTooLong == errorCode) {
            createIfNil
            [data[errorCodeNumber] addObject:[[error userInfo][LGServiceGroupTitleTooLong_OrdinalNumberKey] stringValue]];
        }
        
        else if (LGServiceUnitTooLong == errorCode) {
            createIfNil
            [data[errorCodeNumber] addObject:[[error userInfo][LGServiceUnitTooLong_OrdinalNumberKey] stringValue]];
        }
        
        else if (LGServiceTitleTooLong == errorCode) {
            createIfNil
            [data[errorCodeNumber] addObject:[[error userInfo][LGServiceTitleTooLong_OrdinalNumberKey] stringValue]];
        }
        
        else if (LGInvalidServiceType == errorCode) {
            createIfNil
            [data[errorCodeNumber] addObject:[NSString stringWithFormat:@"\"%@\"", [error userInfo][LGInvalidServiceType_ServiceTitleKey]]];
        }
        
        else {
            [summarized addObject:error];
        }
        
    }
    
    for (NSNumber *errorCodeNumber in data) {
        NSInteger errorCode = [errorCodeNumber integerValue];
        
        if (LGUnrecognizeableLine == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                                        @"%@. Zeile",
                                                        @"Zeilen %@");
            NSString *description = [NSString stringWithFormat:@"Die %@ der CSV-Datei konnten leider nicht erkannt werden.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGUnrecognizeableLineSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey: description,
                                                             LGErrorPriorityKey: LGErrorPriorityWarning}]];
        }
        
        else if (LGUnrecognizeableLineWithOrdinalNumber == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                                        @"Der Ordnungspunkt %@ konnte leider nicht eindeutig als Teilleistung oder LV-Gruppe",
                                                        @"Die Ordnungspunkte %@ konnten leider nicht eindeutig als Teilleistungen oder LV-Gruppen");
            NSString *description = [NSString stringWithFormat:@"%@ erkannt werden.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGUnrecognizeableLineWithOrdinalNumberSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey: description,
                                                             LGErrorPriorityKey: LGErrorPriorityFatal}]];
        }
        
        else if (LGDeadFieldsWithTextInServiceTextChunkLine == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                                        @"der %@. Zeile",
                                                        @"den Zeilen %@");
            NSString *description = [NSString stringWithFormat:@"Achtung: Lediglich Text aus der 2. Spalte zählt zum Langtext einer Teilleistung, in %@ haben auch andere Spalten einen Inhalt, dieser wurde ignoriert.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGDeadFieldsWithTextInServiceTextChunkLineSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey: description,
                                                             LGErrorPriorityKey: LGErrorPriorityWarning}]];
        }
        
        else if (LGServiceGroupTitleTooLong == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                              @"Der Titel der LV-Gruppe mit der Ordnungszahl %@ ist",
                                              @"Die Titel der LV-Gruppen mit den Ordnungszahlen %@ sind");
            NSString *description = [NSString stringWithFormat:@"%@ zu lang, der Titel einer LV-Gruppe darf aus maximal 40 Zeichen bestehen.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGServiceGroupTitleTooLongSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey:description,
                                                             LGErrorPriorityKey: LGErrorPriorityWarning}]];
        }
        
        else if (LGServiceUnitTooLong == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                                        @"Einheit der Teilleistung mit der Ordnungszahl %@ ist",
                                                        @"Einheiten der Teilleistungen mit den Ordnungszahlen %@ sind");
            NSString *description = [NSString stringWithFormat:@"Die %@ zu lang, eine Einheit muss aus eins bis vier Zeichen bestehen.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGServiceUnitTooLongSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey:description,
                                                             LGErrorPriorityKey: LGErrorPriorityFatal}]];
        }
        
        else if (LGServiceTitleTooLong == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                                        @"Der Titel der Teilleistung mit der Ordnungszahl %@ ist",
                                                        @"Die Titel der Teilleistungen mit den Ordnungszahlen %@ sind");
            NSString *description = [NSString stringWithFormat:@"%@ zu lang, der Titel einer Teilleistung darf aus maximal 70 Zeichen bestehen.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGServiceTitleTooLongSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey:description,
                                                             LGErrorPriorityKey: LGErrorPriorityWarning}]];
        }
        
        else if (LGInvalidServiceType == errorCode) {
            NSString *varDescription = arrayToHumanList(data[errorCodeNumber],
                                                        @"Die Kombination von Art und Einheit der Teilleistung mit dem Titel %@ ist",
                                                        @"Die Kombinationen von Art und Einheit der Teilleistungen mit den Titeln %@ sind");
            NSString *description = [NSString stringWithFormat:@"%@ ungültig.", varDescription];
            [summarized addObject:[NSError errorWithDomain:LGErrorDomain
                                                      code:LGInvalidServiceTypeSummarized
                                                  userInfo:@{NSLocalizedDescriptionKey:description,
                                                             LGErrorPriorityKey: LGErrorPriorityFatal}]];
        }
        
    }
    
    return summarized;
}

@end
