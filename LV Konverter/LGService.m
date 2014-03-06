//
//  LGService.m
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

#import "LGService.h"
#import "LGOrdinalNumber.h"
#import "LGOrdinalNumberScheme.h"
#import "LGSet.h"
#import "LGErrors.h"
#import "LGServiceDirectory.h"
#import "LGServiceType.h"


// Summarize in LGErrors, range 200 -> 299.

NSInteger const LGServiceUnitTooLong = 200;
NSString * const LGServiceUnitTooLong_OrdinalNumberKey = @"ordinalNumber";

NSInteger const LGServiceTitleTooLong = 201;
NSString * const LGServiceTitleTooLong_OrdinalNumberKey = @"ordinalNumber";


@implementation LGService

- (id)init
{
    @throw [NSException exceptionWithName:@"LGServiceInitialization"
                                   reason:@"Use initWithTitle:ofQuantity:inUnit:withCSVTypeString:, not init."
                                 userInfo:nil];
}

- (id)initWithTitle:(NSString *)aTitle
         ofQuantity:(float)aQuantity
             inUnit:(NSString *)aUnit
  withCSVTypeString:(NSString *)typeString
             errors:(LGErrors *)errors
{
    self = [super initWithoutChildren];
    if (self) {
        title = aTitle;
        quantity = aQuantity;
        unit = aUnit;
        
        NSError *error;
        type = [[LGServiceType alloc] initWithCSVString:typeString
                                     forServiceWithUnit:aUnit
                                                 error:&error];
        if (!type && [error code] == LGInvalidServiceType) {
            [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                 code:LGInvalidServiceType
                                             userInfo:@{LGInvalidServiceType_ServiceTitleKey: title}]];
        }
        
        text = [NSMutableString string];
    }
    return self;
}

- (void)appendTextChunk:(NSString *)textChunk
{
    if ([text length]) [text appendString:@"\n"];
    [text appendString:textChunk];
}

/*
 Called when adding of text chunks is done
 Removes empty lines and spaces from start/end of text
 */
- (void)trimText
{
    // remove whitespaces from line end
    NSRegularExpression *whitespacesLineEnd = [NSRegularExpression regularExpressionWithPattern:@"[ \t]+\n" options:0 error:nil];
    text = [NSMutableString stringWithString:[whitespacesLineEnd stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@"\n"]];
    
    // remove whitespaces from end
    NSRegularExpression *whitespacesEnd = [NSRegularExpression regularExpressionWithPattern:@"[ \t]+$" options:0 error:nil];
    text = [NSMutableString stringWithString:[whitespacesEnd stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@""]];
    
    // remove newlines from beginning
    NSRegularExpression *newlinesAtStart = [NSRegularExpression regularExpressionWithPattern:@"^+[\n]" options:0 error:nil];
    text = [NSMutableString stringWithString:[newlinesAtStart stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@""]];
    
    // removew newlines from end
    NSRegularExpression *newlinesAtEnd = [NSRegularExpression regularExpressionWithPattern:@"[\n]+$" options:0 error:nil];
    text = [NSMutableString stringWithString:[newlinesAtEnd stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:@""]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Service: %@>", title];
}

// Overwriting LGNode:

- (NSUInteger)servicesCount // end recursion
{
    return 1;
}

// D83

- (NSArray *)d83SetsWithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber
                             ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme
                               errors:(LGErrors *)errors
{
    NSMutableArray *sets = [NSMutableArray array];
    [sets addObject:[self d83Set21WithOrdinalNumber:ordinalNumber
                                           ofScheme:ordinalNumberScheme
                                             errors:errors]];
    [sets addObject:[self d83Set25AndErrors:errors
                              ordinalNumber:ordinalNumber]];
    
    // Split text by lines, spaces and long words by length and save them into an array.
    NSUInteger maxLength = 55; // max length of one line
    NSRegularExpression *wordLengthRegExp = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@".{1,%lu}", (unsigned long)maxLength] options:0 error:nil]; // 55 chars
    NSArray *inputLines = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *lines = [NSMutableArray array]; // output array
    for (NSString *line in inputLines) {
        if ([line length] <= maxLength) {
            [lines addObject:line];
        } else { // line too long
            NSArray *words = [line componentsSeparatedByString:@" "]; // split into words
            NSMutableString *cutLine = [NSMutableString string]; // current cut line
            for (NSString *word in words) {
                if ([word length] > maxLength) { // word too long for a line
                    NSArray *matches = [wordLengthRegExp matchesInString:word options:0 range:NSMakeRange(0,[word length])];
                    for (NSTextCheckingResult *match in matches) [lines addObject:[word substringWithRange:match.range]];
                } else if (([cutLine length] && [cutLine length] + [word length] + 1 <= maxLength) || (![cutLine length] && [word length] <= maxLength)) { // word fits into this line (with or without space)
                    if ([cutLine length]) [cutLine appendString:@" "];
                    [cutLine appendString:word];
                } else { // word must be in next line
                    [lines addObject:cutLine];
                    cutLine = [NSMutableString string];
                    [cutLine appendString:word];
                }
            }
            if ([cutLine length]) [lines addObject:cutLine]; // add final words of line
        }
    }
    
    // Add chunks to sets.
    for (NSString *chunk in lines) [sets addObject:[self d83Set26WithChunk:chunk]];
    
    // Creates one empty 26 set even if text is empty.
    // Each service needs at least one 26 set.
    
    return sets;
}

// Sets

- (LGSet *)d83Set21WithOrdinalNumber:(LGOrdinalNumber *)ordinalNumber
                            ofScheme:(LGOrdinalNumberScheme *)ordinalNumberScheme
                              errors:(LGErrors *)errors
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:21];
    [set setString:[ordinalNumberScheme d83Data73OfOrdinalNumber:ordinalNumber] range:NSMakeRange(2, 9)]; // OZ
    [set setString:[type d83Data787980] range:NSMakeRange(11,3)]; // POSART1 + POSART2 + POSTYP
    [set setFloat:quantity range:NSMakeRange(23,11) comma:3]; // MENGE
    // EINHEIT:
    if ([set setCutString:unit range:NSMakeRange(34,4)]) [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                                                               code:LGServiceUnitTooLong
                                                                                           userInfo:@{LGServiceUnitTooLong_OrdinalNumberKey: ordinalNumber}]];
    return set;
}

- (LGSet *)d83Set25AndErrors:(LGErrors *)errors
               ordinalNumber:(LGOrdinalNumber *)ordinalNumber
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:25];
    // KURZTEXT:
    if ([set setCutString:title range:NSMakeRange(2, 70)]) [errors addError:[NSError errorWithDomain:LGErrorDomain
                                                                                                 code:LGServiceTitleTooLong
                                                                                             userInfo:@{LGServiceTitleTooLong_OrdinalNumberKey: ordinalNumber}]];
    return set;
}

- (LGSet *)d83Set26WithChunk:(NSString *)chunk
{
    LGSet *set = [[LGSet alloc] init];
    [set setType:26];
    [set setString:chunk range:NSMakeRange(5, 55)]; // LANGTEXT
    return set;
}

- (NSString *)title
{
    return title;
}

@end
