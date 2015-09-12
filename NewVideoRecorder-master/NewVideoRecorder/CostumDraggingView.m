//
//  CostumDraggingView.m
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/08/25.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import "Defines.h"
#import "CostumDraggingView.h"

@implementation CostumDraggingView{
    
    UIView* draggingViewLeft;
    UIView* draggingViewRight;
    
    UIView* colorView;
    

}

const int BAR_WIDTH = 30;
const int LEFT_TAG = 1;
const int RIGHT_TAG = 2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init:(CGRect)frame
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.startTime = 0;
    self.endTime =DEFINES_MAX_TIME;
    
    //左にドラッギング用のViewを準備
    draggingViewLeft  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BAR_WIDTH, self.frame.size.height)];
    draggingViewLeft.backgroundColor = [UIColor blueColor];
    draggingViewLeft.tag = LEFT_TAG;
    
    //右にドラッギング用のViewを準備
    draggingViewRight = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width-BAR_WIDTH, 0, BAR_WIDTH, self.frame.size.height)];
    draggingViewRight.backgroundColor = [UIColor blueColor];
    draggingViewRight.tag = RIGHT_TAG;
    
    UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [draggingViewLeft  addGestureRecognizer:panGesture1];
    [draggingViewRight addGestureRecognizer:panGesture2];
    
    
    //View追加
    [self addSubview:draggingViewLeft];
    [self addSubview:draggingViewRight];
    
    //便利な省略形
    self.startTime = 10;
    int x = self.startTime;
    
    //正しい書き方
    [self setStartTime:10];
    int x2 = [self startTime];
}

-(void)dragged:(UIPanGestureRecognizer*) sender{
    
    UIView *draggedView = sender.view;
    CGPoint delta = [sender translationInView:draggedView];
    CGPoint movedPoint = CGPointMake(draggedView.center.x + delta.x, draggedView.center.y/*+ delta.y*/);
    
    
    if(draggedView.tag == LEFT_TAG){
        
        //画面端で止める
        if(movedPoint.x <= (0+BAR_WIDTH/2) ){
            movedPoint.x = BAR_WIDTH/2;
        }
        
        //RightBarを越えないように制御
        if(movedPoint.x >= (draggingViewRight.frame.origin.x -BAR_WIDTH/2 )){
            movedPoint.x = (draggingViewRight.frame.origin.x -BAR_WIDTH/2 );
        }
        
        
    }else{
        
        //画面端で止める
        if(movedPoint.x >= (self.frame.size.width - BAR_WIDTH/2) ){
            movedPoint.x = (self.frame.size.width - BAR_WIDTH/2);
        }
        
        //LeftBarを越えないように制御
        if(movedPoint.x <= (draggingViewLeft.frame.origin.x + BAR_WIDTH + BAR_WIDTH/2 )){
            movedPoint.x = (draggingViewLeft.frame.origin.x + BAR_WIDTH + BAR_WIDTH/2 );
        }
        
        
    }
    
    
    draggedView.center = movedPoint;
    [sender setTranslation:CGPointZero inView:draggedView];
    [self changedState];
    
//    if(sender.state != UIGestureRecognizerStateEnded){
//
//
//
//    }
    
}


-(void)changedState{

    if(!colorView){
        colorView = [[UIView alloc]initWithFrame:CGRectMake(draggingViewLeft.frame.origin.x+BAR_WIDTH, 0, self.frame.size.width - draggingViewRight.frame.origin.x, self.frame.size.height)];
        colorView.backgroundColor = [UIColor yellowColor];
        [self addSubview:colorView];
    }else{
        colorView.frame = CGRectMake(draggingViewLeft.frame.origin.x+BAR_WIDTH, 0, draggingViewRight.frame.origin.x - draggingViewLeft.frame.origin.x-BAR_WIDTH, self.frame.size.height);
    }
    
    [self.delegate changeThumnail:draggingViewLeft.frame.origin.x];

}


@end
