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
 int facialIndex[31]={17,19,21,22,24,26,27,30,31,35,36,37,39,41,42,43,45,47,48,51,54,57,61,64};
int ind=-1;
int selectedPt=-1;
cv::Point2f ImageViewCenter;
 std::vector<CRSpline*> outlines;
std::vector<cv::Point2f> sourcePts;
@implementation ViewController
@synthesize imageView;
@synthesize thumImageView;

-(UIImage *)getImageInPoint:(CGPoint)point{
    // UIImage* bigImage= [UIImage imageNamed:@"5.png"];
    CGFloat x =point.x -35;
    CGFloat y = point.y -35;
    CGRect rect = CGRectMake(x, y, 70, 70);
    CGImageRef imageRef = imageView.image.CGImage;
    
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    CGSize size;
    size.width = 70;
    size.height = 70;
    UIGraphicsBeginImageContext(size);
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(subImageRef);
    size_t pixelsHigh = CGImageGetHeight(subImageRef);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //    if (colorSpace == NULL)
    //    {
    //        fprintf(stderr, "Error allocating color space\n");
    //        return NULL;
    //    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        // fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    //    if (context == NULL)
    //    {
    //        free (bitmapData);
    //        fprintf (stderr, "Context not created!");
    //    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    
    //  CGContextRef context=[UIImageCVMatConverter createARGBBitmapContextFromImage:subImageRef];
    // CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetAlpha(context, 1.0);
    
    CGContextDrawImage(context,CGRectMake(0, 0,70, 70), subImageRef);
    
//    CGFloat colors [] = {
//        0.4, 0.8, 1.0, 1.0,
//        0.0, 0.0, 1.0, 1.0
//    };
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
//    CGRect currPoint =CGRectMake(35-2,35-2, 4, 4);
//    CGContextSaveGState(context);
//    CGContextAddEllipseInRect(context, currPoint);
//    CGContextClip(context);
//    CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
//    CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//    CGContextRestoreGState(context);
//    CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
//     CGGradientRelease(gradient);
    
    CGContextDrawImage(context, CGRectMake(35-10,35-10, 20, 20), cgimage);
    
    // draw the line
//    CGContextMoveToPoint(context, 35, 25);
//    CGContextAddLineToPoint(context, 35, 45);
//    CGContextMoveToPoint(context, 25, 35);
//    CGContextAddLineToPoint(context, 45, 35);
//    CGContextStrokePath(context);
    CGImageRef imageRefnew=CGBitmapContextCreateImage(context);
    free(bitmapData);
    UIImage* smallImage = [UIImage imageWithCGImage:imageRefnew];
    UIGraphicsEndImageContext();
    CGImageRelease(imageRefnew);
    CGImageRelease(subImageRef);
    CGContextRelease(context);
    return smallImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cgimage=[UIImage imageNamed:@"btn_notice.png"].CGImage;
    outlines.resize(8);
    for (int i=0; i<outlines.size(); i++) {
        if (outlines.at(i)) {
            delete outlines.at(i);
        }
        outlines[i]=new CRSpline();
    }
    
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
        newFacepts.push_back(cv::Point2f(xxx.x/xscale,xxx.y/yscale));
    }
    
    for (int i=0; i<24; i++) {
        int index=facialIndex[i];
        CGFloat x = framePoints.at(index).x;
        CGFloat y = framePoints.at(index).y;
        sourcePts.push_back(cv::Point2f(x,y));
    }
    
    sourcePts.at(11)=cv::Point2f((framePoints.at(37).x+framePoints.at(38).x)/2,framePoints.at(37).y);
    sourcePts.at(13)=cv::Point2f((framePoints.at(41).x+framePoints.at(40).x)/2,framePoints.at(41).y);
    sourcePts.at(15)=cv::Point2f((framePoints.at(43).x+framePoints.at(44).x)/2,framePoints.at(43).y);
    sourcePts.at(17)=cv::Point2f((framePoints.at(46).x+framePoints.at(47).x)/2,framePoints.at(46).y);

    for (int i=0; i<24; i++) {
      
        CGFloat x = sourcePts.at(i).x;
        CGFloat y = sourcePts.at(i).y;
      
        CGFloat size = 10.0f;
        UIImageView *image=[[UIImageView alloc] initWithFrame:CGRectMake(x-size/2, y-size/2, size, size)];
        image.image=[UIImage imageNamed:@"blue_point@2x.png"];
        image.userInteractionEnabled = YES;
        //        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.view addSubview:image];
        // [image addGestureRecognizer:pan];
        //   pan.view.tag=i;
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
    
    maskview = [CALayer layer];
    maskview.contents = (id)[[UIImage imageNamed:@"mask.png"] CGImage];
    maskview.frame = CGRectMake(0, 0, 70, 70);
    
    thumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(125, 0, 70, 70)];
    //   thumImageView.center = point;
    [self.view addSubview:thumImageView];
    [self.view bringSubviewToFront:thumImageView];
    // Do any additional setup after loading the view, typically from a nib.
}

