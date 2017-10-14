//
//  KNVUNDNumberPadInputModel.m
//  Pods
//
//  Created by Erjian Ni on 14/10/17.
//

#import "KNVUNDNumberPadInputModel.h"

@implementation KNVUNDNumberPadInputModel

#pragma mark - Initialization
- (instancetype)initWithInputType:(KNVUNDNumberPadInputModelType)inputType andInputingValueString:(NSString *)inputValueString
{
    if (self = [super init]) {
        self.inputType = inputType;
        self.inputingValueString = inputValueString;
    }
    return self;
}

@end
