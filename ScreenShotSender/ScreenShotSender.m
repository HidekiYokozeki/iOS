//
//  ScreenShotSender.m
//
//
//  Created by VCJPCM012 on 2015/07/10.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

/*
 If you like to use AFNetworking, you can use "upLoadImageToSlackUsingAFNetWorking" method.
 Please remove Comment out from Line 17, 61, 127 to 148.
 */

#import "ScreenShotSender.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
//#import <AFNetworking.h>
#import <sys/sysctl.h>

@implementation ScreenShotSender
static ScreenShotSender *sharedData_ = nil;

//PUT if you want to use Slack send mode
static NSString *channel = @"INPUT_YOUR_CHANNEL";
static NSString *token = @"INPUT_YOUR_TOKEN";

//PUT if you want to use Mail send mode
static NSString *mailTitle = @"INPUT_MAIL_TITLE";
static NSString *mailTo = @"INPUTEMAIL@example.com";

//PUT if you want to save Local Camera Library
static bool needSaveToLibrary = false;

//true : SlackSendMode
//false: MailSendMode
static bool slackMode = true;

- (void)showAlert{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"detail"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"cancel"
                                            otherButtonTitles:@"send", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [message textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [message show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString* message;
    
    switch (buttonIndex) {
        //cancel
        case 0:
            break;
        //send
        case 1:
            message = [self packMassege:[[alertView textFieldAtIndex:0] text]];
            [self upLoadImageToSlack:[ScreenShotSender sharedManager].senderImage message:message];
            //[self upLoadImageToSlackUsingAFNetWorking:[ScreenShotSender sharedManager].senderImage message:message];
        default:
            break;
    }
    
    if (buttonIndex==1) {
        
    }
}

- (void)upLoadImageToSlack:(UIImage*)image message:(NSString*)message{
    NSData *sampleData = [[NSData alloc]initWithData:UIImagePNGRepresentation(image)];
    
    //API
    NSURL *url = [NSURL URLWithString:@"https://slack.com/api/files.upload"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    //multipart/form-data boundary
    CFUUIDRef uuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *boundary = [NSString stringWithFormat:@"abcdefghijklmn-%@",uuidString];
    
    //slackFileParams
    NSString *parameter = @"file";
    
    //imageName
    NSString *fileName = @"screenshot.jpg";
    
    //imageType
    NSString *contentType = @"image/jpg";
    
    NSMutableData *postBody = [NSMutableData data];
    
    //channnel
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"channels"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", channel] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //token
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"token"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", token] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialComment
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"initial_comment"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", message] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Image
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",parameter,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:sampleData];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //request header
    NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:header forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postBody];
    
    [NSURLConnection connectionWithRequest:request delegate:self];}

-(void)upLoadImageToSlackUsingAFNetWorking:(UIImage*)image message:(NSString*)message{
    /*
    NSData* pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation( image )];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary* params  = @{ @"channels":@"C07DXGRK6",
                               @"token":@"xoxp-2662122641-2738747511-7473803299-126ab4",
                               @"initial_comment":message};
    [manager POST:@"https://slack.com/api/files.upload"
       parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         [formData appendPartWithFileData:pngData name:@"file" fileName:@"image.png" mimeType:@"image/jpg"];
         
     }
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"response is :  %@",responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@ *****", [error description]);
     }];
     */
}

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


-(NSString*)packMassege:(NSString*)message{
    NSString* resultMessage;
    
    //Getting deviceName
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *deviceName = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    deviceName = [self convertToProductName:deviceName];
    free(machine);
    
    //Getting iOS ver
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    //Getting app_version
    NSString *app_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    resultMessage = [NSString stringWithFormat:@" 端末名:%@\n iOSver:%.2f\n AppVer:%@\n 特記事項:%@\n",deviceName,osVersion,app_version,message];
    
    return resultMessage;
}

- (void)didTap:(UITapGestureRecognizer *)tap {
    
    [ScreenShotSender sharedManager].senderWindow.hidden = YES;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *aWindow in [[UIApplication sharedApplication] windows]) {
        [aWindow.layer renderInContext:context];
    }
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [ScreenShotSender sharedManager].senderWindow.hidden = NO;
    
    //save image to Library if needSaveToLivrary is true
    if(needSaveToLibrary){
        UIImageWriteToSavedPhotosAlbum(capturedImage, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
    }
    [ScreenShotSender sharedManager].senderImage = capturedImage;
    
    if(slackMode){
        [self showAlert];
    }else{
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:mailTitle];
        
        //To,Cc,Bcc
        NSArray *toRecipients = [NSArray arrayWithObject:mailTo];
        //    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
        //    NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
        [picker setToRecipients:toRecipients];
        //    [picker setCcRecipients:ccRecipients];
        //    [picker setBccRecipients:bccRecipients];
        
        //imageData
        NSData *data  = [[NSData alloc]initWithData:UIImagePNGRepresentation(capturedImage)];
        [picker addAttachmentData:data mimeType:@"image/jpg" fileName:@"image"];
        [window.rootViewController presentViewController:picker animated:NO completion:nil];
    

    }

}

- (void) savingImageIsFinished:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo
{
    

    
    if(_error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                        message:@"fail to save Image"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil
                              ];
        
        [alert show];
        //[[ScreenShotSender sharedManager] stopIndicator];
        
    }else{//保存できたとき
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"complete"
                                                        message:@"Succsess to save Image"
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
        
        [ScreenShotSender sharedManager].senderWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [ScreenShotSender sharedManager].senderWindow.restorationIdentifier = @"SenderCaptureWindow";
        [ScreenShotSender sharedManager].senderWindow.backgroundColor = [UIColor colorWithRed: 1.0f green: 0 blue: 0 alpha: 0.25f];
        
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        label.font = [UIFont systemFontOfSize:10];
        label.text = @"Capture";
        label.center = [ScreenShotSender sharedManager].senderWindow.center;
        label.textAlignment = NSTextAlignmentCenter;
        [[ScreenShotSender sharedManager].senderWindow addSubview:label];
        
        // (1)
        [[ScreenShotSender sharedManager].senderWindow addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTap:)]];
        
        UIWindow *window = noti.object;
        [ScreenShotSender sharedManager].senderWindow.windowLevel = window.windowLevel + 1;
        [[ScreenShotSender sharedManager].senderWindow makeKeyAndVisible];
        
        //set gesture recognizer
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

