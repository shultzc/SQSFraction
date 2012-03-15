//
//  SQSFractionTests.m
//  SQSFractionTests
//
//  Created by Conrad Shultz on 2/29/12.
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

#import "SQSFractionTests.h"
#import "SQSFraction.h"
#import "NSDecimalNumber+SQSFraction.h"

@implementation SQSFractionTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testFractionEquality
{
    SQSFraction *frac1 = [SQSFraction fractionWithNumerator:1 denominator:4 negative:NO];
    SQSFraction *frac2 = [SQSFraction fractionWithNumerator:2 denominator:8 negative:NO];
    SQSFraction *frac3 = [SQSFraction fractionWithNumerator:1 denominator:4 negative:YES];
    SQSFraction *frac4 = [SQSFraction fractionWithNumerator:2 denominator:8 negative:YES];
    
    STAssertEqualObjects(frac1, frac2, @"Equality test false negative");
    STAssertEqualObjects(frac3, frac4, @"Equality test false negative");
    STAssertFalse([frac1 isEqual:frac3], @"Equality test false positive");
    STAssertFalse([frac2 isEqual:frac4], @"Equality test false positive");
    STAssertEquals([frac1 hash], [frac2 hash], @"Hash test false negative");
    STAssertEquals([frac3 hash], [frac4 hash], @"Hash test false negative");
    STAssertFalse([frac1 hash] == [frac3 hash], @"Hash test false positive");
    STAssertFalse([frac2 hash] == [frac4 hash], @"Hash test false positive");

    
}

- (void)testFractionAddition
{
    SQSFraction *frac1 = [SQSFraction fractionWithNumerator:1 denominator:5 negative:NO];
    SQSFraction *frac2 = [SQSFraction fractionWithNumerator:3 denominator:8 negative:NO];
    // 8/40 + 15/40 = 23/40
    SQSFraction *expectedResult12 = [SQSFraction fractionWithNumerator:23 denominator:40 negative:NO];
    SQSFraction *frac1PlusFrac2 = [frac1 fractionByAddingFraction:frac2];
    STAssertTrue([frac1PlusFrac2 isEqual:expectedResult12], @"Positive addition mismatch");
    
    SQSFraction *frac3 = [SQSFraction fractionWithNumerator:1 denominator:4 negative:NO];
    SQSFraction *frac4 = [SQSFraction fractionWithNumerator:4 denominator:3 negative:YES];
    // 3/12 - 16/12 = - 13/12
    SQSFraction *expectedResult34 = [SQSFraction fractionWithNumerator:13 denominator:12 negative:YES];
    SQSFraction *frac3PlusFrac4 = [frac3 fractionByAddingFraction:frac4];
    STAssertTrue([frac3PlusFrac4 isEqual:expectedResult34], @"Negative addition mismatch");
}

- (void)testFractionSubtraction
{
    SQSFraction *frac1 = [SQSFraction fractionWithNumerator:1 denominator:2 negative:NO];
    SQSFraction *frac2 = [SQSFraction fractionWithNumerator:3 denominator:8 negative:NO];
    // 1/2 - 3/8 = 1/8
    SQSFraction *expectedResult = [SQSFraction fractionWithNumerator:1 denominator:8 negative:NO];
    SQSFraction *actualResult = [frac1 fractionBySubtractingFraction:frac2];
    STAssertEqualObjects(expectedResult, actualResult, @"Subtraction of fraction failed");
}

- (void)testFractionMultiplication
{
    SQSFraction *frac1 = [SQSFraction fractionWithNumerator:1 denominator:2 negative:NO];
    SQSFraction *frac2 = [SQSFraction fractionWithNumerator:3 denominator:8 negative:NO];
    NSInteger negativeIntegerFactor = -4;
    SQSFraction *expectedResult1 = [SQSFraction fractionWithNumerator:3 denominator:16 negative:NO];
    SQSFraction *expectedResult2 = [SQSFraction fractionWithNumerator:2 denominator:1 negative:YES];
    SQSFraction *actualResult1 = [frac1 fractionByMultiplyingByFraction:frac2];
    SQSFraction *actualResult2 = [frac1 fractionByMultiplyingByInteger:negativeIntegerFactor];
    STAssertEqualObjects(expectedResult1, actualResult1, @"Multiplication by fraction failed");
    STAssertEqualObjects(expectedResult2, actualResult2, @"Mulitplication by neg integer failed");
}

- (void)testFractionDivision
{
    SQSFraction *frac1 = [SQSFraction fractionWithNumerator:1 denominator:2 negative:NO];
    SQSFraction *frac2 = [SQSFraction fractionWithNumerator:3 denominator:8 negative:NO];
    NSInteger negativeIntegerDivisor = -4;
    // 1/2 / 3/8 = 1/2 * 8/3 = 8/6 = 4/3
    SQSFraction *expectedResult1 = [SQSFraction fractionWithNumerator:4 denominator:3 negative:NO];
    SQSFraction *expectedResult2 = [SQSFraction fractionWithNumerator:1 denominator:8 negative:YES];
    SQSFraction *actualResult1 = [frac1 fractionByDividingByFraction:frac2];
    SQSFraction *actualResult2 = [frac1 fractionByDividingByInteger:negativeIntegerDivisor];
    STAssertEqualObjects(expectedResult1, actualResult1, @"Division by fraction failed");
    STAssertEqualObjects(expectedResult2, actualResult2, @"Division by neg integer failed");
    
}

