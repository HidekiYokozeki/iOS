//
//  ScreenShotSender.m
//
//
//  Created by VCJPCM012 on 2015/07/09.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import "ScreenShotSender.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@implementation ScreenShotSender
static ScreenShotSender *sharedData_ = nil;
static NSString *mailTitle = @"Input_MailTitle";
static NSString *mailTo = @"InputEmail@example.com";

//キャプチャ画像をローカルのライブラリにも保存したい場合はtrueに
static bool needSaveToLibrary = false;

+ (ScreenShotSender *)sharedManager{
    
    @synchronized(self){
        
        if (!sharedData_) {
            sharedData_ = [ScreenShotSender new];
        }
        
    }
    return sharedData_;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didTap:(UITapGestureRecognizer *)tap {
    
    
    //[[ScreenShotSender sharedManager] showIndicator];
    // キャプチャ対象をWindowに
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *aWindow in [[UIApplication sharedApplication] windows]) {
        [aWindow.layer renderInContext:context];
    }
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //ライブラリにも保存する場合は下記が実行される
    if(needSaveToLibrary){
        UIImageWriteToSavedPhotosAlbum(capturedImage, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    //メールタイトル設定
    [picker setSubject:mailTitle];
    
    //To,Cc,Bccを設定: Cc,Bccが必要な場合はコメントを外す
    NSArray *toRecipients = [NSArray arrayWithObject:mailTo];
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
    [picker setToRecipients:toRecipients];
//    [picker setCcRecipients:ccRecipients];
//    [picker setBccRecipients:bccRecipients];
    
    // 添付ファイル準備
    NSData *data  = [[NSData alloc]initWithData:UIImagePNGRepresentation(capturedImage)];
    [picker addAttachmentData:data mimeType:@"image/jpg" fileName:@"image"];
    [window.rootViewController presentViewController:picker animated:NO completion:nil];
    
}

// ライブラリ保存完了を知らせる
- (void) savingImageIsFinished:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo
{
    

    
    if(_error){//エラーのとき
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"画像の保存に失敗しました。"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil
                              ];
        
        [alert show];
        //[[ScreenShotSender sharedManager] stopIndicator];
        
    }else{//保存できたとき
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完了"
                                                        message:@"スクリーンショットを保存しました。"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil
                              ];
        
        [alert show];
        //[[ScreenShotSender sharedManager] stopIndicator];
        return;
    }
}

-(void)windowDidBecomeVisible:(NSNotification*)noti
{
    
    if(![ScreenShotSender sharedManager].senderWindow){
        [ScreenShotSender sharedManager].senderWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [ScreenShotSender sharedManager].senderWindow.restorationIdentifier = @"SenderCaptureWindow";
        [ScreenShotSender sharedManager].senderWindow.backgroundColor = [UIColor colorWithRed: 1.0f green: 0 blue: 0 alpha: 0.25f];
        
        // (1)
        [[ScreenShotSender sharedManager].senderWindow addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTap:)]];
        
        UIWindow *window = noti.object;
        [ScreenShotSender sharedManager].senderWindow.windowLevel = window.windowLevel + 1;
        [[ScreenShotSender sharedManager].senderWindow makeKeyAndVisible];
        
        //gesture recognizerを設定
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
        [[ScreenShotSender sharedManager].senderWindow addGestureRecognizer:panGestureRecognizer];

        
    }
}


-(void)dragView:(UIPanGestureRecognizer *)sender
{

    UIWindow *targetView = (UIWindow*)sender.view;
    CGPoint p = [sender translationInView:targetView];
 
    CGPoint movedPoint = CGPointMake(targetView.center.x + p.x, targetView.center.y + p.y);

    targetView.center = movedPoint;
    [sender setTranslation:CGPointZero inView:targetView];
    
}


+(void)setScreenShotWindow{
    
    [[NSNotificationCenter defaultCenter] addObserver:[ScreenShotSender sharedManager]
                                             selector:@selector(windowDidBecomeVisible:)
                                                 name:UIWindowDidBecomeVisibleNotification
                                               object:nil];

}

@end
