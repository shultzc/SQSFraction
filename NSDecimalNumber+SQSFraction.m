//
//  NSDecimalNumber+SQSFraction.m
//  SQSConContinuedFraction
//
//  Created by Conrad Shultz on 2/25/12.
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

#import "NSDecimalNumber+SQSFraction.h"

@implementation NSDecimalNumber (SQSFraction)

- (NSUInteger)positiveFloor
{
    return floor([self doubleValue]);
}

+ (NSDecimalNumber *)_recursiveDecimalRepresentationOfPartialContinuedFraction:(NSArray *)quotientsWithoutIntegerPart
{
    NSDecimalNumber *one = [NSDecimalNumber one];
    NSDecimalNumber *firstTerm = [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)[quotientsWithoutIntegerPart objectAtIndex:0] decimalValue]];
    NSDecimalNumber *divisor;
    if ([quotientsWithoutIntegerPart count] == 1) {
        divisor = firstTerm;
    }
    else {
        NSArray *newQuotients = [quotientsWithoutIntegerPart objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [quotientsWithoutIntegerPart count] - 1)]];
        divisor = [firstTerm decimalNumberByAdding:[self _recursiveDecimalRepresentationOfPartialContinuedFraction:newQuotients]];
    }
    return [one decimalNumberByDividingBy:divisor];
}

+ (NSDecimalNumber *)decimalNumberWithContinuedFraction:(NSArray *)quotients
{
    NSDecimalNumber *firstTerm = [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)[quotients objectAtIndex:0] decimalValue]];
    if ([quotients count] == 1) {
        return firstTerm;
    }
    else {
        NSArray *newQuotients = [quotients objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [quotients count] - 1)]];
        NSDecimalNumber *fractionalPortion = [self _recursiveDecimalRepresentationOfPartialContinuedFraction:newQuotients];
        return [firstTerm decimalNumberByAdding:fractionalPortion];
    }
}

- (NSArray *)_continuedFractionByExtendingPreviousContinuedFraction:(NSArray *)previousFractionOrNil
                                                        withResidue:(NSDecimalNumber *)residueOrNil
                                                    acceptableError:(double)error
{
    if (residueOrNil == nil) {
        residueOrNil = self;
    }
    NSNumber *integerPortion = [NSNumber numberWithUnsignedInteger:[residueOrNil positiveFloor]];
    NSDecimalNumber *decIntegerPortion = [NSDecimalNumber decimalNumberWithDecimal:[integerPortion decimalValue]];
    NSArray *newFraction;
    if (previousFractionOrNil == nil) {
        newFraction = [NSArray arrayWithObject:integerPortion];
    }
    else {
        newFraction = [previousFractionOrNil arrayByAddingObject:integerPortion];
    }
    NSDecimalNumber *difference = [residueOrNil decimalNumberBySubtracting:decIntegerPortion];
    if (difference == [NSDecimalNumber zero]) {
        return newFraction;
    }
    else {
        NSDecimalNumber *decimalRep = [NSDecimalNumber decimalNumberWithContinuedFraction:newFraction];
        if (fabs([[self decimalNumberBySubtracting:decimalRep] doubleValue]) < error) {
            return newFraction;
        }
        else {
            NSDecimalNumber *newResidual = [[NSDecimalNumber one] decimalNumberByDividingBy:difference];
            return [self _continuedFractionByExtendingPreviousContinuedFraction:newFraction
                                                                    withResidue:newResidual
                                                                acceptableError:error];
        }
    }
}

- (NSArray *)continuedFractionValueWithAcceptableError:(double)error
{
    NSAssert1(error > 0, @"Error must be greater than zero, got %@", error);
    NSAssert1([self compare:[NSDecimalNumber zero]] != NSOrderedAscending, @"Decimal number must not be negative, got %@", self);
    return [self _continuedFractionByExtendingPreviousContinuedFraction:nil
                                                            withResidue:nil
                                                        acceptableError:error];
}

@end