- (void)testDecimalToContinuedFraction
{
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:@"3.245"];
    NSArray *contFrac = [num continuedFractionValueWithAcceptableError:(double)0.00001];
    NSArray *expectedResult = [NSArray arrayWithObjects:
                               [NSNumber numberWithUnsignedInteger:3],
                               [NSNumber numberWithUnsignedInteger:4],
                               [NSNumber numberWithUnsignedInteger:12],
                               [NSNumber numberWithUnsignedInteger:4],
                               nil];
    STAssertEqualObjects(contFrac, expectedResult, @"Bad decimal to continued fraction conversion");
}

- (void)testContinuedFractionToDecimal
{
    NSArray *contFrac = [NSArray arrayWithObjects:
                         [NSNumber numberWithInteger:0],
                         [NSNumber numberWithInteger:1],
                         [NSNumber numberWithInteger:2],
                         [NSNumber numberWithInteger:3],
                         [NSNumber numberWithInteger:4],
                         nil];
    double expectedResult = [[NSDecimalNumber decimalNumberWithString:@"0.697674419"] doubleValue];
    double actualResult = [[NSDecimalNumber decimalNumberWithContinuedFraction:contFrac] doubleValue];
    STAssertEqualsWithAccuracy(expectedResult, actualResult, 0.000000001, @"Bad continued fraction to decimal conversion");
}

- (void)testFractionCreationFromDecimal
{
    NSDecimalNumber *oneThirdInput = [NSDecimalNumber decimalNumberWithString:@"0.333333"];
    SQSFraction *oneThirdResult = [SQSFraction fractionWithDecimalNumber:oneThirdInput acceptableError:0.0001];
    SQSFraction *expectedOneThirdResult = [SQSFraction fractionWithNumerator:1 denominator:3 negative:NO];
    STAssertEqualObjects(oneThirdResult, expectedOneThirdResult, @"Generation of 1/3 failed");
    
    NSDecimalNumber *nineEleventhsInput = [NSDecimalNumber decimalNumberWithString:@"0.81818181"];
    SQSFraction *nineEleventhsResult = [SQSFraction fractionWithDecimalNumber:nineEleventhsInput acceptableError:0.0001];
    SQSFraction *expectedNineEleventhsResult = [SQSFraction fractionWithNumerator:9 denominator:11 negative:NO];
    STAssertEqualObjects(nineEleventhsResult, expectedNineEleventhsResult, @"Generation of 9/11 failed");
    
    NSDecimalNumber *negativeNineEleventhsInput = [NSDecimalNumber decimalNumberWithString:@"-.8181818181"];
    SQSFraction *negativeNineEleventhsResult = [SQSFraction fractionWithDecimalNumber:negativeNineEleventhsInput acceptableError:0.0001];
    SQSFraction *expectedNegativeNineEleventhsResult = [SQSFraction fractionWithNumerator:9 denominator:11 negative:YES];
    STAssertEqualObjects(negativeNineEleventhsResult, expectedNegativeNineEleventhsResult, @"Generation of -9/11 failed");
    
}

- (void)testMixedNumberFormatting
{
    NSString *expectedResult = @"2 1/4";
    SQSFraction *input = [SQSFraction fractionWithNumerator:9 denominator:4 negative:NO];
    NSString *result = [input stringValueWithStyle:SQSFractionStringStyleMixedNumber];
    STAssertEqualObjects(expectedResult, result, @"Generation of positive mixed number string failed");
    
    NSString *negExpectedResult = @"-2 1/4";
    SQSFraction *negInput = [SQSFraction fractionWithNumerator:9 denominator:4 negative:YES];
    NSString *negResult = [negInput stringValueWithStyle:SQSFractionStringStyleMixedNumber];
    STAssertEqualObjects(negExpectedResult, negResult, @"Generation of negative mixed number string failed");
}

- (void)testCopying
{
    SQSFraction *input = [SQSFraction fractionWithNumerator:3 denominator:8 negative:NO];
    SQSFraction *copy = [input copy];
    STAssertEqualObjects(input, copy, @"Copy not equal to copied object");
}

- (void)testCoding
{
    SQSFraction *input = [SQSFraction fractionWithNumerator:3 denominator:8 negative:NO];
    
    NSData *keyedArchive = [NSKeyedArchiver archivedDataWithRootObject:input];
    STAssertNotNil(keyedArchive, @"Keyed archiving failed");
    SQSFraction *keyedOutput = [NSKeyedUnarchiver unarchiveObjectWithData:keyedArchive];
    STAssertEqualObjects(keyedOutput, input, @"Keyed unarchiving failed");
    
    NSData *serialArchive = [NSArchiver archivedDataWithRootObject:input];
    STAssertNotNil(serialArchive, @"Serial archiving failed");
    SQSFraction *serialOutput = [NSUnarchiver unarchiveObjectWithData:serialArchive];
    STAssertEqualObjects(serialOutput, input, @"Serial unarchiving failed");
}

@end
