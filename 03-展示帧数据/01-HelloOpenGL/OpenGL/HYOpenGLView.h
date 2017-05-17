//
//  HYOpenGLView.h
//  01-HelloOpenGL
//
//  Created by apple on 17/4/29.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface HYOpenGLView : UIView

- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
