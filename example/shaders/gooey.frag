#version 300 es
#include <flutter/runtime_effect.glsl>

precision highp float;

// x, y, width, height
uniform vec4 uBounds; 
uniform float uGooiness;
uniform float uBlobCount;

// Per blob: (cx, cy, half_w, half_w)
uniform vec4 blob1;
uniform vec4 blob2;
uniform vec4 blob3;
uniform vec4 blob4;
uniform vec4 blob5;
uniform vec4 blob6;
uniform vec4 blob7;
uniform vec4 blob8;

// Per blob corner radii: (topLeft, topRight, bottomRight, bottomLeft)
uniform vec4 blobCornerRadius1;
uniform vec4 blobCornerRadius2;
uniform vec4 blobCornerRadius3;
uniform vec4 blobCornerRadius4;
uniform vec4 blobCornerRadius5;
uniform vec4 blobCornerRadius6;
uniform vec4 blobCornerRadius7;
uniform vec4 blobCornerRadius8;

// 0.0 = circle, 1.0 = rounded rect, 2.0 = superellipse
uniform float blobType1;
uniform float blobType2;
uniform float blobType3;
uniform float blobType4;
uniform float blobType5;
uniform float blobType6;
uniform float blobType7;
uniform float blobType8;

// Fill color (offset 60)
uniform vec4 uColor;

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

out vec4 fragColor;

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

    // Anti-aliasing factor
    float aa = fwidth(d);

    // Create mask with smoothstep for anti-aliasing
    float alpha = smoothstep(aa, -aa, d);

    // Use uColor for fill
    fragColor = vec4(uColor.rgb * alpha, alpha * uColor.a);
}