//
//  NSArray+LGCSVParser.h
//  csvToD83
//
//  Created by Luis Gerhorst on 28/01/14.
//  Copyright (c) 2014 Luis Gerhorst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (LGCSVParser)

+ (instancetype)arrayWithCSVString:(NSString *)csvString;
+ (instancetype)arrayWithCSVString:(NSString *)csvString delimiter:(unichar)delimiter;

@end
