//
//  ViewController.m
//  ScreenShotSenderSample
//
//  Created by VCJPCM012 on 2015/07/10.
//  Copyright (c) 2015年 VCJPCM012. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated{
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please change setting data in ScreenShotSender.m"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"cancel"
                                            otherButtonTitles:@"OK", nil];
    [message textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    
    if([ScreenShotSender getSlackMode]){
    
        if([[ScreenShotSender getChannel] isEqualToString:@"INPUT_YOUR_CHANNEL"] || [[ScreenShotSender getToken] isEqualToString:@"INPUT_YOUR_TOKEN"]){
            [message show];
        }
        
    }else{
        if([[ScreenShotSender getMailTitle] isEqualToString:@"INPUT_MAIL_TITLE"] || [[ScreenShotSender getMailTo] isEqualToString:@"INPUTEMAIL@example.com"]){
            [message show];
        }
        
    }
    


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
