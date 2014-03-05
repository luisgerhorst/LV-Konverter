//
//  LGProblems.h
//  LV Konverter
//
//  Created by Luis Gerhorst on 17.02.14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSInteger const LGUnrecognizeableLineSummarized;
extern NSInteger const LGUnrecognizeableLineWithOrdinalNumberSummarized;
extern NSInteger const LGDeadFieldsWithTextInServiceTextChunkLineSummarized;
extern NSInteger const LGServiceGroupTitleTooLongSummarized;
extern NSInteger const LGServiceUnitTooLongSummarized;
extern NSInteger const LGServiceTitleTooLongSummarized;
extern NSInteger const LGInvalidServiceTypeSummarized;

extern NSString * const LGErrorPriorityKey;
extern NSString * const LGErrorPriorityFatal;
extern NSString * const LGErrorPriorityWarning;


@interface LGErrors : NSObject

- (void)addError:(NSError *)error;
- (void)addErrors:(LGErrors *)errors;

- (BOOL)errorsExist;
- (NSArray *)summarizedErrors;

@end
