#!/usr/bin/env python3
"""Deepen the red parts of a texture, leaving blacks, whites and metals alone.

    python3 tools/deepen_red.py SOURCE.png OUT.png [--target "#8e1219"] [--strength 1.0]

Each pixel's "redness" (how far red exceeds green and blue) becomes a soft mask; masked pixels
are pulled toward the target's hue and depth while keeping their own light/dark detail, so
panel lines, scuffs and highlights in the paint survive.
"""
import argparse

import numpy as np
from PIL import Image

p = argparse.ArgumentParser()
p.add_argument("source")
p.add_argument("out")
p.add_argument("--target", default="#8e1219")
p.add_argument("--strength", type=float, default=1.0)
args = p.parse_args()

img = Image.open(args.source)
alpha = img.getchannel("A") if img.mode == "RGBA" else None
a = np.asarray(img.convert("RGB")).astype(float) / 255.0
r, g, b = a[..., 0], a[..., 1], a[..., 2]
redness = r - np.maximum(g, b)
mask = np.clip((redness - 0.12) / 0.25, 0.0, 1.0)[..., None] * args.strength

t = np.array([int(args.target[i:i + 2], 16) for i in (1, 3, 5)], float) / 255.0
red = mask[..., 0] > 0.5
ref = r[red].mean() if red.any() else 1.0              # the paint's average red level
detail = (r / max(ref, 1e-3))[..., None]               # 1.0 = average paint brightness
deep = np.clip(t * detail, 0.0, 1.0)
outp = a * (1.0 - mask) + deep * mask
res = Image.fromarray((outp * 255.0 + 0.5).astype(np.uint8), "RGB")
if alpha is not None:
    res.putalpha(alpha)
res.save(args.out)
print(f"{args.out}: {red.mean() * 100:.1f}% of pixels recoloured toward {args.target}")
