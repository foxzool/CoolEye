//
//  ViewController.h
//  CoolEye
//
//  Created by ZoOL on 13-12-31.
//  Copyright (c) 2013年 ZoOL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/features2d/features2d.hpp>
#include "opencv2/imgproc/imgproc.hpp"
#include <stdio.h>
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/nonfree.hpp"
#include <iostream>

using namespace cv;

@interface ViewController : UIViewController <UIAlertViewDelegate, CvVideoCameraDelegate, CvPhotoCameraDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *hist1View;
@property (strong, nonatomic) IBOutlet UIImageView *hist2View;
@property (strong, nonatomic) IBOutlet UIImageView *hist3View;
@property (strong, nonatomic) IBOutlet UIImageView *preView;

- (IBAction)actionStart:(id)sender;
- (IBAction)takePic:(id)sender;

@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) CvPhotoCamera* photoCamera;

@property (strong, nonatomic) IBOutlet UILabel *lblText;
@property int hfcount;
@property int hfcount2;
@property (strong, nonatomic) UIImage* demoJPG;
@property int itemType;
@property  BOOL isIT;
@end
