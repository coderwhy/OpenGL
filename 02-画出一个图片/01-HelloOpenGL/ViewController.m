//
//  ViewController.m
//  01-HelloOpenGL
//
//  Created by apple on 17/4/29.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import "HYOpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HYOpenGLView *glView = [[HYOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
}


@end
