//
//  MoviewEditViewController.m
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/07/22.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import "MovieEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation MovieEditViewController{
    
    UIScrollView* mainView;
    CGSize thumnailSize;
    
}

const int FRAME_HEIGHT = 100;

-(void)initialize{
    
    //スクロールビューの準備
    mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - FRAME_HEIGHT, self.view.frame.size.width, FRAME_HEIGHT)];
    mainView.delegate = self;
    mainView.bounces  = NO;
    thumnailSize = CGSizeMake(self.view.frame.size.width/30, FRAME_HEIGHT);
    [self.view addSubview:mainView];

}

-(void)setContents:(NSArray*)imageArray{
    
    int counter = 0;
    for (UIImage* image in imageArray) {
        
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(counter*thumnailSize.width, 0, thumnailSize.width, thumnailSize.height)];
        counter++;
        imageView.contentMode = UIViewContentModeRedraw;
        imageView.image = image;
        [mainView addSubview:imageView];
    }
    CGSize size = CGSizeMake(thumnailSize.width*counter, 10);
    mainView.contentSize = size;
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    
    AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    NSArray* array = [self createThumbnailImage:asset];
    [self setContents:array];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (NSArray*)createThumbnailImage:(AVURLAsset*)asset {
    
    NSMutableArray* result = [NSMutableArray array];
    
    if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
        AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        [imageGen setAppliesPreferredTrackTransform:YES];
        
        
        Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
        
        for(Float64 i = 0; i <= 30 ;i++){
            CMTime point =   CMTimeMakeWithSeconds(i, 600);
            NSError* error = nil;
            CMTime actualTime;
            CGImageRef halfWayImageRef = [imageGen copyCGImageAtTime:point actualTime:&actualTime error:&error];
            if (halfWayImageRef != NULL) {
                UIImage* myImage = [[UIImage alloc]initWithCGImage:halfWayImageRef];
                [result addObject:myImage];
                CGImageRelease(halfWayImageRef);
            }
            
            if(i >= durationSeconds){
                break;
            }
            
        }
        
    }
    return result;
}

/*
- (UIImage*)createThumbnailImage:(AVURLAsset*)asset {
    if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
        AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        [imageGen setAppliesPreferredTrackTransform:YES];
        
        Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
        CMTime midpoint =   CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
        NSError* error = nil;
        CMTime actualTime;
        
        CGImageRef halfWayImageRef = [imageGen copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
        
        if (halfWayImageRef != NULL) {
            UIImage* myImage = [[UIImage alloc]initWithCGImage:halfWayImageRef];
            CGImageRelease(halfWayImageRef);
            return myImage;
        }
    }
    return nil;
}
*/
@end
