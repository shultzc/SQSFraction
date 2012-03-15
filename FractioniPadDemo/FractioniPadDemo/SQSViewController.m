//
//  SQSViewController.m
//  FractioniPadDemo
//
//  Created by Conrad Shultz on 3/15/12.
//  Copyright (c) 2012 Synthetiq Solutions LLC. All rights reserved.
//
/*
 Copyright (c) 2012, Synthetiq Solutions LLC.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Synthetiq Solutions LLC nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SYNTHETIQ SOLUTIONS LLC BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
