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
@interface ViewController : UIViewController
{
     NSMutableArray *imageList;
    float xscale;
    float yscale;
    cv::Mat sourceMat;
    float imagescale;
    cv::Point2f ImageViewCenter;
    std::vector<cv::Point2f> sourcePts;
}
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UILabel *PointLabel;

@end
