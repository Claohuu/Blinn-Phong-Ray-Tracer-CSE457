
# CSE 457 – Project 3: Tracer

A Blinn-Phong shader and recursive ray tracer implementing direct lighting, reflection, and refraction, built for the University of Washington's CSE 457 (Computer Graphics) course.

## Acknowledgments

Built for CSE 457 at the University of Washington. This repo contains the full Unity project as provided by course staff (skeleton scenes, the acceleration structure `BVH.cs`, the image comparison / grading tool `ImageComparison.cs`, sample solution renders, etc.). The code I actually wrote is limited to two files: `Assets/Shaders/BlinnPhong.cginc` and `Assets/Scripts/RayTracing/RayTracer.cs`. Everything else was starter code.

## Blinn-Phong Shader (`BlinnPhong.cginc`)

This is my implementation of the Blinn-Phong reflection model as a Unity fragment shader (HLSL), computing per-pixel color for a point light:

$$I_{direct} = k_e + k_d I_a + \sum_j \left[ A_{shadow_j} A_{dist_j} I_{L,j} \left( k_d (N \cdot L_j)^+ + k_s (N \cdot H_j)^{n_s^+} \right) \right]$$

I implemented:

- **Distance attenuation** — `1 / (1 + r²)` for each point light, so intensity falls off smoothly with distance instead of the harsh, unattenuated falloff in the starter code.
- **Ambient component** — `k_d * I_a`, using Unity's environment lighting.
- **Specular component** — the Blinn-Phong half-vector term `k_s (N · H)^ns`, using the halfway vector between the view and light directions rather than the full mirror-reflection vector (cheaper, and avoids some artifacts of pure Phong specular).

## Ray Tracer (`RayTracer.cs`)

This is my implementation of `TraceRay()`, a recursive ray tracer that computes color as a sum of three components:

$$I_{total} = I_{direct} + k_s I_{reflection} + k_t I_{refraction}$$

**Direct lighting** — the same Blinn-Phong sum as above, computed per light source, plus:
- Shadow rays cast toward each light, with "thin shell" color filtering so light passing through a transparent object picks up that object's color rather than just being fully blocked or fully passed.

**Reflection** — computed the reflection direction

$$R = 2(V \cdot N)N - V$$

and recursively traced a new ray from the intersection point in that direction, up to `MaxRecursionDepth`.

**Refraction** — computed the refracted ray direction using Snell's law:

$$\eta = \eta_i / \eta_t, \quad \cos\theta_i = N \cdot V, \quad \cos\theta_t = \sqrt{1 - \eta^2(1 - \cos^2\theta_i)}$$
$$T = (\eta \cos\theta_i - \cos\theta_t)N - \eta V$$

and handled **total internal reflection** — when the term under the square root goes negative, the ray reflects instead of refracting, rather than producing a NaN/garbage direction.

Both reflection and refraction recurse back into `TraceRay()`, so a ray can bounce and bend through multiple surfaces (e.g. a reflective sphere behind a refractive cube) before terminating.

## Verifying correctness

I tested against the provided `ImageComparison` tool (not written by me), which renders my output against the solution's, marking pixel-level differences with a diff overlay. My implementation passed the direct-lighting, reflection, and refraction test scenes at >95% pixel match.
