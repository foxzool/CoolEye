//
//  ViewController.m
//  CoolEye
//
//  Created by ZoOL on 13-12-31.
//  Copyright (c) 2013年 ZoOL. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
  self.videoCamera.delegate = self;
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
  self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
  self.videoCamera.defaultFPS = 30;
  self.videoCamera.grayscaleMode = NO;
  
//  self.photoCamera = [[CvPhotoCamera alloc] initWithParentView:_imageView];
//  self.photoCamera.delegate = self;
//  self.photoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
//  self.photoCamera.defaultAVCaptureSessionPreset  = AVCaptureSessionPreset640x480;
//  self.photoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//  self.photoCamera.defaultFPS = 30;

  [self.lblText setText:@"点击按钮启动"];
  
  self.demoJPG = [UIImage imageNamed:@"demo.jpg"];
  
  self.isIT = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionStart:(id)sender {
  [self.lblText setText:@"识别中...."];
  self.isIT = false;
  self.hfcount = 0;
  self.hfcount2 = 0;
  [self.videoCamera start];
//  [self.photoCamera start];
}

- (IBAction)takePic:(id)sender {
//  [self.videoCamera stop];
  [self.photoCamera takePicture];
}


- (void)showResult:(NSString*)resultText {
  
  
}


- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image {
  NSLog(@"photo");
  
  /// 将被显示的原图像
  Mat img, templ, result;
  Mat img_display;
  img.copyTo( img_display );
  
  int match_method = 5;
  
  img = [self cvMatFromUIImage:image];
  
  templ = [self cvMatFromUIImage:[UIImage imageNamed:@"black_nike.jpg"]];
  
  
//  cvtColor(img, img, CV_RGB2BGR);
  
  /// 创建输出结果的矩阵
  int result_cols =  img.cols - templ.cols + 1;
  int result_rows = img.rows - templ.rows + 1;
  
  result.create( result_cols, result_rows, CV_32FC1 );
  
  /// 进行匹配和标准化
  matchTemplate( img, templ, result, match_method );
  normalize( result, result, 0, 1, NORM_MINMAX, -1, Mat() );
  
  /// 通过函数 minMaxLoc 定位最匹配的位置
  double minVal; double maxVal; cv::Point minLoc; cv::Point maxLoc;
  cv::Point matchLoc;
  
  minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, Mat() );
  
  /// 对于方法 SQDIFF 和 SQDIFF_NORMED, 越小的数值代表更高的匹配结果. 而对于其他方法, 数值越大匹配越好
  if( match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED )
  { matchLoc = minLoc; }
  else
  { matchLoc = maxLoc; }
  
  /// 让我看看您的最终结果
  rectangle( img_display, matchLoc, cv::Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar::all(0), 2, 8, 0 );
  rectangle( result, matchLoc, cv::Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar::all(0), 2, 8, 0 );

  
  
  
}

- (void)photoCameraCancel:(CvPhotoCamera *)photoCamera {
  NSLog(@"cancel");
}


/**
 *  摄像头处理
 *
 *  @param image mat image
 */
