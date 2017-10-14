//
//  KNVUNDNumberPadInputHelper.m
//  Pods
//
//  Created by Erjian Ni on 14/10/17.
//

#import "KNVUNDNumberPadInputHelper.h"

// Categories
#import "NSString+KNVUNDNumberPadInputHelper.h"

@interface KNVUNDNumberPadInputHelper(){
    KNVUNDNumberPadInputHelperTextFieldUpdateBlock _relatedTextUpdatingBlock;
    BOOL _hasHadFirstInput;
}

@property (nonatomic, weak) UITextField *displayingTextField;
@property (nonatomic, strong) NSString *rawInputedNumberString; // This is the String without format

// These two properties are used to validate the number Input.
@property (readonly) NSUInteger maximumFractionDigits;
@property (readonly) NSUInteger maximumIntegerDigits;

@end

@implementation KNVUNDNumberPadInputHelper

#pragma mark - Constants
NSString *const KNVUNDNumberPadInputHelper_Using_Decimal_Dot = @"."; // In our system, we will use @"." as decimal dot in calculation.

#pragma mark - Getter & Setter
#pragma mark - Getters
- (NSUInteger)maximumFractionDigits
{
    if (_customMaximumFractionDigits) {
        return _customMaximumFractionDigits.unsignedIntegerValue;
    }
    switch (self.type) {
        case KNVUNDNumberPadType_Currency:
            return self.usingCurrencyFormat.maximumFractionDigits;
        case KNVUNDNumberPadType_Unit:
            return 0;
        case KNVUNDNumberPadType_Default:
        default:
            return NSNotFound;
    }
}

- (NSUInteger)maximumIntegerDigits
{
    if (_customMaximumIntegerDigits) {
        return _customMaximumIntegerDigits.unsignedIntegerValue;
    }
    switch (self.type) {
        case KNVUNDNumberPadType_Currency:
            return self.usingCurrencyFormat.maximumIntegerDigits;
        case KNVUNDNumberPadType_Unit:
        case KNVUNDNumberPadType_Default:
        default:
            return NSNotFound;
    }
}

- (NSString *)rawDisplayingString
{
    return self.rawInputedNumberString;
}

- (NSString *)rawInputedNumberString
{
    return _rawInputedNumberString ?: @"";
}

- (NSNumberFormatter *)usingCurrencyFormat
{
    if (_usingCurrencyFormat) {
        NSLocale *currentLocale = [NSLocale systemLocale];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.locale = currentLocale;
        [formatter setGroupingSeparator:[currentLocale objectForKey:NSLocaleGroupingSeparator]];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setAlwaysShowsDecimalSeparator:NO];
        [formatter setUsesGroupingSeparator:YES];
        _usingCurrencyFormat = formatter;
    }
    return _usingCurrencyFormat;
}

#pragma mark - Setters
- (void)setRawDisplayingString:(NSString *)rawDisplayingString
{
    self.rawInputedNumberString = rawDisplayingString;
    [self setupTextInDisplayingTextField];
}

- (void)setType:(KNVUNDNumberPadType)type
{
    _type = type;
    self.rawDisplayingString = @"";
}

#pragma mark - Initial
- (instancetype)initWithNumberDisplayingTextField:(UITextField *)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type
{
    return [self initWithNumberDisplayingTextField:displayingTextField
                                  andNumberPadTypd:type
                       andTextFieldTextUpdateBlock:nil];
}

- (instancetype)initWithNumberDisplayingTextField:(UITextField *)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type andTextFieldTextUpdateBlock:(KNVUNDNumberPadInputHelperTextFieldUpdateBlock)updatingBlock
{
    if (self = [self init]) {
        [self setUpWithNumberDisplayingTextField:displayingTextField
                                andNumberPadTypd:type
                     andTextFieldTextUpdateBlock:updatingBlock];
    }
    return self;
}

#pragma mark - Set Up
- (void)setUpWithNumberDisplayingTextField:(UITextField *)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type
{
    [self setUpWithNumberDisplayingTextField:displayingTextField
                            andNumberPadTypd:type
                 andTextFieldTextUpdateBlock:nil];
}

- (void)setUpWithNumberDisplayingTextField:(UITextField *_Nonnull)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type andTextFieldTextUpdateBlock:(KNVUNDNumberPadInputHelperTextFieldUpdateBlock _Nullable)updatingBlock
{
    _displayingTextField = displayingTextField;
    _type = type;
    _relatedTextUpdatingBlock = updatingBlock;
    
    self.rawDisplayingString = @""; // inital Raw Displaying String.
}

