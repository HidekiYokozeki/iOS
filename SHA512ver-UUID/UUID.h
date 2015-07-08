//
//  UUID.h
//  
//
//  Created by VCJPCM012 on 2015/01/22.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUID : NSObject


+ (NSString*)getUUID;
+ (NSString*)getTimeStamp;
+ (NSString *)createSHA512:(NSString *)string;


@end
