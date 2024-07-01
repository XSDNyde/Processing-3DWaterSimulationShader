#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D waterTexture;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying float matID;

void main() {
  if(matID <= 0.95) gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  else gl_FragColor = texture2D(waterTexture, vertTexCoord.st) * vertColor;
}
