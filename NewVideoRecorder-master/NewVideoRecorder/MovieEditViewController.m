//
//  MoviewEditViewController.m
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/07/22.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import "Defines.h"
#import "MovieEditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@implementation MovieEditViewController{
    
    UIImageView* photoView;
    CostumDraggingView* cuttingView;
    NSArray* thumnailArray;
    
    UIScrollView* mainView;
    CGSize thumnailSize;
    
}

const int FRAME_HEIGHT = 100;
const int CUTTINGVIEW_HEIGHT = 100;
const int kVideoFPS = 30;

-(void)initialize{
    
    //スクロールビューの準備
    mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - FRAME_HEIGHT- self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, FRAME_HEIGHT)];
    mainView.delegate = self;
    mainView.bounces  = NO;
    thumnailSize = CGSizeMake(self.view.frame.size.width/30, FRAME_HEIGHT);
    mainView.backgroundColor = [UIColor redColor];
    [self.view addSubview:mainView];
    
    //フレーム画像表示部の準備
    photoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-FRAME_HEIGHT-CUTTINGVIEW_HEIGHT-self.navigationController.navigationBar.frame.size.height)];
    [self.view addSubview:photoView];
    
    //動画カットViewの準備
    
    cuttingView = [[CostumDraggingView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height -FRAME_HEIGHT - CUTTINGVIEW_HEIGHT-self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, CUTTINGVIEW_HEIGHT)];
    cuttingView.delegate = self;
    //cuttingView.parent = self;
    cuttingView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:cuttingView];
    
    //ナビゲーションコントローラのスワイプBackを無効化
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //ナビゲーションコントローラに保存ボタンを追加
    UIBarButtonItem* right1 = [[UIBarButtonItem alloc]
                               initWithTitle:@"右1"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(cutMovie)];
    self.navigationItem.rightBarButtonItems = @[right1];
    
}

-(void)setContents:(NSArray*)imageArray{
    
    int counter = 0;
    for (UIImage* image in imageArray) {
        
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(counter*thumnailSize.width, 0, thumnailSize.width, thumnailSize.height)];
        counter++;
        //imageView.contentMode = UIViewContentModeRedraw;
        imageView.image = image;
        imageView.backgroundColor = [UIColor redColor];
        [mainView addSubview:imageView];
        
        if(counter == 1){
            photoView.image = image;
        }
        
    }
    CGSize size = CGSizeMake(thumnailSize.width*counter, thumnailSize.height);
    mainView.contentSize = size;
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if (floor(NSFoundationVersionNumber) &gt; NSFoundationVersionNumber_iOS_6_1){
        // ①下から表示
        self.edgesForExtendedLayout = UIRectEdgeNone;
        // ②不透明バーがレイアウトに含まれない
        self.extendedLayoutIncludesOpaqueBars = NO;
        // ③ScrollViewのインセット自動調整をしない
        self.automaticallyAdjustsScrollViewInsets = NO;
    //}
    
    [self initialize];
    
    AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    thumnailArray = [self createThumbnailImage:asset];
    [self setContents:thumnailArray];
    
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


//プロトコル
-(void)changeThumnail:(int)leftViewPosition{
    
    int oneFrameSize = self.view.frame.size.width/30;
    int frame = leftViewPosition / oneFrameSize;
    
    //撮影数が下回っていた場合
    if(frame >= (thumnailArray.count - 1)){
        frame = thumnailArray.count - 1;
    }
    
    photoView.image = thumnailArray[frame];
    
}

- (void)cutMovie
{
    // 1
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *inputPath = [[path stringByAppendingPathComponent:@"portrait1"] stringByAppendingPathExtension:@"mov"];
    NSString *outputPath = [[path stringByAppendingPathComponent:@"result"] stringByAppendingPathExtension:@"mov"];
    Float64 startTime = 2;
    Float64 duration = 3;
    
    // 2
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error;
    
    // 3
//    NSURL *inputURL = [NSURL fileURLWithPath:inputPath];
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:inputURL options:nil];
    
    AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    
    // 4
    if (startTime >= CMTimeGetSeconds(asset.duration) || startTime < 0 || duration <= 0)
        return;
    CMTime rangeStart = CMTimeMakeWithSeconds(startTime, kVideoFPS);
    CMTime rangeDuration = CMTimeMakeWithSeconds(duration, kVideoFPS);
    CMTimeRange inputRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    CMTimeRange outputRange = CMTimeRangeMake(rangeStart, rangeDuration);
    
    // 5
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    
    // 6
    [compositionVideoTrack insertTimeRange:outputRange ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    [compositionAudioTrack insertTimeRange:outputRange ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    
    // 7
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = inputRange;
    
    // 8
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    // 9
    CGSize videoSize = videoTrack.naturalSize;
    CGAffineTransform transform = videoTrack.preferredTransform;;
    if (transform.a == 0 && transform.d == 0 && (transform.b == 1.0 || transform.b == -1.0) && (transform.c == 1.0 || transform.c == -1.0))
    {
        videoSize = CGSizeMake(videoSize.height, videoSize.width);
    }
    
    // 10
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    instruction.layerInstructions = @[layerInstruction];
    
    // 11
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = videoSize;
    videoComposition.instructions = @[instruction];
    videoComposition.frameDuration = CMTimeMake(1, kVideoFPS);
    
    // 12
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:outputPath])
    {
        [fm removeItemAtPath:outputPath error:&error];
    }
    
    // 13
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    session.outputURL = [NSURL fileURLWithPath:outputPath];
    session.outputFileType = AVFileTypeQuickTimeMovie;
    session.videoComposition = videoComposition;
    
    // 14
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"output complete!");
            NSURL *outputURL = session.outputURL;
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    //delete file from documents after saving to camera roll
                    [self removeFile:outputURL];
                    if (error) {
                        
                    } else {
                        NSLog(@"output all complete!");
                    }
                }];
            }
            
        }
        else
        {
            NSLog(@"output error! : %@", session.error);
        }
    }];

}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
}
@end