float F(float t,float x,int index)
{
    vec3 rv =  outlines[index]->GetInterpolatedSplinePoint(t);
    return x-rv.x;
}

float solveForX(float x,int index)
{
    float a=0,b=1.0,c,e=1e-5;
    c=(a+b)/2;
    while( (fabs(b-a)>e) && (F(c,x,index)!=0) )
    {
        if (F(a,x,index)*F(c,x,index)<0)
        {
            b=c;
        }
        else
        {
            a=c;
        }
        c=(a+b)/2;
    }
    return c;
}

// a case-insensitive comparison function:
bool mycomp (Point2f p1, Point2f p2)
{
    return p1.x<p2.x;
}

float dist(Point2f p1,Point2f p2)
{
    return sqrt((p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y));
}

int findNEarestPt(Point2f pt, float maxDist)
{
    float minDist=FLT_MAX;
    int ind=-1;
    for(int i=0;i<sourcePts.size();++i)
    {
        float d=dist(pt,sourcePts[i]);
        if(minDist>d)
        {
            ind=i;
            minDist=d;
        }
    }
    printf("%f\n",minDist);
    if(minDist>maxDist)
    {
        ind=-1;
    }
    return ind;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count]==1) {
      UITouch  *touch1=[[[event allTouches]allObjects] objectAtIndex:0];
      CGPoint  touchLocation=[touch1 locationInView:self.view];
        Point2f m;
        m.x=touchLocation.x;
        m.y=touchLocation.y;
        ind=findNEarestPt(m,25);//返回最邻近的点的序号
        if (ind==-1)
        {
            //                pts.push_back(m);
            //                selectedPt=(int)pts.size()-1;
        }else
        {
            selectedPt=ind;
        }
        
        CGPoint touchPoint;
        touchPoint.x=(touchLocation.x-imageView.frame.origin.x)*xscale;
        touchPoint.y=(touchLocation.y-imageView.frame.origin.y)*yscale;
        thumImageView.hidden=NO;
        thumImageView.image=nil;
        UIImage *image = [self getImageInPoint:touchPoint];
        thumImageView.image = image;
        
        thumImageView.layer.mask = maskview;
        thumImageView.layer.masksToBounds = YES;
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  
    for( UITouch *touch in touches )
    {
        CGPoint  touchLocation=[touch locationInView:self.view];
        Point2f m;
        m.x=touchLocation.x;
        m.y=touchLocation.y;
        
        if(ind!=-1)
        {
            sourcePts[selectedPt].x=m.x;
            sourcePts[selectedPt].y=m.y;
        
        UIImageView *imagec=   [imageList objectAtIndex:selectedPt];
        
//        CGFloat x =sourcePts.at(selectedPt).x-(sourcePts.at(selectedPt).x-ImageViewCenter.x)*(1-imagescale);
//        CGFloat y = sourcePts.at(selectedPt).y-(sourcePts.at(selectedPt).y-ImageViewCenter.y)*(1-imagescale);
        imagec.center=CGPointMake(touchLocation.x, touchLocation.y);
            
            CGPoint touchPoint;
            touchPoint.x=(touchLocation.x-imageView.frame.origin.x)*xscale;
            touchPoint.y=(touchLocation.y-imageView.frame.origin.y)*yscale;
            thumImageView.hidden=NO;
            thumImageView.image=nil;
            UIImage *image = [self getImageInPoint:touchPoint];
            thumImageView.image = image;
            thumImageView.layer.mask = maskview;
            thumImageView.layer.masksToBounds = YES;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    thumImageView.hidden=YES;
    thumImageView.image=nil;
    if ([[event allTouches] count]==1) {
        UITouch  *touch1=[[[event allTouches]allObjects] objectAtIndex:0];
        CGPoint  touchLocation=[touch1 locationInView:self.view];
        Point2f m;
        m.x=touchLocation.x;
        m.y=touchLocation.y;
        ind=-1;
        sourcePts[selectedPt].x=m.x;
        sourcePts[selectedPt].y=m.y;
    }
}

-(void)confirm
{
    for(int i=0;i<24;i++){
        UIImageView *imagec=   [imageList objectAtIndex:i];
        CGFloat x = imagec.center.x;
        CGFloat y = imagec.center.y;
        sourcePts.at(i)=cv::Point2f(x,y);
    }
    
    int   index=0;
    std::vector<cv::Point2f> roipoints;
    for (int i=0; i<3; i++) {
        vec3 v(sourcePts[i].x,sourcePts[i].y,0);
        roipoints.push_back(cv::Point2f(sourcePts[i].x,sourcePts[i].y));
        outlines[index]->AddSplinePoint(v);
    }
    
    vec3 rv_last_face(roipoints.at(0).x,roipoints.at(0).y,0);
    int sizemax=(int)roipoints.size();
    int diff=(roipoints.at(sizemax-1).x-roipoints.at(0).x)/4;
    newFacepts.at(17)=cv::Point2f(roipoints.at(0).x,roipoints.at(0).y);
    for(int i=1;i<5;i++)
    {
        float x=roipoints.at(0).x+i*diff;
        float t=solveForX(x,index);
        vec3 rv =  outlines[0]->GetInterpolatedSplinePoint(t);
        newFacepts.at(17+i)=cv::Point2f(rv.x,rv.y);
        rv_last_face=rv;
        
    }

    
    index=1;
    roipoints.clear();
    for (int i=3; i<6; i++) {
        vec3 v(sourcePts[i].x,sourcePts[i].y,0);
        roipoints.push_back(cv::Point2f(sourcePts[i].x,sourcePts[i].y));
        outlines[index]->AddSplinePoint(v);
    }
    
    rv_last_face=vec3(roipoints.at(0).x,roipoints.at(0).y,0);
    sizemax=(int)roipoints.size();
    diff=(roipoints.at(sizemax-1).x-roipoints.at(0).x)/4;
    newFacepts.at(22)=cv::Point2f(roipoints.at(0).x,roipoints.at(0).y);
    for(int i=1;i<5;i++)
    {
        float x=roipoints.at(0).x+i*diff;
        float t=solveForX(x,index);
        vec3 rv =  outlines[index]->GetInterpolatedSplinePoint(t);
      newFacepts.at(22+i)=cv::Point2f(rv.x,rv.y);
        rv_last_face=rv;
      
    }
    
    index=2;
    roipoints.clear();
    for (int i=10; i<13; i++) {
        vec3 v(sourcePts[i].x,sourcePts[i].y,0);
        roipoints.push_back(cv::Point2f(sourcePts[i].x,sourcePts[i].y));
        outlines[index]->AddSplinePoint(v);
    }
    
    rv_last_face=vec3(roipoints.at(0).x,roipoints.at(0).y,0);
    sizemax=(int)roipoints.size();
    diff=(roipoints.at(sizemax-1).x-roipoints.at(0).x)/3;
    
         newFacepts.at(36)=cv::Point2f(roipoints.at(0).x,roipoints.at(0).y);
    for(int i=1;i<4;i++)
    {
        float x=roipoints.at(0).x+i*diff;
        float t=solveForX(x,index);
        vec3 rv =  outlines[index]->GetInterpolatedSplinePoint(t);
        rv_last_face=rv;
        newFacepts.at(36+i)=cv::Point2f(rv.x,rv.y);
      
    }
    
    index=3;
    roipoints.clear();
    for (int i=12; i<14; i++) {
        vec3 v(sourcePts[i].x,sourcePts[i].y,0);
        roipoints.push_back(cv::Point2f(sourcePts[i].x,sourcePts[i].y));
        outlines[index]->AddSplinePoint(v);
    }
    outlines[index]->AddSplinePoint(vec3(sourcePts[10].x,sourcePts[10].y,0));
    roipoints.push_back(cv::Point2f(sourcePts[10].x,sourcePts[10].y));
    rv_last_face=vec3(roipoints.at(0).x,roipoints.at(0).y,0);
    sizemax=(int)roipoints.size();
    diff=(roipoints.at(sizemax-1).x-roipoints.at(0).x)/3;
        std::vector<cv::Point2f>pts;
    for(int i=1;i<4;i++)
    {
        float x=roipoints.at(0).x+i*diff;
        float t=solveForX(x,index);
        vec3 rv =  outlines[index]->GetInterpolatedSplinePoint(t);
        pts.push_back(cv::Point2f(rv.x,rv.y));
        rv_last_face=rv;
        
    }
      newFacepts.at(40)=pts.at(1);
      newFacepts.at(41)=pts.at(2);
        pts.clear();
        
    index=4;
    roipoints.clear();
    for (int i=14; i<17; i++) {
        vec3 v(sourcePts[i].x,sourcePts[i].y,0);
        roipoints.push_back(cv::Point2f(sourcePts[i].x,sourcePts[i].y));
        outlines[index]->AddSplinePoint(v);
    }
    rv_last_face=vec3(roipoints.at(0).x,roipoints.at(0).y,0);
    sizemax=(int)roipoints.size();
    diff=(roipoints.at(sizemax-1).x-roipoints.at(0).x)/3;
    newFacepts.at(42)=cv::Point2f(roipoints.at(0).x,roipoints.at(0).y);
    for(int i=1;i<4;i++)
    {
        float x=roipoints.at(0).x+i*diff;
        float t=solveForX(x,index);
        vec3 rv =  outlines[index]->GetInterpolatedSplinePoint(t);
        rv_last_face=rv;
         newFacepts.at(42+i)=cv::Point2f(rv.x,rv.y);
    }
    
    index=5;
    roipoints.clear();
    for (int i=16; i<18; i++) {
        vec3 v(sourcePts[i].x,sourcePts[i].y,0);
        roipoints.push_back(cv::Point2f(sourcePts[i].x,sourcePts[i].y));
        outlines[index]->AddSplinePoint(v);
    }
    roipoints.push_back(cv::Point2f(sourcePts[14].x,sourcePts[14].y));
    outlines[index]->AddSplinePoint(vec3(sourcePts[14].x,sourcePts[14].y,0));
    rv_last_face=vec3(roipoints.at(0).x,roipoints.at(0).y,0);
    sizemax=(int)roipoints.size();
    diff=(roipoints.at(sizemax-1).x-roipoints.at(0).x)/3;
    
    for(int i=1;i<4;i++)
    {
        float x=roipoints.at(0).x+i*diff;
        float t=solveForX(x,index);
        vec3 rv =  outlines[index]->GetInterpolatedSplinePoint(t);
        pts.push_back(cv::Point2f(rv.x,rv.y));
        rv_last_face=rv;
    }
        newFacepts.at(46)=pts.at(1);
        newFacepts.at(47)=pts.at(2);
        pts.clear();
    
    for(int i=0;i<66;i++){
      //  UIImageView *imagec=   [imageList objectAtIndex:i];
        CGFloat x = newFacepts.at(i).x*xscale;
        CGFloat y = newFacepts.at(i).y*yscale;
        circle(sourceMat, cv::Point2f(x,y), 5, Scalar(255,0,0),-1);
      }
    imageView.image=[UIImageCVMatConverter UIImageFromCVMat:sourceMat];
}
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
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
