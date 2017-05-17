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
    
    // OpenGL如果要绘制图片
    /*
     顶点着色器 和 片段着色器
        共同的特点
            1> 他们都运行在GPU上面的程序, openGL2.0开始被称之为可编程管线, 在OpenGL1.0的时候, 固定管线, 很多顶点着色器都是固定的, 不能任意的修改, 但是从OpenGL2.0开始, 变成可编程管线, 但是难度也突然提升了很多, 相当于我们需要在GPU上面来运行我们的程序
            2> 都是用来为GPU提供绘制图像的内容的
        顶点着色器
            1> 在openGL的世界里, 所有的图像都是以三角形的方式存在的. 为什么是三角形? 比如两个点只能组成一条线, 但是四个点就组成了无线多的面, 不能将4个顶点固定在一个平面上. 但是三角形的三个点确定下来之后, 是一定在同一个平面的. 如果想在其他平面继续画东西, 就给出其他屏幕的三角形即可
            2> 外界提供给我们即将画出的图像的所有顶点, 比如说现在要画一个长方形, 一个长方形是由两个三角形组成的, 那么就需要提供能形成两个三角形的顶点. 而顶点着色器就是接受三角形顶点的. 之后会经过各种变化, 形成新的顶点(因为就3D图像来说, 很多内容是会被上层的内容遮盖的, 那么有些顶点是没有存在的必要)
            3> 接受纹理数据, 并且对纹理数据进行转化
        片段着色器
            1> 接受变化后的顶点, 之后再根据传入的纹理数据, 生成片段, 之后根据片段给屏幕渲染对应的颜色
        如何创建着色器
            1> 需要书写glsl程序, 该程序就是运行了GPU上的程序
            2> 加载源码, 并且编译的程序
     */
    // 4.创建和编译着色器程序
    GLuint vertexShader = [self compileShader:@"VertexSource" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"FragmentSource" withType:GL_FRAGMENT_SHADER];
    
    // 5.将两个程序链接在一起使用
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
    }
    glUseProgram(programHandle);
    
    // 6.给顶点着色器传入数据
    // 6.1.传入顶点坐标数据
    GLfloat quadVertexData [] = {
        -1, -1,
        1, -1,
        -1, 1,
        1, 1,
    };
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, quadVertexData);
    glEnableVertexAttribArray(0);
    
    // 6.2.传入纹理的坐标数据
    GLfloat quadTextureData[] =  { // 正常坐标
        0, 0,
        1, 0,
        0, 1,
        1, 1
    };
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, quadTextureData);
    glEnableVertexAttribArray(1);
    
    // 7.设置片段着色器中的纹理数据
    // 7.1.获取片段着色器中的纹理属性
    GLuint textureUniform = glGetUniformLocation(programHandle, "Texture");
    
    // 7.2.绑定纹理数据
    GLuint floorTexture = [self setupTexture:@"tile_floor.png"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, floorTexture);
    
    // 7.3.将纹理传入给fragment shader中Uniform属性中
    glUniform1i(textureUniform, 0);
    
    // 8.开始绘制图像
    // 8.1.告知系统绘制的大小(绘制的是当前View的大小)
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 8.2.
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 8.3.渲染上述的内容
    [glContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1.获取shader文件的路径
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
    }
    
    // 2.根据类型, 创建对应的着色器对象
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3.加载着色器源码
    const char* shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, NULL);
    
    // 4.编译着色器
    glCompileShader(shaderHandle);
    
    // 5.查看是否编译成功, 如果没有成功, 则打印对应的错误信息
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
    }
    
    return shaderHandle;
}

- (GLuint)setupTexture:(NSString *)fileName {
    // 1.根据文件名称, 加载对应的图片
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2.获取Bitmap上下文
    // 2.1.获取图片的宽度和高度
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    // 2.2.根据图片的宽度和高度分配内存
    // *4 : 图片的每一个像素点都是由RGBA组成, 而一种颜色通道需要一个字节表示
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    // 2.3.创建BitmapContext
    // 最后一个参数是Alpha通道的位置(第一个还是最后一个)
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3.将当前的图片绘制到当前位图的上下文中
    // 3.1.绘制到当前位图上下文中
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    // 3.3.释放之前的位图
    CGContextRelease(spriteContext);
    
    // 4.生成纹理
    // 4.1.定义纹理的数字标识符(名字)
    GLuint texName;
    // 4.2.创建纹理对象
    glGenTextures(1, &texName);
    // 4.3.绑定纹理是2D还是3D
    glBindTexture(GL_TEXTURE_2D, texName);
    
    // https://learnopengl-cn.readthedocs.io/zh/latest/01%20Getting%20started/06%20Textures/
    // 4.4.设置纹理的过滤效果
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 4.5.生成对应的纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    
    return texName;
}

@end







