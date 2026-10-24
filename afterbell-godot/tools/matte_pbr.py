#!/usr/bin/env python3
"""Make a glTF metallic-roughness map read matte, keeping metal parts reflective.

    python3 tools/matte_pbr.py SOURCE.png OUT.png [--paint 0.72] [--metal 0.3]

glTF packs roughness in green and metallic in blue. Non-metal pixels get their roughness raised
to at least --paint (keeping their variation above it); metal pixels are capped at --metal so
reflections concentrate on buckles, trims and blades.
"""
import argparse

import numpy as np
from PIL import Image

p = argparse.ArgumentParser()
p.add_argument("source")
p.add_argument("out")
p.add_argument("--paint", type=float, default=0.72)
p.add_argument("--metal", type=float, default=0.3)
args = p.parse_args()

a = np.asarray(Image.open(args.source).convert("RGB")).astype(float) / 255.0
rough, metal = a[..., 1], a[..., 2]
is_metal = np.clip((metal - 0.3) / 0.4, 0.0, 1.0)
matte = args.paint + rough * (1.0 - args.paint) * 0.5       # floor at --paint, keep some variation
shiny = np.minimum(rough, args.metal)
a[..., 1] = matte * (1.0 - is_metal) + shiny * is_metal
Image.fromarray((a * 255.0 + 0.5).astype(np.uint8), "RGB").save(args.out)
print(f"{args.out}: {(is_metal > 0.5).mean() * 100:.1f}% metal kept glossy, the rest matte")
