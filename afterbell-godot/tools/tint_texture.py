#!/usr/bin/env python3
"""Make a colour variant of an existing texture set, keeping its surface detail.

    python3 tools/tint_texture.py SOURCE NEW_NAME --color "#5b2a4a" [--strength 1.0]

Recolours assets/textures/SOURCE/albedo.png toward --color while keeping its light and dark
variation, and copies the normal and roughness maps. One AI texture becomes many materials.
"""
import argparse
import os
import shutil

import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "textures")

p = argparse.ArgumentParser()
p.add_argument("source")
p.add_argument("name")
p.add_argument("--color", required=True)
p.add_argument("--strength", type=float, default=1.0)
args = p.parse_args()

src = os.path.join(ROOT, args.source)
dst = os.path.join(ROOT, args.name)
os.makedirs(dst, exist_ok=True)
a = np.asarray(Image.open(os.path.join(src, "albedo.png")).convert("RGB")).astype(float) / 255.0
lum = a.mean(axis=2, keepdims=True)
detail = lum / max(lum.mean(), 1e-3)                   # 1.0 = average brightness
target = np.array([int(args.color.lstrip("#")[i:i + 2], 16) / 255.0 for i in (0, 2, 4)])
tinted = np.clip(detail * target, 0, 1)
out = a * (1 - args.strength) + tinted * args.strength
Image.fromarray((out * 255).astype(np.uint8)).save(os.path.join(dst, "albedo.png"))
for f in ("normal.png", "roughness.png"):
    shutil.copy(os.path.join(src, f), os.path.join(dst, f))
print(f"{args.name}: {args.source} tinted {args.color}")
