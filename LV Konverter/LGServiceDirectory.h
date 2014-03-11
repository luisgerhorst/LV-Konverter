//
//  LGServiceDirectory.h
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

@class LGErrors;


// Error constants.

extern NSString * const LGErrorDomain;

extern NSInteger const LGInvalidFieldCount;
extern NSInteger const LGInvalidStructureUnregularDepth;
extern NSInteger const LGInvalidStructureGroupUnderService;
extern NSInteger const LGInvalidStructureServiceUnderService;
extern NSInteger const LGInvalidStructureGroupInServiceLayer;
extern NSInteger const LGInvalidStructureServiceInGroupLayer;
extern NSInteger const LGServiceDirectoryStringTooLong;

extern NSInteger const LGUnrecognizeableLine;
extern NSString * const LGUnrecognizeableLine_LineIndexKey;

extern NSInteger const LGUnrecognizeableLineWithOrdinalNumber;
extern NSString * const LGUnrecognizeableLineWithOrdinalNumber_LineIndexKey;
extern NSString * const LGUnrecognizeableLineWithOrdinalNumber_OrdinalNumberKey;

extern NSInteger const LGDeadFieldsWithTextInServiceTextChunkLine;
extern NSString * const LGDeadFieldsWithTextInServiceTextChunkLine_LineIndexKey;


// Class interface.

@interface LGServiceDirectory : LGNode // Leistungsverzeichnis

+ (LGServiceDirectory *)serviceDirectoryWithCSVString:(NSString *)csvString errors:(LGErrors *)problems;

// 01 Informationen Leistungsverzeichnis
@property NSString *title; // LVBEZ - Bezeichnung des Leistungsverzeichnisses

// 02 Informationen Projekt
@property NSString *project; // PROBEZ - Bezeichnung des Projekts

// 03 Informationen Auftraggeber
@property NSString *client; // AGBEZ - Bezeichnung des Auftraggebers

- (NSString *)d83StringAndErrors:(LGErrors *)errors;

@end