-(NSString*)convertToProductName:(NSString*)deviceName{
    
    //Device Name table
    NSDictionary* productNames = @{
                                   @"iPhone1,1" : @"iPhone",
                                   @"iPhone1,2" : @"iPhone3G",
                                   @"iPhone2,1" : @"iPhone3GS",
                                   @"iPhone3,1" : @"iPhone4_GSM",
                                   @"iPhone3,3" : @"iPhone4_CDMA",
                                   @"iPhone4,1" : @"iPhone4S",
                                   @"iPhone5,1" : @"iPhone5_A1428",
                                   @"iPhone5,2" : @"iPhone5_A1429",
                                   @"iPhone5,3" : @"iPhone5c_A1456A1532",
                                   @"iPhone5,4" : @"iPhone5c_A1507A1516A1529",
                                   @"iPhone6,1" : @"iPhone5s_A1433A1453",
                                   @"iPhone6,2" : @"iPhone5s_A1457A1518A1530",
                                   @"iPhone7,1" : @"iPhone6Plus",
                                   @"iPhone7,2" : @"iPhone6",
                                   @"iPad1,1" 	 : @"iPad",
                                   @"iPad2,1"   : @"iPad2_Wi-Fi",
                                   @"iPad2,2"   : @"iPad2_GSM",
                                   @"iPad2,3"   : @"iPad2_CDMA",
                                   @"iPad2,4"   : @"iPad2_Wi-Fi_revised",
                                   @"iPad2,5"   : @"iPadmini_Wi-Fi",
                                   @"iPad2,6"   : @"iPadmini_A1454",
                                   @"iPad2,7"   : @"iPadmini_A1455",
                                   @"iPad3,1"   : @"iPad3rdgen_Wi-Fi",
                                   @"iPad3,2"   : @"iPad3rdgen_Wi-FiLTEVerizon",
                                   @"iPad3,3"   : @"iPad3rdgen_Wi-FiLTEAT_T",
                                   @"Pad3,4"    : @"iPad4thgen_Wi-Fi",
                                   @"iPad3,5"   : @"iPad4thgen_A1459",
                                   @"iPad3,6"   : @"iPad4thgen_A1460",
                                   @"iPad4,1"   : @"iPadAir_Wi-Fi",
                                   @"iPad4,2"   : @"iPadAir_Wi-FiLTE",
                                   @"iPad4,3"   : @"iPadAir_Rev",
                                   @"iPad4,4"   : @"iPadmini2_Wi-Fi",
                                   @"iPad4,5"   : @"iPadmini2_Wi-FiLTE",
                                   @"iPad4,6"   : @"iPadmini2Rev",
                                   @"iPad4,7"   : @"iPadmini3_Wi-Fi",
                                   @"iPad4,8"   : @"iPadmini3_A1600",
                                   @"iPad4,9"   : @"iPadmini3_A1601",
                                   @"iPad5,3"   : @"iPadAir2_Wi-Fi",
                                   @"iPad5,4"   : @"iPadAir2_Wi-FiLTE",
                                   @"iPod1,1"   : @"iPodtouch",
                                   @"iPod2,1"   : @"iPodtouch_2ndgen",
                                   @"iPod3,1"   : @"iPodtouch_3rdgen",
                                   @"iPod4,1"   : @"iPodtouch_4thgen",
                                   @"iPod5,1"   : @"iPodtouch_5thgen"
                                   };
    
    
    if([productNames objectForKey:deviceName]){
        return [productNames objectForKey:deviceName];
    }
    
    return deviceName;//[NSString stringWithFormat:@"%@_%@",[UIDevice currentDevice].model,deviceName];
    
    
    
    
}


@end
