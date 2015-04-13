//
//  ViewController.h
//  FaceAdjust
//
//  Created by zhou shiwei on 15/4/5.
//  Copyright (c) 2015年 zhou shiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <opencv2/opencv.hpp>
#include <fstream>
#include "overhauser.hpp"
@interface ViewController : UIViewController
{
     NSMutableArray *imageList;
    float xscale;
    float yscale;
    cv::Mat sourceMat;
    float imagescale;
     CALayer *maskview;
    std::vector<cv::Point2f> newFacepts;
    CGImageRef cgimage;
  
}
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UILabel *PointLabel;
@property (nonatomic,strong) UIImageView *thumImageView;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

int findNEarestPt(cv::Point2f pt, float maxDist);

@end
