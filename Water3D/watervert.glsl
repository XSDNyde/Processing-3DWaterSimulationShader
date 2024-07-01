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

void main() {
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);

  vec4 heightDisplacement = vec4(0.0, texture2D(waterHeightMap, vertTexCoord.st).x*-20.0, 0.0, 0.0);

  if(texture2D(heightMap, vertTexCoord.st).x >= texture2D(waterHeightMap, vertTexCoord.st).x) vertColor = vec4(0.0, 0.0, 0.0, 0.0);
  else vertColor = vec4(color.rgb, 0.8);

  vertColor *= mix(vec4(1.0, 1.0, 1.0, 0.8), vec4(0.2, 0.4, 0.8, 2.2), texture2D(waterHeightMap, vertTexCoord.st).x);

  vertTexCoord = texMatrix * vec4(mod((texCoord.x*4.0),1.0), texCoord.y, 1.0, 1.0);
  gl_Position = transform * (vertex + heightDisplacement);
}
