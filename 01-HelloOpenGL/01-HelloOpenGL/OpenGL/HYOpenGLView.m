//
//  HYOpenGLView.m
//  01-HelloOpenGL
//
//  Created by apple on 17/4/29.
//  Copyright © 2017年 apple. All rights reserved.
//
/*
 1> 将layer改成CAEAGLLayer
 2> 创建EAGLContext上下文
 */

#import "HYOpenGLView.h"
#import <OpenGLES/ES2/gl.h>

@implementation HYOpenGLView

// 1> 将HYOpenGLView的layer改成CAEAGLlayer
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

// 2> 初始化OpenGL的信息
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupOpenGL];
    }
    return self;
}

- (void)setupOpenGL {
    // 1.创建EAGLContext
    EAGLContext *glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glContext];
    CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
    
    // 在openGL中,即使是画最简单的颜色来添加, 也需要至少两个缓冲区
    // renderBuffer(渲染缓冲区, 用来存储一些图像信息)/frameBuffer(帧缓冲区, 渲染缓冲区依附于帧缓冲区才能显示内容的)
    // GLuint作为openGL所有对象的引用, 该对象指向GPU中的一块内存地址
    
    // 2.创建渲染缓存区
    GLuint renderbufferUint;
    glGenRenderbuffers(1, &renderbufferUint);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbufferUint);
    [glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];
    
    // 3.创建帧缓冲区
    GLuint framebufferUint;
    glGenFramebuffers(1, &framebufferUint);
    glBindFramebuffer(GL_FRAMEBUFFER, framebufferUint);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbufferUint);
    
    // 4.设置缓冲区的填充颜色
    glClearColor(1.0, 0.5, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 5.使用上下文, 渲染缓冲区的颜色
    [glContext presentRenderbuffer:GL_RENDERBUFFER];
}

@end
