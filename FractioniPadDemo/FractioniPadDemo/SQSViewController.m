//
//  SQSViewController.m
//  FractioniPadDemo
//
//  Created by Conrad Shultz on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SQSViewController.h"

@interface SQSViewController ()

@end

@implementation SQSViewController
@synthesize addend = _addend;
@synthesize numerator = _numerator;
@synthesize denominator = _denominator;
@synthesize result = _result;
@synthesize style = _style;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)calculateResultIfPossible
{
    if ([[[self numerator] text] length] && [[[self denominator] text] length] && [[[self addend] text] length]) {
        NSInteger num = [[[self numerator] text] integerValue];
        NSInteger denom = [[[self denominator] text] integerValue];
        NSDecimalNumber *add = [NSDecimalNumber decimalNumberWithString:[[self addend] text]];
        SQSFraction *frac1 = [SQSFraction fractionWithDecimalNumber:add acceptableError:0.001];
        SQSFraction *frac2 = [SQSFraction fractionWithNumerator:num denominator:denom negative:NO];
        SQSFraction *additionResult = [frac1 fractionByAddingFraction:frac2];
        [[self result] setText:[additionResult stringValueWithStyle:[[self style] selectedRowInComponent:0]]];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == [self denominator]) {
        if ([[textField text] integerValue] == 0) {
            [textField setText:nil];
        }
    }
    if ([[textField text] doubleValue] < 0) {
        [textField setText:nil];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self calculateResultIfPossible];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView 
             titleForRow:(NSInteger)row 
            forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"Inline";
            break;
        
        case 1:
            return @"Parenthetical";
            break;
        case 2:
            return @"Mixed number";
            break;
        case 3:
            return @"LaTeX";
            break;
        default:
            return @"INVALID ROW";
            break;
    }
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView 
      didSelectRow:(NSInteger)row 
       inComponent:(NSInteger)component
{
    [self calculateResultIfPossible];
}

@end
