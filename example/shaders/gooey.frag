#version 300 es
#include <flutter/runtime_effect.glsl>

precision highp float;

// x, y, width, height
layout(location = 0) uniform vec4 uBounds; 
// x: gooiness, y: blobCount, z: borderWidth, w: fillType (0=solid, 1=linear, 2=radial)
layout(location = 1) uniform vec4 uParams;

// Fill colors
layout(location = 2) uniform vec4 uColor;
layout(location = 3) uniform vec4 uColor2;
layout(location = 4) uniform vec4 uColor3;

// Border color
layout(location = 5) uniform vec4 uBorderColor;

// Gradient params: x: startX, y: startY, z: endX, w: endY (linear) or focalX, focalY, radius, unused (radial)
layout(location = 6) uniform vec4 uGradientParams;

// Per blob: (cx, cy, half_w, half_w)
layout(location = 7) uniform vec4 blob1;
layout(location = 8) uniform vec4 blob2;
layout(location = 9) uniform vec4 blob3;
layout(location = 10) uniform vec4 blob4;
layout(location = 11) uniform vec4 blob5;
layout(location = 12) uniform vec4 blob6;
layout(location = 13) uniform vec4 blob7;
layout(location = 14) uniform vec4 blob8;
layout(location = 15) uniform vec4 blob9;
layout(location = 16) uniform vec4 blob10;

// Per blob: x: borderRadius, y: type, z: cutout (0=false, 1=true), w: unused
layout(location = 17) uniform vec4 blobParams1;
layout(location = 18) uniform vec4 blobParams2;
layout(location = 19) uniform vec4 blobParams3;
layout(location = 20) uniform vec4 blobParams4;
layout(location = 21) uniform vec4 blobParams5;
layout(location = 22) uniform vec4 blobParams6;
layout(location = 23) uniform vec4 blobParams7;
layout(location = 24) uniform vec4 blobParams8;
layout(location = 25) uniform vec4 blobParams9;
layout(location = 26) uniform vec4 blobParams10;

// getFill determines the fill color based on the fill type and gradient parameters
vec4 getFill(vec2 p, float fillCode, vec4 color, vec4 color2, vec4 color3, vec4 gradientParams) {
    // 0 = solid
    // 1 = linear, 2 colors
    // 2 = linear, 3 colors
    // 3 = radial, 2 colors
    // 4 = radial, 3 colors

    if (fillCode < 0.5) {
        return color;
    }

    bool isLinear = fillCode < 2.5;
   bool twoColors = mod(fillCode, 2.0) > 0.5;

    float t;
    if (isLinear) {
        vec2 start = gradientParams.xy;
        vec2 end = gradientParams.zw;
        vec2 dir = end - start;
        t = clamp(dot(p - start, dir) / dot(dir, dir), 0.0, 1.0);
    } else {
        vec2 center = gradientParams.xy;
        float radius = gradientParams.z;
        t = clamp(length(p - center) / radius, 0.0, 1.0);
    }

    if (twoColors) {
        return mix(color, color2, t);
    } else {
        if (t < 0.5) {
            return mix(color, color2, t * 2.0);
        } else {
            return mix(color2, color3, (t - 0.5) * 2.0);
        }
    }
}

// Signed distance function for adding a circle, 
float sdCircle(vec2 p, vec2 c, float r) {
    return length(p - c) - r;
}

// Signed distance function for adding a rounded rectangle, with border radius 'r'
float sdRoundRect(vec2 p, vec2 c, vec2 b, float r) {
    vec2 d = p - c;
    r = min(r, min(b.x, b.y));
    vec2 q = abs(d) - (b - r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

// additional smooth operations for blending blobs
float smoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Smooth subtraction for cutout blobs
float smoothSubtract(float base, float sub, float k) {
    float h = clamp(0.5 - 0.5 * (base + sub) / k, 0.0, 1.0);
    return mix(base, -sub, h) + k * h * (1.0 - h);
}

// Evaluates the distance for a single blob based on its type and parameters
float evalBlob(vec2 p, vec4 b, vec4 params) {
    vec2 c = b.xy;
    float type = params.y;
    float borderRadius = params.x;
    if (type < 0.5) {
        return sdCircle(p, c, b.z);
    } else {
        return sdRoundRect(p, c, b.zw, borderRadius);
    }
}

// Accumulates a blob into the existing distance field 'd' using either union or subtraction based on the cutout parameter
float accumulateBlob(float d, vec2 p, vec4 b, vec4 params, float k) {
    float bd = evalBlob(p, b, params);
    if (params.z > 0.5) {
        float h = clamp(0.5 - 0.5 * (d + bd) / k, 0.0, 1.0);
        return mix(d, -bd, h) + k * h * (1.0 - h);
    }
    float h = clamp(0.5 + 0.5 * (bd - d) / k, 0.0, 1.0);
    return mix(bd, d, h) - k * h * (1.0 - h);
}

layout(location = 0) out vec4 fragColor;

void main() {
    // normalized pixel coordinates 
    vec2 pos = (FlutterFragCoord().xy - uBounds.xy);
    vec2 p = pos / uBounds.z;

    // We assume uParams.y is at least 1.0
    float d = evalBlob(p, blob1, blobParams1);
    
    // 3. Conditional accumulation
    // Using an unrolled loop style that allows the compiler to optimize
    if (uParams.y >= 2.0) d = accumulateBlob(d, p, blob2, blobParams2, uParams.x);
    if (uParams.y >= 3.0) d = accumulateBlob(d, p, blob3, blobParams3, uParams.x);
    if (uParams.y >= 4.0) d = accumulateBlob(d, p, blob4, blobParams4, uParams.x);
    if (uParams.y >= 5.0) d = accumulateBlob(d, p, blob5, blobParams5, uParams.x);
    if (uParams.y >= 6.0) d = accumulateBlob(d, p, blob6, blobParams6, uParams.x);
    if (uParams.y >= 7.0) d = accumulateBlob(d, p, blob7, blobParams7, uParams.x);
    if (uParams.y >= 8.0) d = accumulateBlob(d, p, blob8, blobParams8, uParams.x);
    if (uParams.y >= 9.0) d = accumulateBlob(d, p, blob9, blobParams9, uParams.x);
    if (uParams.y >= 10.0) d = accumulateBlob(d, p, blob10, blobParams10, uParams.x);

    float aa = 0.001;
    // Combine smoothsteps into a single calculation area
    float outer = smoothstep(aa, -aa, d);
    float inner = smoothstep(aa, -aa, d + uParams.z);

    // We can calculate the factor once to avoid multiple vec4 multiplications
    float borderMask = clamp(outer - inner, 0.0, 1.0);
    
    // mix() is often hardware-accelerated and cleaner than manual addition
    vec4 fillColor = getFill(p, uParams.w, uColor, uColor2, uColor3, uGradientParams);
    vec4 color = mix(vec4(0.0), uBorderColor, borderMask);
    color = mix(color, fillColor, inner);

    fragColor = color;
}