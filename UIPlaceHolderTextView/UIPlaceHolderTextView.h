//
//  UIPlaceHolderTextView.h
//  
//
//  Created by VCJPCM012 on 2014/12/19.
//  Copyright (c) 2014年 HidekiYokozeki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end