//
//  KNVUNDNumberPadInputModel.h
//  Pods
//
//  Created by Erjian Ni on 14/10/17.
//

#import <Foundation/Foundation.h>

// This is the Number Pad Button Type we supported.
typedef enum : NSUInteger {
    KNVUNDNumberPadInputModel_Type_Append = 6001, // This type of input we will append your input to displayed String
    KNVUNDNumberPadInputModel_Type_Delete = 6002, // This type of input, we will remove the last digit of displayed String
    KNVUNDNumberPadInputModel_Type_Accumulate_Integer = 6003, // This type of input we will accumulate the amount of your input to current displayed string
    KNVUNDNumberPadInputModel_Type_Decimal_Dot = 6004 // In some case they might use different separator as decimal dot other than "."
} KNVUNDNumberPadInputModelType;

@interface KNVUNDNumberPadInputModel : NSObject

@property (nonatomic) KNVUNDNumberPadInputModelType inputType;
@property (nonatomic, strong) NSString *inputingValueString;

#pragma mark - Initialization
- (instancetype)initWithInputType:(KNVUNDNumberPadInputModelType)inputType andInputingValueString:(NSString *)inputValueString;

@end
