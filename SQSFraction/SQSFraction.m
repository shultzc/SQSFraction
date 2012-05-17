//
//  SQSFraction.m
//  SQSFraction
//
//  Created by Conrad Shultz on 2/15/12.
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

#import "SQSFraction.h"
#import "NSDecimalNumber+SQSFraction.h"

static NSString * const kCodingKeyNumerator = @"SQSNumerator";
static NSString * const kCodingKeyDenominator = @"SQSDenominator";
static NSString * const kCodingKeyIsNegative = @"SQSIsNegative";

@interface SQSFraction ()

+ (SQSFraction *)_fractionByCollapsingPartialContinuedFraction:(NSArray *)partialContinuedFraction;
+ (SQSFraction *)_fractionForDecimalNumber:(NSDecimalNumber *)decimal 
                           acceptableError:(double)error;
- (NSUInteger)_leastCommonMultipleOfTerm1:(NSUInteger)t1 andTerm2:(NSUInteger)t2;
- (NSUInteger)_greatestCommonFactorOfTerm1:(NSUInteger)t1 andTerm2:(NSUInteger)t2;

@end

@interface SQSFraction (PublicCandidates)
// The following two methods should be made public once negative continued fractions can be handled natively
- (id)_initWithContinuedFraction:(NSArray *)continuedFraction
                        negative:(BOOL)negative;
+ (id)_fractionWithContinuedFraction:(NSArray *)continuedFraction 
                            negative:(BOOL)negative;
@end

@implementation SQSFraction

@synthesize numerator = _numerator;
@synthesize denominator = _denominator;
@synthesize isNegative = _isNegative;

#pragma mark -
#pragma mark Initialization, deallocation

- (id)initWithNumerator:(NSUInteger)numerator 
            denominator:(NSUInteger)denominator 
               negative:(BOOL)negative
{
    self = [super init];
    if (self) {
        NSUInteger gcf = [self _greatestCommonFactorOfTerm1:numerator 
                                                   andTerm2:denominator];
        _numerator = numerator / gcf;
        _denominator = denominator / gcf;
        _isNegative = negative;
    }
    return self;
}

+ (id)fractionWithNumerator:(NSUInteger)numerator 
                denominator:(NSUInteger)denominator 
                   negative:(BOOL)negative

{
    return [[[[self class] alloc] initWithNumerator:numerator
                                        denominator:denominator
                                           negative:negative] autorelease];
}

- (id)initWithDecimalNumber:(NSDecimalNumber *)decimalNumber
            acceptableError:(double)error
{
    return [[[self class] _fractionForDecimalNumber:decimalNumber
                                    acceptableError:error] retain];
}

+ (id)fractionWithDecimalNumber:(NSDecimalNumber *)decimalNumber
                acceptableError:(double)error
{
    return [[[[self class] alloc] initWithDecimalNumber:decimalNumber 
                                        acceptableError:error] autorelease];
}

#pragma mark -
#pragma mark Arithmetic

- (id)fractionByAddingFraction:(SQSFraction *)addend
{
    NSUInteger denom1 = [self denominator];
    NSUInteger denom2 = [addend denominator];
    NSUInteger lcm = [self _leastCommonMultipleOfTerm1:denom1 andTerm2:denom2];
    NSInteger numer1 = [self numerator] * lcm / denom1;
    NSInteger numer2 = [addend numerator] * lcm / denom2;
    if ([self isNegative]) {
        numer1 *= -1;
    }
    if ([addend isNegative]) {
        numer2 *= -1;
    }
    NSInteger numerSum = numer1 + numer2;
    BOOL resultIsNegative = (numerSum < 0);
    if (resultIsNegative) {
        numerSum *= -1;
        resultIsNegative = YES;
    }
    return [[self class] fractionWithNumerator:numerSum
                                   denominator:lcm
                                      negative:resultIsNegative];
    
}

- (id)fractionBySubtractingFraction:(SQSFraction *)subtrahend
{
    NSUInteger numer = [subtrahend numerator];
    NSUInteger denom = [subtrahend denominator];
    BOOL isNegative = ! [subtrahend isNegative];
    SQSFraction *negativeFraction = [[self class] fractionWithNumerator:numer
                                                           denominator:denom
                                                              negative:isNegative];
    return [self fractionByAddingFraction:negativeFraction];
}

- (id)fractionByMultiplyingByFraction:(SQSFraction *)factor
{
    NSUInteger numer1 = [self numerator];
    NSUInteger numer2 = [factor numerator];
    NSUInteger denom1 = [self denominator];
    NSUInteger denom2 = [factor denominator];
    BOOL isNegative = [self isNegative] ^ [factor isNegative];
    return [[self class] fractionWithNumerator:numer1 * numer2
                                   denominator:denom1 * denom2
                                      negative:isNegative];
}

