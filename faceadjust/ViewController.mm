//
//  ViewController.m
//  FaceAdjust
//
//  Created by zhou shiwei on 15/4/5.
//  Copyright (c) 2015年 zhou shiwei. All rights reserved.
//

#import "ViewController.h"
#import "UIImageCVMatConverter.h"
using namespace std;
using namespace cv;
@interface ViewController ()

@end
 int facialIndex[31]={0,3,6,8,11,13,16,17,19,21,22,24,26,27,30,31,35,36,37,39,41,42,43,45,47,48,51,54,57,61,64};
@implementation ViewController
@synthesize imageView;
- (void)viewDidLoad {
    [super viewDidLoad];
    imageList=[NSMutableArray array];
   
   
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    ImageViewCenter=cv::Point2f(screenBounds.origin.x+screenBounds.size.width/2,screenBounds.origin.y+screenBounds.size.height/2);
    imageView = [[UIImageView alloc] initWithFrame:screenBounds];
    imageView.image = [UIImage imageNamed:@"1.jpg"];
    imageView.backgroundColor=[UIColor redColor];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    sourceMat=[UIImageCVMatConverter cvMatFromUIImage:imageView.image];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [imageView addGestureRecognizer:pinch];
    std::ifstream ifs;
    NSString *datatex=[[NSBundle mainBundle] pathForResource:@"1" ofType:@"txt"];
    std::vector<cv::Point2f> SourcePoints,framePoints;
    string datapath=[datatex UTF8String];
    ifs.open(datapath);
    xscale=imageView.image.size.width/imageView.frame.size.width;
    yscale=imageView.image.size.height/imageView.frame.size.height;
   
    for (int i=0;i<66;i++) {
        cv::Point2f xxx;
        ifs >> xxx.x >>xxx.y;
        SourcePoints.push_back(cv::Point2f(xxx.x,xxx.y));
        framePoints.push_back(cv::Point2f(xxx.x/xscale,xxx.y/yscale));
    }
    
    for (int i=0; i<31; i++) {
        int index=facialIndex[i];
        CGFloat x = framePoints.at(index).x;
        CGFloat y = framePoints.at(index).y;
        sourcePts.push_back(cv::Point2f(x,y));
        CGFloat size = 10.0f;
        UIImageView *image=[[UIImageView alloc] initWithFrame:CGRectMake(x-size/2, y-size/2, size, size)];
        image.image=[UIImage imageNamed:@"blue_point@2x.png"];
        image.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.view addSubview:image];
        [image addGestureRecognizer:pan];
        pan.view.tag=i;
        [imageList addObject:image];
    }
    

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setBackgroundColor:[UIColor clearColor]];
    confirmButton.frame = CGRectMake(screenBounds.size.width-60, screenBounds.size.height-260, 40, 40);
    [confirmButton setImage:[UIImage imageNamed:@"btn_camera_ok_a@2x.png"] forState:UIControlStateNormal];
    [confirmButton setImage:[UIImage imageNamed:@"btn_camera_ok_a@2x.png"] forState:UIControlStateSelected];
    [confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    imagescale=1.0;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)confirm
{
    

    for(int i=0;i<66;i++){
        UIImageView *imagec=   [imageList objectAtIndex:i];
        CGFloat x = imagec.center.x*xscale;
        CGFloat y = imagec.center.y*yscale;
        circle(sourceMat, cv::Point2f(x,y), 13, Scalar(255,0,0),-1);
    
    }
    
    imageView.image=[UIImageCVMatConverter UIImageFromCVMat:sourceMat];
}
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    // [self drawImageForGestureRecognizer:gestureRecognizer atPoint:location underAdditionalSituation:nil];
    //gestureRecognizer.view.center = CGPointMake(gestureRecognizer.view.center.x + location.x, gestureRecognizer.view.center.y + location.y);
    
    [gestureRecognizer setTranslation:location inView:self.view];
  
    UIImageView *imagec=   [imageList objectAtIndex:(int)gestureRecognizer.view.tag];
    
    CGFloat x =sourcePts.at((int)gestureRecognizer.view.tag).x-(sourcePts.at((int)gestureRecognizer.view.tag).x-ImageViewCenter.x)*(1-imagescale);
    CGFloat y = sourcePts.at((int)gestureRecognizer.view.tag).y-(sourcePts.at((int)gestureRecognizer.view.tag).y-ImageViewCenter.y)*(1-imagescale);
    imagec.center=CGPointMake(location.x, location.y);
    printf("dxhvjgj  %f  %f %ld\n",location.x, location.y, (long)gestureRecognizer.view.tag);
   
}

/* 识别放大缩小 */
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
  //  CGPoint location = [gestureRecognizer locationInView:self.view];
    gestureRecognizer.view.transform = CGAffineTransformScale(gestureRecognizer.view.transform, gestureRecognizer.scale, gestureRecognizer.scale);
    printf("%f\n",gestureRecognizer.scale);
    imagescale*= gestureRecognizer.scale;
    for(int i=0;i<31;i++){
        UIImageView *imagec=   [imageList objectAtIndex:i];
        CGFloat x =sourcePts.at(i).x-(sourcePts.at(i).x-ImageViewCenter.x)*(1-imagescale);
        CGFloat y = sourcePts.at(i).y-(sourcePts.at(i).y-ImageViewCenter.y)*(1-imagescale);
        imagec.center=CGPointMake(x, y);
        
    }
    gestureRecognizer.scale =1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
