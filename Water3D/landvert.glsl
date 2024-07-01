#define PROCESSING_TEXTURE_SHADER

uniform mat4 transform;
uniform mat4 texMatrix;
uniform sampler2D texture;
uniform sampler2D heightMap;

attribute vec4 vertex;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
    
  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);

  vec4 heightDisplacement = vec4(0.0, texture2D(heightMap, vertTexCoord.st).x*-20.0, 0.0, 0.0);
  vertTexCoord = texMatrix * vec4(mod((texCoord.x*4.0),1.0), texCoord.y, 1.0, 1.0);
  gl_Position = transform * (vertex + heightDisplacement);
}