- (id)fractionByMultiplyingByInteger:(NSInteger)factor
{
    BOOL isNegative = NO;
    if (factor < 0) {
        factor *= -1;
        isNegative = YES;
    }
    SQSFraction *fracFactor = [[self class] fractionWithNumerator:factor
                                                      denominator:1
                                                         negative:isNegative];
    return [self fractionByMultiplyingByFraction:fracFactor];
}

- (id)fractionByDividingByFraction:(SQSFraction *)divisor
{
    NSUInteger numer = [divisor numerator];
    NSAssert(numer != 0, @"Attempt to divide by zero");
    NSUInteger denom = [divisor denominator];
    BOOL isNegative = [divisor isNegative];
    SQSFraction *inverseFraction = [[self class] fractionWithNumerator:denom
                                                           denominator:numer
                                                              negative:isNegative];
    return [self fractionByMultiplyingByFraction:inverseFraction];
}

- (id)fractionByDividingByInteger:(NSInteger)divisor
{
    NSAssert(divisor != 0, @"Attempt to divide by zero");
    BOOL isNegative = NO;
    if (divisor < 0) {
        divisor *= -1;
        isNegative = YES;
    }
    SQSFraction *fracDivisor = [[self class] fractionWithNumerator:divisor
                                                       denominator:1
                                                          negative:isNegative];
    return [self fractionByDividingByFraction:fracDivisor];
}

#pragma mark -
#pragma mark Equality

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (! [object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isNegative] == [object isNegative] 
    && [self numerator] == [object numerator] 
    && [self denominator] == [object denominator];
}

- (NSUInteger)hash
{
    NSUInteger hash = [self numerator] & [self denominator];
    if ([self isNegative]) {
        hash = ~hash;
    }
    return hash;
}

#pragma mark -
#pragma mark Accessors

- (NSString *)stringValueWithStyle:(SQSFractionStringStyle)style
{
    NSString *stringValue = nil;
    switch (style) {
            
        case SQSFractionStringStyleInline:
            stringValue = [NSString stringWithFormat:@"%u/%u", [self numerator], [self denominator]];
            if ([self isNegative]) {
                stringValue = [@"-" stringByAppendingString:stringValue];
            }
            break;
            
        case SQSFractionStringStyleLaTeX:
            stringValue = [NSString stringWithFormat:@"{%u \\over %u}", [self numerator], [self denominator]];
            if ([self isNegative]) {
                stringValue = [@"- " stringByAppendingString:stringValue];
            }
            break;
            
        case SQSFractionStringStyleMixedNumber:
        {
            NSUInteger numer = [self numerator];
            NSUInteger denom = [self denominator];
            if (numer < denom) {
                // Just a normal fraction (no whole part)
                return [self stringValueWithStyle:SQSFractionStringStyleInline];
            }
            else {
                NSInteger wholePart = (NSInteger)floor(numer / denom);
                if ([self isNegative]) {
                    wholePart *= -1;
                }
                NSUInteger remainder = numer % denom;
                if (remainder == 0) {
                    // Fraction is actually a whole number
                    return [NSString stringWithFormat:@"%d", wholePart];
                }
                else {
                    // True mixed fraction
                    SQSFraction *remainderFrac = [[self class] fractionWithNumerator:remainder
                                                                         denominator:denom
                                                                            negative:NO];
                    return [NSString stringWithFormat:@"%d %@", wholePart, [remainderFrac stringValueWithStyle:SQSFractionStringStyleInline]];
                }
            }
        }
            break;
            
        case SQSFractionStringStyleParenthetical:
        default:
        {
            NSInteger numerator = (NSInteger)[self numerator];
            
            if ([self isNegative]) {
                numerator *= -1;
            }
            stringValue = [NSString stringWithFormat:@"(%d / %u)", numerator, [self denominator]];
        }
            break;
            
    }
    return stringValue;
}

- (NSDecimalNumber *)decimalValue
{
    if ([self numerator] == 0) {
        return [NSDecimalNumber zero];
    }
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithMantissa:[self numerator]
                                                             exponent:0
                                                           isNegative:[self isNegative]];
    NSDecimalNumber *denom = [NSDecimalNumber decimalNumberWithMantissa:[self denominator]
                                                               exponent:0
                                                             isNegative:NO];
    return [num decimalNumberByDividingBy:denom];
}

- (double)doubleValue
{
    return [[self decimalValue] doubleValue];
}

- (float)floatValue
{
    return (float)[self doubleValue];
}

- (int)intValue
{
    return (int)[self integerValue];
}

- (NSInteger)integerValue
{
    return [[self decimalValue] integerValue];
}

#pragma mark -
#pragma mark Misc superclass methods