#pragma mark - General Method
- (void)tapedNumberPadButton:(UIButton *)numberPadButton;
{
    KNVUNDNumberPadInputModel *convertedModel = [[KNVUNDNumberPadInputModel alloc]initWithInputType:numberPadButton.tag
                                                                             andInputingValueString:numberPadButton.titleLabel.text];
    [self handleNumberPadInputWithModel:convertedModel];
}

// This in this method, you could create your own Number Pad Input Model and let this Helper handle the displaying logic.
- (void)handleNumberPadInputWithModel:(KNVUNDNumberPadInputModel *_Nonnull)inputModel
{
    if (!_hasHadFirstInput && self.shouldResetValueForFirstInput) {
        self.rawDisplayingString = @"";
    }
    switch (inputModel.inputType) {
        case KNVUNDNumberPadInputModel_Type_Append:
            [self appendStringToRawInputedNumberString:inputModel.inputingValueString];
            break;
        case KNVUNDNumberPadInputModel_Type_Delete:
            if(self.rawInputedNumberString.length > 0)
                self.rawInputedNumberString = [NSMutableString stringWithString:[self.rawInputedNumberString substringToIndex:self.rawInputedNumberString.length - 1]];
            break;
        case KNVUNDNumberPadInputModel_Type_Accumulate_Integer:
            [self accumulateStringAmountToRawInputedNumberString:inputModel.inputingValueString];
            break;
        case KNVUNDNumberPadInputModel_Type_Decimal_Dot:
            if (self.rawDisplayingString.length == 0) {
                self.rawDisplayingString = @"0";
            }
            [self appendStringToRawInputedNumberString:KNVUNDNumberPadInputHelper_Using_Decimal_Dot];
            break;
    }
    [self setupTextInDisplayingTextField];
    _hasHadFirstInput = YES;
}

#pragma mark Support Methods
- (void)accumulateStringAmountToRawInputedNumberString:(NSString *)accumulateAmount
{
    NSString *integerPart = nil;
    NSString *otherPart = nil;
    NSUInteger decimalDotLocation = [self.rawInputedNumberString rangeOfString:KNVUNDNumberPadInputHelper_Using_Decimal_Dot].location;
    if (decimalDotLocation == NSNotFound) {
        integerPart = self.rawInputedNumberString;
    } else {
        integerPart = [self.rawInputedNumberString substringToIndex:decimalDotLocation];
        otherPart = [self.rawInputedNumberString substringFromIndex:decimalDotLocation];
    }
    
    // update integer Part
    self.rawInputedNumberString = [integerPart stringByAccumulatingStringValue:accumulateAmount];
    
    // Then is has other Part, we will append the other part to the end
    if (otherPart) {
        self.rawInputedNumberString = [self.rawInputedNumberString stringByAppendingString:otherPart];
    }
}

- (void)appendStringToRawInputedNumberString:(NSString *)appendingString
{
    if([self couldAppendStringToRawInputedNumberString:appendingString]){
        self.rawInputedNumberString = [self.rawInputedNumberString stringByAppendingString:appendingString];
    }
}

- (BOOL)couldAppendStringToRawInputedNumberString:(NSString *)appendingString
{
    // Might needed Propeties
    NSUInteger maximumFractionDigits = self.maximumFractionDigits;
    NSUInteger maximumIntegerDigits = self.maximumIntegerDigits;
    
    NSUInteger decimalDotLocation = [self.rawInputedNumberString rangeOfString:KNVUNDNumberPadInputHelper_Using_Decimal_Dot].location;
    BOOL hasDecimalDot= decimalDotLocation != NSNotFound;
    
    
    if(hasDecimalDot) {
        // Part One:  We only support One Decimal Dot
        if ([appendingString isEqualToString:KNVUNDNumberPadInputHelper_Using_Decimal_Dot]){
            return NO;
        }
        
        // Part Two:  We should make sure we won't input Digits bigger than Maximum Fraction Digits
        if (maximumFractionDigits != NSNotFound) {
            NSString *fractionPart = [self.rawInputedNumberString substringFromIndex:decimalDotLocation + 1];
            return fractionPart.length + appendingString.length <= maximumFractionDigits;
        }
    } else if ([appendingString isEqualToString:KNVUNDNumberPadInputHelper_Using_Decimal_Dot]) {
        return maximumFractionDigits == NSNotFound || maximumFractionDigits > 0;
    } else if (maximumIntegerDigits != NSNotFound) {
        return self.rawInputedNumberString.length + appendingString.length <= maximumIntegerDigits;
        
    }
    return YES;
}

