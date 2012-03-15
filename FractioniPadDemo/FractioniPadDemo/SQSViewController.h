//
//  SQSViewController.h
//  FractioniPadDemo
//
//  Created by Conrad Shultz on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQSFraction.h"

@interface SQSViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (assign, nonatomic) IBOutlet UITextField *addend;
@property (assign, nonatomic) IBOutlet UITextField *numerator;
@property (assign, nonatomic) IBOutlet UITextField *denominator;
@property (assign, nonatomic) IBOutlet UITextField *result;
@property (assign, nonatomic) IBOutlet UIPickerView *style;

@end
