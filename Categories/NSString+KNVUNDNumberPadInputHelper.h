//
//  NSString+KNVUNDNumberPadInputHelper.h
//  Pods
//
//  Created by Erjian Ni on 14/10/17.
//

#import <Foundation/Foundation.h>

@interface NSString (KNVUNDNumberPadInputHelper)

#pragma mark - Numeric Related
@property (readonly) NSDecimalNumber *decimalValue;

// This method is used to make calculation between Strings more concise.
- (NSString *)stringByAccumulatingStringValue:(NSString *)stringValue;

@end
