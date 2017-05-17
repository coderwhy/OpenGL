attribute vec4 Position;
attribute vec2 TexCoordIn;

varying vec2 TexCoordOut;

void main(void) {
    gl_Position = Position;
    TexCoordOut = TexCoordIn; 
}
