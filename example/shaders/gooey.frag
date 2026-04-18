#version 300 es
#include <flutter/runtime_effect.glsl>

precision highp float;

// x, y, width, height
layout(location = 0) uniform vec4 uBounds; 
layout(location = 1) uniform float uGooiness;
layout(location = 2) uniform float uBlobCount;

// Per blob: (cx, cy, half_w, half_w)
layout(location = 3) uniform vec4 blob1;
layout(location = 4) uniform vec4 blob2;
layout(location = 5) uniform vec4 blob3;
layout(location = 6) uniform vec4 blob4;
layout(location = 7) uniform vec4 blob5;
layout(location = 8) uniform vec4 blob6;
layout(location = 9) uniform vec4 blob7;
layout(location = 10) uniform vec4 blob8;

// Per blob corner radii: (topLeft, topRight, bottomRight, bottomLeft)
layout(location = 11) uniform vec4 blobCornerRadius1;
layout(location = 12) uniform vec4 blobCornerRadius2;
layout(location = 13) uniform vec4 blobCornerRadius3;
layout(location = 14) uniform vec4 blobCornerRadius4;
layout(location = 15) uniform vec4 blobCornerRadius5;
layout(location = 16) uniform vec4 blobCornerRadius6;
layout(location = 17) uniform vec4 blobCornerRadius7;
layout(location = 18) uniform vec4 blobCornerRadius8;

// 0.0 = circle, 1.0 = rounded rect, 2.0 = superellipse
layout(location = 19) uniform float blobType1;
layout(location = 20) uniform float blobType2;
layout(location = 21) uniform float blobType3;
layout(location = 22) uniform float blobType4;
layout(location = 23) uniform float blobType5;
layout(location = 24) uniform float blobType6;
layout(location = 25) uniform float blobType7;
layout(location = 26) uniform float blobType8;

// Fill color (offset 78)
layout(location = 27) uniform vec4 uColor;

// Border width and color (offset 82)
layout(location = 28) uniform float uBorderWidth;
layout(location = 29) uniform vec4 uBorderColor;

// ----------------------------
// Distance functions
// ----------------------------

float sdCircle(vec2 p, vec2 c, float r) {
    return length(p - c) - r;
}

float sdRoundRect(vec2 p, vec2 c, vec2 b, vec4 cr) {
    vec2 d = p - c;
    float r = d.x < 0.0
        ? (d.y < 0.0 ? cr.x : cr.w)
        : (d.y < 0.0 ? cr.y : cr.z);
    r = min(r, min(b.x, b.y)); // clamp r to fit within the shape
    vec2 q = abs(d) - (b - r);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float sdRSuperellipse(vec2 p, vec2 c, vec2 b, vec4 cr) {
    vec2 d = p - c;
    
    // Determine corner radius based on quadrant
    float r = (d.x < 0.0) ? (d.y < 0.0 ? cr.x : cr.w) : (d.y < 0.0 ? cr.y : cr.z);
    r = min(r, min(b.x, b.y));

    if (r < 0.0001) {
        vec2 q = abs(d) - b;
        return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
    }

    float maxR = min(b.x, b.y);
    float t = clamp(r / maxR, 0.0, 1.0);
    float n = mix(8.0, 2.0, t);
    
    // You were missing the actual math return here!
    // Standard superellipse distance approximation:
    vec2 q = abs(d) - (b - r);
    return pow(pow(max(q.x, 0.0), n) + pow(max(q.y, 0.0), n), 1.0/n) - r;
}
// ----------------------------
// Smooth union
// ----------------------------

float smoothUnion(float d1, float d2, float k) {
    float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
    return mix(d2, d1, h) - k * h * (1.0 - h);
}

// ----------------------------
// Blob evaluation
// ----------------------------

float evalBlob(vec2 p, vec4 b, vec4 cornerRadius, float type) {
    vec2 c = b.xy;
    if (type < 0.5) {
        return sdCircle(p, c, b.z);
    } else if (type < 1.5) {
        return sdRoundRect(p, c, b.zw, cornerRadius);
    } else {
        return sdRSuperellipse(p, c, b.zw, cornerRadius);
    }
}

// ----------------------------
// Main
// ----------------------------

layout(location = 0) out vec4 fragColor;

void main() {
  
    vec2 pos = (FlutterFragCoord().xy - uBounds.xy);
    // 1. Normalize coordinates
    #ifdef IMPELLER_TARGET_OPENGLES
       pos.y = uBounds.w - pos.y;
    #endif

    vec2 p = pos / uBounds.z;

    // 2. Initialize d with the first blob to avoid smoothUnion with "INACTIVE"
    // We assume uBlobCount is at least 1.0
    float d = evalBlob(p, blob1, blobCornerRadius1, blobType1);
     
    // 3. Conditional accumulation
    // Using an unrolled loop style that allows the compiler to optimize
    if (uBlobCount >= 2.0) d = smoothUnion(d, evalBlob(p, blob2, blobCornerRadius2, blobType2), uGooiness);
    if (uBlobCount >= 3.0) d = smoothUnion(d, evalBlob(p, blob3, blobCornerRadius3, blobType3), uGooiness);
    if (uBlobCount >= 4.0) d = smoothUnion(d, evalBlob(p, blob4, blobCornerRadius4, blobType4), uGooiness);
    if (uBlobCount >= 5.0) d = smoothUnion(d, evalBlob(p, blob5, blobCornerRadius5, blobType5), uGooiness);
    if (uBlobCount >= 6.0) d = smoothUnion(d, evalBlob(p, blob6, blobCornerRadius6, blobType6), uGooiness);
    if (uBlobCount >= 7.0) d = smoothUnion(d, evalBlob(p, blob7, blobCornerRadius7, blobType7), uGooiness);
    if (uBlobCount >= 8.0) d = smoothUnion(d, evalBlob(p, blob8, blobCornerRadius8, blobType8), uGooiness);

    float aa = 0.001;
    // Combine smoothsteps into a single calculation area
    float outer = smoothstep(aa, -aa, d);
    float inner = smoothstep(aa, -aa, d + uBorderWidth);

    // 5. Optimized Blending
    // We can calculate the factor once to avoid multiple vec4 multiplications
    float borderMask = clamp(outer - inner, 0.0, 1.0);
    
    // mix() is often hardware-accelerated and cleaner than manual addition
    vec4 color = mix(vec4(0.0), uBorderColor, borderMask);
    color = mix(color, uColor, inner);

    fragColor = color;
}