//
//  NSString+KNVUNDNumberPadInputHelper.m
//  Pods
//
//  Created by Erjian Ni on 14/10/17.
//

#import "NSString+KNVUNDNumberPadInputHelper.h"

@implementation NSString (KNVUNDNumberPadInputHelper)

#pragma mark - Numeric Related
- (NSDecimalNumber *)decimalValue
{
    return [[NSDecimalNumber decimalNumberWithString:self] isEqualToNumber:[NSDecimalNumber notANumber]] ? [NSDecimalNumber zero] : [NSDecimalNumber decimalNumberWithString:self];
}

- (NSString *)stringByAccumulatingStringValue:(NSString *)stringValue
{
    return [self.decimalValue decimalNumberByAdding:stringValue.decimalValue].stringValue;
}

@end
