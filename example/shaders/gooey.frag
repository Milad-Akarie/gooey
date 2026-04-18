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

    float r = d.x < 0.0
        ? (d.y < 0.0 ? cr.x : cr.w)
        : (d.y < 0.0 ? cr.y : cr.z);
    r = min(r, min(b.x, b.y));

    // r=0 → plain rectangle
    if (r < 1e-4) {
        vec2 q = abs(d) - b;
        return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
    }

    float maxR = min(b.x, b.y);
    float t = clamp(r / maxR, 0.0, 1.0);
    float n = mix(8.0, 2.0, t);

    // ... rest of Newton iteration
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
   vec2 p = (FlutterFragCoord().xy - uBounds.xy) / uBounds.z;

    const float INACTIVE = 1e9;

    float d1 = uBlobCount >= 1.0 ? evalBlob(p, blob1, blobCornerRadius1, blobType1) : INACTIVE;
    float d2 = uBlobCount >= 2.0 ? evalBlob(p, blob2, blobCornerRadius2, blobType2) : INACTIVE;
    float d3 = uBlobCount >= 3.0 ? evalBlob(p, blob3, blobCornerRadius3, blobType3) : INACTIVE;
    float d4 = uBlobCount >= 4.0 ? evalBlob(p, blob4, blobCornerRadius4, blobType4) : INACTIVE;
    float d5 = uBlobCount >= 5.0 ? evalBlob(p, blob5, blobCornerRadius5, blobType5) : INACTIVE;
    float d6 = uBlobCount >= 6.0 ? evalBlob(p, blob6, blobCornerRadius6, blobType6) : INACTIVE;
    float d7 = uBlobCount >= 7.0 ? evalBlob(p, blob7, blobCornerRadius7, blobType7) : INACTIVE;
    float d8 = uBlobCount >= 8.0 ? evalBlob(p, blob8, blobCornerRadius8, blobType8) : INACTIVE;

    float d = d1;
    d = smoothUnion(d, d2, uGooiness);
    d = smoothUnion(d, d3, uGooiness);
    d = smoothUnion(d, d4, uGooiness);
    d = smoothUnion(d, d5, uGooiness);
    d = smoothUnion(d, d6, uGooiness);
    d = smoothUnion(d, d7, uGooiness);
    d = smoothUnion(d, d8, uGooiness);

    float aa = fwidth(d);

    float outer = smoothstep(aa, -aa, d);
    float inner = smoothstep(aa, -aa, d + uBorderWidth);

    float borderMask = outer * (1.0 - inner);
    float fillMask   = inner;

    vec4 fill   = vec4(uColor.rgb, uColor.a) * fillMask;
    vec4 border = vec4(uBorderColor.rgb, uBorderColor.a) * borderMask;

    fragColor = fill + border;
}