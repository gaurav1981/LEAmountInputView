//
//  LEAmountInputView.m
//  LEAmountInputView
//
//  Created by Lasha Efremidze on 4/29/15.
//  Copyright (c) 2015 Lasha Efremidze. All rights reserved.
//

#import "LEAmountInputView.h"
#import "LENumberPad.h"

@interface LEAmountInputView () <LENumberPadDataSource, LENumberPadDelegate>

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation LEAmountInputView

- (instancetype)initWithFrame:(CGRect)frame numberStyle:(NSNumberFormatterStyle)numberStyle;
{
    self = [self initWithFrame:frame];
    if (self) {
        self.numberStyle = numberStyle;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize;
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.numberPad.layer.borderColor = [UIColor colorWithWhite:0.9f alpha:1.0f].CGColor;
    self.numberPad.layer.borderWidth = 1.0f;
    
    [self addSubview:self.textField];
    [self addSubview:self.numberPad];
    
    NSDictionary *views = @{@"textField": self.textField, @"numberPad": self.numberPad};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[textField]-20-|" options:0 metrics:0 views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[numberPad]|" options:0 metrics:0 views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField][numberPad]|" options:0 metrics:0 views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.numberPad attribute:NSLayoutAttributeHeight multiplier:1.0f / self.numberPad.numberOfRows constant:0]];
}

#pragma mark - Override Properties

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
        _textField.font = [UIFont systemFontOfSize:40.0f];
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.placeholder = [self currencyString:nil];
        _textField.enabled = NO;
    }
    return _textField;
}

- (LENumberPad *)numberPad
{
    if (!_numberPad) {
        _numberPad = [[LENumberPad alloc] initWithFrame:CGRectZero];
        _numberPad.translatesAutoresizingMaskIntoConstraints = NO;
        _numberPad.dataSource = self;
        _numberPad.delegate = self;
    }
    return _numberPad;
}

- (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter) {
        _numberFormatter = [NSNumberFormatter new];
    }
    return _numberFormatter;
}

- (void)setAmount:(NSNumber *)amount
{
    if (amount.doubleValue) {
        self.textField.text = [self.numberFormatter stringFromNumber:amount];
    } else {
        self.textField.text = nil;
    }
}

- (NSNumber *)amount;
{
    return [self amountFromString:self.textField.text];
}

- (void)setNumberStyle:(NSNumberFormatterStyle)numberStyle
{
    self.numberFormatter.numberStyle = numberStyle;
    
    self.textField.placeholder = [self currencyString:nil];
}

- (NSNumberFormatterStyle)numberStyle
{
    return self.numberFormatter.numberStyle;
}

#pragma mark - LENumberPadDataSource

- (NSInteger)numberOfColumnsInNumberPad:(LENumberPad *)numberPad;
{
    return 3;
}

- (NSInteger)numberOfRowsInNumberPad:(LENumberPad *)numberPad;
{
    return 4;
}

- (NSString *)numberPad:(LENumberPad *)numberPad buttonTitleForButtonAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.item == 9) {
        return @"C";
    } else if (indexPath.item == 10) {
        return @"0";
    } else if (indexPath.item == 11) {
        return @"00";
    }
    return [NSString stringWithFormat:@"%d", (int)indexPath.item + 1];
}

- (UIColor *)numberPad:(LENumberPad *)numberPad buttonTitleColorForButtonAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.item == 9) {
        return [UIColor orangeColor];
    }
    return [UIColor colorWithWhite:0.3f alpha:1.0f];
}

- (UIFont *)numberPad:(LENumberPad *)numberPad buttonTitleFontForButtonAtIndexPath:(NSIndexPath *)indexPath;
{
    return [UIFont systemFontOfSize:40.0f];
}

- (UIColor *)numberPad:(LENumberPad *)numberPad buttonBackgroundColorForButtonAtIndexPath:(NSIndexPath *)indexPath;
{
    return [UIColor whiteColor];
}

- (UIColor *)numberPad:(LENumberPad *)numberPad buttonBackgroundHighlightedColorForButtonAtIndexPath:(NSIndexPath *)indexPath;
{
    return [UIColor colorWithWhite:0.9f alpha:1.0f];
}

#pragma mark - LENumberPadDelegate

- (void)numberPad:(LENumberPad *)numberPad didSelectButtonAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *amount = @0;
    
    if (indexPath.item != 9) {
        UIButton *button = [numberPad buttonAtIndexPath:indexPath];
        NSString *string = [self.textField.text stringByAppendingString:button.titleLabel.text];
        amount = [self amountFromString:string];
    }
    
    if ([amount isEqualToNumber:self.amount] || ![self shouldChangeAmount:amount]) {
        return;
    }
    
    self.amount = amount;
    
    [self didChangeAmount:amount];
}

#pragma mark - Private

- (BOOL)shouldChangeAmount:(NSNumber *)amount
{
    if ([self.delegate respondsToSelector:@selector(amountInputView:shouldChangeAmount:)]) {
        return [self.delegate amountInputView:self shouldChangeAmount:amount];
    }
    return YES;
}

- (void)didChangeAmount:(NSNumber *)amount
{
    if ([self.delegate respondsToSelector:@selector(amountInputView:didChangeAmount:)]) {
        [self.delegate amountInputView:self didChangeAmount:amount];
    }
}

- (NSString *)currencyString:(NSString *)string;
{
    NSNumber *amount = [self amountFromString:string];
    return [self.numberFormatter stringFromNumber:amount];
}

- (NSNumber *)amountFromString:(NSString *)string;
{
    string = [self sanitizedString:string];
    if (string.doubleValue == 0) {
        return @0;
    }
    NSDecimalNumber *digits = [NSDecimalNumber decimalNumberWithString:string];
    NSDecimalNumber *decimalPlace = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:pow(10.0, self.numberFormatter.minimumFractionDigits)];
    return [digits decimalNumberByDividingBy:decimalPlace];
}

- (NSString *)sanitizedString:(NSString *)string;
{
    return [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:[NSString string]];
}

@end
