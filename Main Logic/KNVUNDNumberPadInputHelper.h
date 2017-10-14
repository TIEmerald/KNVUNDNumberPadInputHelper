//
//  KNVUNDNumberPadInputHelper.h
//  Pods
//
//  Created by Erjian Ni on 14/10/17.
//

#import <UIKit/UIKit.h>

#import "KNVUNDNumberPadInputModel.h"

// This is the Number Pad Type we supported.
typedef enum : NSUInteger {
    KNVUNDNumberPadType_Default,// Default is Plain String.
    KNVUNDNumberPadType_Currency, // The format of Currency you input is based on the currency setting you set in backend
    KNVUNDNumberPadType_Unit // Integer only and displayed in Plain String.
} KNVUNDNumberPadType;

typedef void(^KNVUNDNumberPadInputHelperTextFieldUpdateBlock)(UITextField *_Nullable relatedinTextField, NSString *_Nullable rawDisplayingString, NSString *_Nullable formatedDisplayingString);

@interface KNVUNDNumberPadInputHelper : NSObject

@property (nonatomic) KNVUNDNumberPadType type;
@property (nonatomic) BOOL shouldResetValueForFirstInput; // If this value be set to Yes, we will reset stored value while user click any button with first time.
@property (nonatomic, strong, nullable) NSString *rawDisplayingString;

// Customize the raction and Integer Digits if you need.
@property (nonatomic, strong, nullable) NSNumber *customMaximumFractionDigits;
@property (nonatomic, strong, nullable) NSNumber *customMaximumIntegerDigits;
@property (nonatomic, strong, nullable) NSNumberFormatter *usingCurrencyFormat;

#pragma mark - Initial
- (instancetype _Nonnull)initWithNumberDisplayingTextField:(UITextField *_Nonnull)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type;
- (instancetype _Nonnull)initWithNumberDisplayingTextField:(UITextField *_Nonnull)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type andTextFieldTextUpdateBlock:(KNVUNDNumberPadInputHelperTextFieldUpdateBlock _Nullable)updatingBlock;

#pragma mark - Set Up
/*!
 * @brief If you want this helper handle the inputed value displaying logic automatically, you'd better assign a displaying text field to this helper.
 * @param displayingTextField We will have a weak pointer to the textfield you assigned.
 */
- (void)setUpWithNumberDisplayingTextField:(UITextField *_Nonnull)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type;

// If you have different logic to update text field -- like need update text color of textfield. you'd better assign a customised updating Block
- (void)setUpWithNumberDisplayingTextField:(UITextField *_Nonnull)displayingTextField andNumberPadTypd:(KNVUNDNumberPadType)type andTextFieldTextUpdateBlock:(KNVUNDNumberPadInputHelperTextFieldUpdateBlock _Nullable)updatingBlock;

#pragma mark - General Method
/*!
 * @brief If you want use this method, Please call this method in your IBAction method. And please set your Number Pad Input Button with the values in KNVUNDNumberPadInputModelType
 */
- (void)tapedNumberPadButton:(UIButton *_Nonnull)numberPadButton;

// This in this method, you could create your own Number Pad Input Model and let this Helper handle the displaying logic.
- (void)handleNumberPadInputWithModel:(KNVUNDNumberPadInputModel *_Nonnull)inputModel;

@end

