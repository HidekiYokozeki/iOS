//
//  ConvertUIImage.h
//  
//
//  Created by VCJPCM012 on 2015/01/27.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConvertUIImage : UIImage

+ (ConvertUIImage*) imageNamed:(NSString*) name;
+ (ConvertUIImage*)convert:(NSString*)fileName Extensiton:(NSString*)fileExtension;
+ (ConvertUIImage *)sharedManager;

-(void)cacheImage:(ConvertUIImage*)img keyName:(NSString*)fileName;
-(void)memCpyCache;


@end