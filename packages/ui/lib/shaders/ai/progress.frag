#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float iTime; // uTime shader playback time (in seconds)
uniform vec4 uBackgroundColor; // background color of the shape
uniform float bAnimate;

vec2 iResolution; // uResolution Represents iResolution in Shadertoy

out vec4 fragColor;


void main() {
    iResolution = uSize;
    vec2 fragCoord = FlutterFragCoord();

	vec2 p = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
    float tau = 3.1415926535*2.0;
    float a = atan(p.x,p.y);
    float r = length(p)*0.75;
    vec2 uv = vec2(a/tau,r);
	
	//get the color
	float xCol = (uv.x - (iTime / 3.0)) * 3.0;
	xCol = mod(xCol, 3.0);
	vec3 horColour = vec3(0.25, 0.25, 0.25);
	
	if (xCol < 1.0) {
		
		horColour.r += 1.0 - xCol;
		horColour.g += xCol;
	}
	else if (xCol < 2.0) {
		
		xCol -= 1.0;
		horColour.g += 1.0 - xCol;
		horColour.b += xCol;
	}
	else {
		
		xCol -= 2.0;
		horColour.b += 1.0 - xCol;
		horColour.r += xCol;
	}

	// draw color beam
	uv = (2.0 * uv) - 1.0;
	float beamWidth = abs(1.0 / (30.0 * uv.y));
    if (bAnimate == 1) beamWidth *= (0.7+0.5*cos(uv.x*10.0*tau*0.15*clamp(floor(5.0 + 10.0*cos(iTime)), 0.0, 10.0)));
	vec3 horBeam = vec3(beamWidth);
    
	// fragColor = vec4((( horBeam) * horColour), 1.0);
    vec3 combinedColor = mix(uBackgroundColor.rgb, horColour * horBeam, 0.5); // Blend with the effect
    fragColor = vec4(combinedColor, 1.0); // Apply combined color with full opacity
}
