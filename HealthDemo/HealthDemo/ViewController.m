//
//  ViewController.m
//  HealthDemo
//
//  Created by LYX on 16/9/26.
//  Copyright © 2016年 LYX. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, copy) NSString *addString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.healthStore = [[HKHealthStore alloc]init];
    _textField.placeholder = @"请填写步数";
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    

}
- (IBAction)addAction:(id)sender {

    [self _addStepsCounts];
}

- (void)_addStepsCounts{
    _addString = _textField.text;
    if (_addString == nil || [_addString isEqualToString:@""]) {
        [self _showAlert:@"请填写增加的步数"];
    }else{
        
        double stepsCounts = [_addString doubleValue];
        HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        NSSet *writeDataTypes = [NSSet setWithObjects:stepCountType, nil];
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:nil completion:^(BOOL success, NSError * _Nullable error) {
        }];
        HKQuantityType * quantityTypeIdentifier = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:stepsCounts];
        
        HKQuantitySample *temperatureSample = [HKQuantitySample quantitySampleWithType:quantityTypeIdentifier quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
        
        [self.healthStore saveObject:temperatureSample withCompletion:^(BOOL success, NSError * _Nullable error) {
            
            //需要回到主线程显示Alert
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _showAlert:@"添加成功"];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _showAlert:@"添加失败"];
                });
                
            }
        }];
    }
}

- (void)_showAlert:(NSString *)tips{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:tips preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"确定");
    }];

    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self _addStepsCounts];
    return YES;
}


@end
