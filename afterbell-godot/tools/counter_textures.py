#!/usr/bin/env python3
"""Adapt the user's original texture images to the counter: ivory top, plum cabinet, brass trim.

    python3 tools/counter_textures.py

Reads the untouched originals in assets/textures/source/ and writes edited copies as texture sets
(albedo, normal, roughness) to assets/textures/counter_ivory, counter_plum and counter_brass.
Each keeps its source's character (marble veins, plum grain, brushed streaks) but is quietened:
fine speckle is smoothed away, larger detail is kept at reduced contrast, the colour is moved to
the reference palette, and the roughness is set for a satin, mostly matte finish.
"""
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from make_texture import SIZE, blur_wrap, make_seamless, normal_map  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "textures")

# name: (source, target mean colour, detail kept, speckle blur, normal strength, roughness, roughness spread)
SETS = {
    "counter_ivory": ("marble_ivory_original.webp", (236, 227, 209), 0.5, 2, 1.5, 0.4, 0.08),
    "counter_plum": ("plum_original.webp", (92, 35, 65), 0.45, 2, 1.0, 0.56, 0.05),
    "counter_brass": ("brass_brushed_original.webp", (196, 168, 106), 0.55, 1, 1.2, 0.4, 0.06),
}


def adapt(source, target, keep, speckle, bump, rough, spread):
    img = Image.open(os.path.join(ROOT, "source", source)).convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)
    a = make_seamless(np.asarray(img, float))
    base = np.dstack([blur_wrap(a[..., c], 24) for c in range(3)])           # broad colour and shading
    detail = np.dstack([blur_wrap(a[..., c], speckle) for c in range(3)]) - base   # readable detail, speckle removed
    out = base + detail * keep
    out *= (np.array(target, float) / out.reshape(-1, 3).mean(0))[None, None]   # move to the reference colour
    out = np.clip(out, 0, 255)
    lum = out.mean(2) / 255.0
    var = lum - blur_wrap(lum, 6)
    r = np.clip(rough - var / (np.abs(var).max() + 1e-6) * spread, 0.05, 1.0)   # veins / grooves a little rougher
    return out.astype(np.uint8), normal_map(out, bump), (r * 255).astype(np.uint8)


def main():
    for name, args in SETS.items():
        albedo, normal, rough = adapt(*args)
        d = os.path.join(ROOT, name)
        os.makedirs(d, exist_ok=True)
        Image.fromarray(albedo).save(os.path.join(d, "albedo.png"))
        Image.fromarray(normal).save(os.path.join(d, "normal.png"))
        Image.fromarray(rough).save(os.path.join(d, "roughness.png"))
        print(name, albedo.reshape(-1, 3).mean(0).round(0), "roughness", round(rough.mean() / 255, 2))


if __name__ == "__main__":
    main()