- (void)processImage:(Mat&)image {
  
  if (self.isIT) {
    [self.videoCamera stop];
    return;
  }
  
  
  
  
  Mat src_base, hsv_base;
  Mat hsv_test1;
  Mat src_test2, hsv_test2;
  Mat hsv_half_down;
  
  
  Mat src, dst;
  src = image;
  

  
  
  IplImage ipl_img = image;
  Mat src_test1;
  cvSetImageROI(&ipl_img, cv::Rect(40, 40, 400, 400));
  
  rectangle(image, cv::Point(40, 40),cv::Point(440, 440),Scalar(0,0,0));
  
  src_base = &ipl_img;
  src_test1 = [self cvMatFromUIImage:[UIImage imageNamed:@"black_nike.png"]];
  src_test2 = [self cvMatFromUIImage:[UIImage imageNamed:@"twitter.jpg"]];
  
  
  /// 分割成3个单通道图像 ( R, G 和 B )
  vector<Mat> rgb_planes;
  split( src, rgb_planes );
  
  vector<Mat> rgb_planes1;
  split( src_test1, rgb_planes1 );
  
  vector<Mat> rgb_planes2;
  split( src_test2, rgb_planes2 );
  
  cvtColor(src_base, src_base, CV_RGB2BGR);
  cvtColor(src_test1, src_test1, CV_RGB2BGR);
  cvtColor(src_test2, src_test2, CV_RGB2BGR);
  
  //增强直方图
//  cvtColor(src_base, src_base, CV_BGR2GRAY);
//  cvtColor(src_test1, src_test1, CV_BGR2GRAY);
//  cvtColor(src_test2, src_test2, CV_BGR2GRAY);
//  
//  equalizeHist( src_base, src_base );
//  equalizeHist( src_test1, src_test1 );
//  equalizeHist( src_test2, src_test2 );
//  
//  cvtColor(src_base, src_base, CV_GRAY2BGR);
//  cvtColor(src_test1, src_test1, CV_GRAY2BGR);
//  cvtColor(src_test2, src_test2, CV_GRAY2BGR);
//
  /// 转换到 HSV
  cvtColor( src_base, hsv_base, CV_BGR2HSV );
  cvtColor( src_test1, hsv_test1, CV_BGR2HSV );
  cvtColor( src_test2, hsv_test2, CV_BGR2HSV );
  
//  hsv_half_down = hsv_base( Range( hsv_base.rows/2, hsv_base.rows - 1 ), Range( 0, hsv_base.cols - 1 ) );
  
  /// 对hue通道使用30个bin,对saturatoin通道使用32个bin
  int h_bins = 50; int s_bins = 60;
  int histSize[] = { h_bins, s_bins };
  
  // hue的取值范围从0到256, saturation取值范围从0到180
  float h_ranges[] = { 0, 256 };
  float s_ranges[] = { 0, 180 };
  
  const float* ranges[] = { h_ranges, s_ranges };
  
  // 使用第0和第1通道
  int channels[] = { 0, 1 };
  
  /// 直方图
  MatND hist_base;
//  MatND hist_half_down;
  MatND hist_test1;
  MatND hist_test2;
  
  /// 计算HSV图像的直方图
  calcHist( &hsv_base, 1, channels, Mat(), hist_base, 2, histSize, ranges, true, false );
  normalize( hist_base, hist_base, 0, 1, NORM_MINMAX, -1, Mat() );
  
//  calcHist( &hsv_half_down, 1, channels, Mat(), hist_half_down, 2, histSize, ranges, true, false );
//  normalize( hist_half_down, hist_half_down, 0, 1, NORM_MINMAX, -1, Mat() );
  
  calcHist( &hsv_test1, 1, channels, Mat(), hist_test1, 2, histSize, ranges, true, false );
  normalize( hist_test1, hist_test1, 0, 1, NORM_MINMAX, -1, Mat() );
  
  calcHist( &hsv_test2, 1, channels, Mat(), hist_test2, 2, histSize, ranges, true, false );
  normalize( hist_test2, hist_test2, 0, 1, NORM_MINMAX, -1, Mat() );
 
  ///应用不同的直方图对比方法
  for( int i = 0; i < 4; i++ )
  { int compare_method = i;
    double base_base = compareHist( hist_base, hist_base, compare_method );
//    double base_half = compareHist( hist_base, hist_half_down, compare_method );
    double base_test1 = compareHist( hist_base, hist_test1, compare_method );
    double base_test2 = compareHist( hist_base, hist_test2, compare_method );
    
    printf( " Method [%d] Perfect, Base-Test(1), Base-Test(2) : %f, %f, %f \n", i, base_base , base_test1, base_test2 );
    
    if (i == 0) {
    
    if (base_test1 > 0.3) {
      self.hfcount += 1;
    } else {
      self.hfcount = 0;
    }
      
      if (base_test2 > 0.2) {
        self.hfcount2 += 1;
      } else {
        self.hfcount2 = 0;
      }
    
      
      dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithFormat:@"识别中.... %d, %d", self.hfcount, self.hfcount2];
        [self.lblText setText:str];
      });
      
    if (self.hfcount >= 30 * 1) {
      
//      [self.imageView setImage:[self UIImageFromCVMat:image]];
      
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.lblText setText:@"这是NIKE"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"识别结果" message:@"nike" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
      });
