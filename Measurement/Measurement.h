//
//  Measurement.h
//  
//
//  Created by VCJPCM012 on 2015/06/26.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Measurement : NSObject

typedef enum{
    Sec = 1000000000,
    miriSec = 1000000,
    microSec = 1000,
    nanoSec = 1
}measureOptions;

@property(nonatomic,assign) uint64_t start;
@property(nonatomic,assign) uint64_t end;

+ (Measurement *)sharedManager;
+(void)measure_start;
+(void)measure_end;
+(void)resultMeasureTime:(measureOptions)option;


@end
