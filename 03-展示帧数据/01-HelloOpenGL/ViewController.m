//
//  ViewController.m
//  01-HelloOpenGL
//
//  Created by apple on 17/4/29.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import "HYOpenGLView.h"
#import "VideoCapture.h"

@interface ViewController ()

@property (nonatomic, strong) VideoCapture *videoCapture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    HYOpenGLView *glView = [[HYOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
    
    self.videoCapture = [[VideoCapture alloc] init];
    [self.videoCapture startCapturing:glView];
}


@end