- (NSString *)description
{
    return [self stringValueWithStyle:SQSFractionStringStyleParenthetical];
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // Object is immutable, so just retain
    return [self retain];
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSUInteger numerator;
    NSUInteger denominator;
    BOOL isNegative;
    if ([aDecoder allowsKeyedCoding]) {
        numerator = [[aDecoder decodeObjectForKey:kCodingKeyNumerator] unsignedIntegerValue];
        denominator = [[aDecoder decodeObjectForKey:kCodingKeyDenominator] unsignedIntegerValue];
        isNegative = [aDecoder decodeBoolForKey:kCodingKeyIsNegative];
    }
    else {
        numerator = [[aDecoder decodeObject] unsignedIntegerValue];
        denominator = [[aDecoder decodeObject] unsignedIntegerValue];
        isNegative = [[aDecoder decodeObject] unsignedIntegerValue];
    }
    return [self initWithNumerator:numerator
                       denominator:denominator
                          negative:isNegative];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self numerator]] forKey:kCodingKeyNumerator];
        [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self denominator]] forKey:kCodingKeyDenominator];
        [aCoder encodeBool:[self isNegative] forKey:kCodingKeyIsNegative];
    }
    else {
        [aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self numerator]]];
        [aCoder encodeObject:[NSNumber numberWithUnsignedInt:[self denominator]]];
        [aCoder encodeObject:[NSNumber numberWithBool:[self isNegative]]];
    }
}


#pragma mark -
#pragma mark Private methods

+ (SQSFraction *)_fractionByCollapsingPartialContinuedFraction:(NSArray *)partialContinuedFraction
{
    NSUInteger firstTerm = [[partialContinuedFraction objectAtIndex:0] unsignedIntegerValue];
    if ([partialContinuedFraction count] == 1) {
        return [[self class] fractionWithNumerator:1 denominator:firstTerm negative:NO];
    }
    else {
        SQSFraction *divisorAddend = [[self class] fractionWithNumerator:firstTerm
                                                             denominator:1
                                                                negative:NO];
        NSArray *newPartialFraction = [partialContinuedFraction objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [partialContinuedFraction count] - 1)]];
        SQSFraction *divisorSum = [divisorAddend fractionByAddingFraction:[SQSFraction _fractionByCollapsingPartialContinuedFraction:newPartialFraction]];
        return [self fractionWithNumerator:[divisorSum denominator]
                               denominator:[divisorSum numerator] 
                                  negative:NO];
    }
}

+ (SQSFraction *)_fractionForDecimalNumber:(NSDecimalNumber *)decimal
                           acceptableError:(double)error
{
    BOOL isNegative = ([decimal compare:[NSDecimalNumber zero]] == NSOrderedAscending);
    if (isNegative) {
        decimal = [decimal decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    }
    NSArray *contFrac = [decimal continuedFractionValueWithAcceptableError:error];
    return [self _fractionWithContinuedFraction:contFrac negative:isNegative];
}

- (NSUInteger)_leastCommonMultipleOfTerm1:(NSUInteger)t1
                                 andTerm2:(NSUInteger)t2
{
    return t1 * t2 / [self _greatestCommonFactorOfTerm1:t1 
                                               andTerm2:t2];
}

- (NSUInteger)_greatestCommonFactorOfTerm1:(NSUInteger)t1 
                                  andTerm2:(NSUInteger)t2
{
    // Implement Euclid's algorithm
    if (t2 > t1) {
        NSUInteger oldT2 = t2;
        t2 = t1;
        t1 = oldT2;
    }
    if (t2 == 0) {
        return t1;
    }
    else {
        NSUInteger newTerm = (t1 % t2);
        return [self _greatestCommonFactorOfTerm1:t2 andTerm2:newTerm];
    }
    
}

@end

#pragma mark -

@implementation SQSFraction (PublicCandidates)

- (id)_initWithContinuedFraction:(NSArray *)continuedFraction
                        negative:(BOOL)negative
{
    NSNumber *firstTerm = [continuedFraction objectAtIndex:0];
    NSInteger firstInt = [firstTerm integerValue];
    if ([continuedFraction count] == 0) {
        return [self initWithNumerator:(NSUInteger)firstInt denominator:1 negative:negative];
    }
    else {
        NSArray *partialContinuedFraction = [continuedFraction objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [continuedFraction count] - 1)]];
        SQSFraction *firstFrac = [[self class] fractionWithNumerator:(NSUInteger)firstInt
                                                         denominator:1
                                                            negative:NO];
        SQSFraction *totalFrac = firstFrac;
        if ([partialContinuedFraction count]) {
            SQSFraction *remainderFrac = [SQSFraction _fractionByCollapsingPartialContinuedFraction:partialContinuedFraction];
            totalFrac = [firstFrac fractionByAddingFraction:remainderFrac];
        }
        if (negative) {
            totalFrac = [totalFrac fractionByMultiplyingByInteger:-1];
        }
        return [totalFrac retain];
    }
}

+ (id)_fractionWithContinuedFraction:(NSArray *)continuedFraction
                            negative:(BOOL)negative
{
    return [[[[self class] alloc] _initWithContinuedFraction:continuedFraction negative:negative] autorelease];
}

@end
