
//
//  MoviewEditViewController.h
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/07/22.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieEditViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic, strong) NSURL *fileURL;
@property(nonatomic, strong) NSMutableArray *array;

@end
