#define PROCESSING_TEXTURE_SHADER

uniform mat4 transform;
uniform mat4 texMatrix;
uniform sampler2D texture;
uniform sampler2D heightMap;
uniform sampler2D waterHeightMap;

attribute vec4 vertex;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying float matID;

void main() {
    
  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);

  vec4 heightDisplacement = vec4(0,0,0,0);
  if (texture2D(heightMap, vertTexCoord.st).x >= texture2D(waterHeightMap, vertTexCoord.st).x) {
    heightDisplacement.y = texture2D(heightMap, vertTexCoord.st).x*-20.0;
    matID = 0;
  }
  else {
    heightDisplacement.y = texture2D(waterHeightMap, vertTexCoord.st).x*-20.0;
    matID = 1;
  }
  gl_Position = transform * (vertex + heightDisplacement);
}
