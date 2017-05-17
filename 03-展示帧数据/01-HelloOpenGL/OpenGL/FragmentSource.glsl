//varying lowp vec4 DestinationColor;
varying lowp vec2 TexCoordOut;

// 设置浮点型的精准度, 默认片段着色器是没有精准度的
precision mediump float;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform mat3 colorConversionMatrix;

void main(void) {
    
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = (texture2D(SamplerY, TexCoordOut).r);// - (16.0/255.0));
    yuv.yz = (texture2D(SamplerUV, TexCoordOut).ra - vec2(0.5, 0.5));
    
    rgb = colorConversionMatrix * yuv;
    
    gl_FragColor = vec4(rgb,1);
}