//      image = [self cvMatFromUIImage:[UIImage imageNamed:@"demo.jpg"]];
//      [self.videoCamera stop];
      self.isIT = true;
      
      CvSize sz;
      double scale = 0.25;
      IplImage src = src_base;
      sz.width = src.width*scale;
      sz.height = src.height*scale;
      
      IplImage desc = *cvCreateImage(sz,src.depth,src.nChannels);
      cvResize(&src,&desc,CV_INTER_CUBIC);
      
      Mat demo = [self cvMatFromUIImage:[UIImage imageNamed:@"demo.jpg"]];
      cvtColor(demo, demo, CV_RGB2BGR);
      cv::Rect roi(cv::Point(140, 240), cv::Size(100, 100));
      Mat destROI = demo(roi);
      Mat src2 = &desc;
      src2.copyTo(destROI);
      image = demo;
      
      
    }
      
      
      if (self.hfcount2 >= 30 * 1) {
        
        //      [self.imageView setImage:[self UIImageFromCVMat:image]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.lblText setText:@"这是TWITTER"];
          
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"识别结果" message:@"twitter" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
          
          [alert show];
          
        });
        //      image = [self cvMatFromUIImage:[UIImage imageNamed:@"demo.jpg"]];
        //      [self.videoCamera stop];
        self.isIT = true;
        CvSize sz;
        double scale = 0.25;
        IplImage src = src_base;
        sz.width = src.width*scale;
        sz.height = src.height*scale;
        
        IplImage desc = *cvCreateImage(sz,src.depth,src.nChannels);
        cvResize(&src,&desc,CV_INTER_CUBIC);
        
        Mat demo = [self cvMatFromUIImage:[UIImage imageNamed:@"demo2.png"]];
        cvtColor(demo, demo, CV_RGB2BGR);
        cv::Rect roi(cv::Point(140, 240), cv::Size(100, 100));
        Mat destROI = demo(roi);
        Mat src2 = &desc;
        src2.copyTo(destROI);
        image = demo;
        
      }
      
      
    }
    
  }
//  [self.imageView setImage:[UIImage imageNamed:@"demo.jpg"]];
  printf("count %d, %d\n " , self.hfcount, self.hfcount2);
  printf( "Done \n" );

  
  
