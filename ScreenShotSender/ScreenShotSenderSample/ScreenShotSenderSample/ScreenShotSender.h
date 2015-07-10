//
//  ScreenShotSender.h
//
//
//  Created by VCJPCM012 on 2015/07/10.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ScreenShotSender : NSObject<MFMailComposeViewControllerDelegate>

@property (nonatomic,strong)UIWindow* senderWindow;
@property (nonatomic,strong)UIImage* senderImage;

+(void)setScreenShotWindow;

+(NSString*)getToken;
+(NSString*)getChannel;
+(BOOL)getSlackMode;
+(NSString*)getMailTitle;
+(NSString*)getMailTo;

@end