#pragma mark - Support Method
- (void)setupTextInDisplayingTextField
{
    // Clean up Raw Inputed Number String For displaying
    /// Remove aheading "0" if it is not necessary
    while (self.rawDisplayingString.length > 1 && [self.rawDisplayingString characterAtIndex:0] == '0' && [self.rawDisplayingString characterAtIndex:1] != '.') {
        self.rawDisplayingString = [self.rawDisplayingString substringFromIndex:1];
    }
    
    // Formating the Displaying string.
    NSString *formatedDisplayingString = self.rawInputedNumberString;
    
    switch (self.type) {
        case KNVUNDNumberPadType_Currency:
            formatedDisplayingString = [self getFormatedStringForCurrencyType];
            break;
        case KNVUNDNumberPadType_Unit:
        case KNVUNDNumberPadType_Default:
        default:
            break;
    }
    
    if (_relatedTextUpdatingBlock) {
        [self performABlockInMainThread:^{
            _relatedTextUpdatingBlock(self.displayingTextField, self.rawDisplayingString, formatedDisplayingString);
        }];
    } else {
        [self performABlockInMainThread:^{
            self.displayingTextField.text = formatedDisplayingString;
        }];
    }
}

- (NSString *)getFormatedStringForCurrencyType
{
    // Might needed Propeties
    NSNumberFormatter *usingCurrencyNumberFormatter = self.usingCurrencyFormat;
    
    NSUInteger groupSize = usingCurrencyNumberFormatter.groupingSize;
    NSString *decimalSeperator = [usingCurrencyNumberFormatter.locale objectForKey:NSLocaleDecimalSeparator];
    NSString *groupingSeperator = [usingCurrencyNumberFormatter.locale objectForKey:NSLocaleGroupingSeparator];
    NSString *currencySymbol = [usingCurrencyNumberFormatter.locale objectForKey:NSLocaleCurrencySymbol];
    
    NSString *integerPart = nil;
    NSString *fractionPart = nil;
    NSUInteger decimalDotLocation = [self.rawInputedNumberString rangeOfString:KNVUNDNumberPadInputHelper_Using_Decimal_Dot].location;
    BOOL hasDecimalDot= decimalDotLocation != NSNotFound;
    if (!hasDecimalDot) {
        integerPart = self.rawInputedNumberString;
    } else {
        integerPart = [self.rawInputedNumberString substringToIndex:decimalDotLocation];
        fractionPart = [self.rawInputedNumberString substringFromIndex:decimalDotLocation + 1];
    }
    
    NSInteger numberOfGroup = groupSize != 0 ? integerPart.length / groupSize + 1 : 1;
    NSInteger digitsOfFirstGroup = groupSize != 0 ? integerPart.length % groupSize : integerPart.length;
    
    if (digitsOfFirstGroup == 0 && numberOfGroup > 1) {
        digitsOfFirstGroup = groupSize;
        numberOfGroup -= 1;
    }
    
    NSString *formatedIntegerPart = [integerPart substringToIndex:digitsOfFirstGroup];
    for (int index = 0; index < numberOfGroup - 1; index += 1) {
        formatedIntegerPart = [formatedIntegerPart stringByAppendingString:groupingSeperator];
        formatedIntegerPart = [formatedIntegerPart stringByAppendingString:[integerPart substringWithRange:NSMakeRange(digitsOfFirstGroup + index * groupSize, groupSize)]];
    }
    
    NSString *returnString = [NSString stringWithFormat:@"%@ %@",
                              currencySymbol,
                              formatedIntegerPart];
    
    if (hasDecimalDot) {
        returnString = [returnString stringByAppendingString:decimalSeperator];
    }
    
    if (fractionPart != nil) {
        returnString = [returnString stringByAppendingString:fractionPart];
    }
    
    return returnString;
}

- (void)performABlockInMainThread:(void(^_Nonnull)())performingBlock
{
    if (performingBlock == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        performingBlock();
        return; // If current Tread is main tread, there is no need to do something like dispatch_sync()
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        performingBlock();
    });
}

@end