//  /// 设定bin数目
//  int histSize2 = 255;
//  
//  /// 设定取值范围 ( R,G,B) )
//  float range[] = { 0, 255 } ;
//  const float* histRange = { range };
//  
//  bool uniform = true; bool accumulate = false;
//  
//  Mat r_hist, g_hist, b_hist;
//  Mat r_hist1, g_hist1, b_hist1;
//  Mat r_hist2, g_hist2, b_hist2;
//  
//  /// 计算直方图:
//  calcHist( &rgb_planes[0], 1, 0, Mat(), r_hist, 1, &histSize2, &histRange, uniform, accumulate );
//  calcHist( &rgb_planes[1], 1, 0, Mat(), g_hist, 1, &histSize2, &histRange, uniform, accumulate );
//  calcHist( &rgb_planes[2], 1, 0, Mat(), b_hist, 1, &histSize2, &histRange, uniform, accumulate );
//  
//  calcHist( &rgb_planes1[0], 1, 0, Mat(), r_hist1, 1, &histSize2, &histRange, uniform, accumulate );
//  calcHist( &rgb_planes1[1], 1, 0, Mat(), g_hist1, 1, &histSize2, &histRange, uniform, accumulate );
//  calcHist( &rgb_planes1[2], 1, 0, Mat(), b_hist1, 1, &histSize2, &histRange, uniform, accumulate );
//
//  calcHist( &rgb_planes2[0], 1, 0, Mat(), r_hist2, 1, &histSize2, &histRange, uniform, accumulate );
//  calcHist( &rgb_planes2[1], 1, 0, Mat(), g_hist2, 1, &histSize2, &histRange, uniform, accumulate );
//  calcHist( &rgb_planes2[2], 1, 0, Mat(), b_hist2, 1, &histSize2, &histRange, uniform, accumulate );
//
//  
//  // 创建直方图画布
//  int hist_w = 400; int hist_h = 400;
//  int bin_w = cvRound( (double) hist_w/histSize2 );
//  
//  Mat histImage( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );
//  
//  Mat histImage1( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );
//  
//  Mat histImage2( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );
//  
//  /// 将直方图归一化到范围 [ 0, histImage.rows ]
//  normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
//  normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
//  normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
//  
//  normalize(r_hist1, r_hist1, 0, histImage1.rows, NORM_MINMAX, -1, Mat() );
//  normalize(g_hist1, g_hist1, 0, histImage1.rows, NORM_MINMAX, -1, Mat() );
//  normalize(b_hist1, b_hist1, 0, histImage1.rows, NORM_MINMAX, -1, Mat() );
//  
//  normalize(r_hist2, r_hist2, 0, histImage2.rows, NORM_MINMAX, -1, Mat() );
//  normalize(g_hist2, g_hist2, 0, histImage2.rows, NORM_MINMAX, -1, Mat() );
//  normalize(b_hist2, b_hist2, 0, histImage2.rows, NORM_MINMAX, -1, Mat() );
//  
//  /// 在直方图画布上画出直方图
//  for( int i = 1; i < histSize2; i++ )
//  {
//    line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(r_hist.at<float>(i)) ),
//         Scalar( 0, 0, 255), 2, 8, 0  );
//    line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(g_hist.at<float>(i)) ),
//         Scalar( 0, 255, 0), 2, 8, 0  );
//    line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(b_hist.at<float>(i)) ),
//         Scalar( 255, 0, 0), 2, 8, 0  );
//    
//    line( histImage1, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist1.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(r_hist1.at<float>(i)) ),
//         Scalar( 0, 0, 255), 2, 8, 0  );
//    line( histImage1, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist1.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(g_hist1.at<float>(i)) ),
//         Scalar( 0, 255, 0), 2, 8, 0  );
//    line( histImage1, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist1.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(b_hist1.at<float>(i)) ),
//         Scalar( 255, 0, 0), 2, 8, 0  );
//    
//    line( histImage2, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist2.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(r_hist2.at<float>(i)) ),
//         Scalar( 0, 0, 255), 2, 8, 0  );
//    line( histImage2, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist2.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(g_hist2.at<float>(i)) ),
//         Scalar( 0, 255, 0), 2, 8, 0  );
//    line( histImage2, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist2.at<float>(i-1)) ) ,
//         cv::Point( bin_w*(i), hist_h - cvRound(b_hist2.at<float>(i)) ),
//         Scalar( 255, 0, 0), 2, 8, 0  );
//  }
//  
//  
//  
//  
//  
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [self.hist1View setImage:[self UIImageFromCVMat:histImage]];
//        [self.hist2View setImage:[self UIImageFromCVMat:histImage1]];
//        [self.hist3View setImage:[self UIImageFromCVMat:histImage2]];
//  });
//  
  
  
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  
  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
  
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                  cols,                       // Width of bitmap
                                                  rows,                       // Height of bitmap
                                                  8,                          // Bits per component
                                                  cvMat.step[0],              // Bytes per row
                                                  colorSpace,                 // Colorspace
                                                  kCGImageAlphaNoneSkipLast |
                                                  kCGBitmapByteOrderDefault); // Bitmap info flags
  
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  
  return cvMat;
}
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  
  cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
  
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                  cols,                       // Width of bitmap
                                                  rows,                       // Height of bitmap
                                                  8,                          // Bits per component
                                                  cvMat.step[0],              // Bytes per row
                                                  colorSpace,                 // Colorspace
                                                  kCGImageAlphaNoneSkipLast |
                                                  kCGBitmapByteOrderDefault); // Bitmap info flags
  
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
  
  return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
  NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  CGColorSpaceRef colorSpace;
  
  if (cvMat.elemSize() == 1) {
    colorSpace = CGColorSpaceCreateDeviceGray();
  } else {
    colorSpace = CGColorSpaceCreateDeviceRGB();
  }
  
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  
  // Creating CGImage from cv::Mat
  CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                      cvMat.rows,                                 //height
                                      8,                                          //bits per component
                                      8 * cvMat.elemSize(),                       //bits per pixel
                                      cvMat.step[0],                            //bytesPerRow
                                      colorSpace,                                 //colorspace
                                      kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                      provider,                                   //CGDataProviderRef
                                      NULL,                                       //decode
                                      false,                                      //should interpolate
                                      kCGRenderingIntentDefault                   //intent
                                      );
  
  
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  
  return finalImage;
}


@end
