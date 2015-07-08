//
//  Measurement.m
//  
//
//  Created by VCJPCM012 on 2015/06/26.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import "Measurement.h"
#import <mach/mach_time.h>

@implementation Measurement



static Measurement *sharedData_ = nil;

+(void)measure_start{
    
    [Measurement sharedManager].start = mach_absolute_time();
    
}

+(void)measure_end{
 
    [Measurement sharedManager].end = mach_absolute_time();
    
}

+(void)resultMeasureTime:(measureOptions)option{
    
    if(option == 0 || !option){
        option = 1;
    }

    //丸め誤差対策で１０進数計算が扱えるオブジェクトに格納しなおす。
     NSDecimalNumber *decimal_end = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%llu",[Measurement sharedManager].end]];
      NSDecimalNumber *decimal_start = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%llu",[Measurement sharedManager].start]];

    //１０進数にそれぞれ変換
    NSDecimalNumber *decimal_unit = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d",option]];
    //単位
    NSString*unit;
    
    
    decimal_end = [decimal_end decimalNumberByDividingBy:decimal_unit];
    decimal_start = [decimal_start decimalNumberByDividingBy:decimal_unit];
    
    switch (option) {
        case Sec:
            unit = @"Sec";
            break;
        case miriSec:
            unit = @"miriSec";
            break;
        case microSec:
            unit = @"microSec";
            break;
        case nanoSec:
            unit = @"nanoSec";
            break;
            
        default:
            break;
    }
    
    NSDecimalNumber *result = [decimal_end decimalNumberBySubtracting:decimal_start];
    
    NSLog(@"Result time = %@[%@]", result,unit);

}

+ (Measurement *)sharedManager{
    
    @synchronized(self){
        
        if (!sharedData_) {
            sharedData_ = [Measurement new];
        }
        
    }
    return sharedData_;
}


@end
