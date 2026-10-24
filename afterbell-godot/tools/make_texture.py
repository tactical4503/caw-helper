#!/usr/bin/env python3
"""Turn one AI-generated image into a game-ready texture set.

    python3 tools/make_texture.py IMAGE NAME [--roughness 0.6] [--bump 4] [--sign]

Tileable materials (default) -> assets/textures/NAME/{albedo,normal,roughness}.png at 1024x1024:
  * seams removed by cross-fading the image with a half-offset copy of itself (the offset copy's
    edges come from the image's interior, so they wrap perfectly; the original fills the middle);
  * a normal map derived from brightness (bright = raised), tiling-aware;
  * a roughness map around --roughness, slightly varied by the surface detail.
Regular patterns (bricks, tiles, wallpaper) should use --no-blend: cross-fading ghosts their lines.
Signs (--sign) -> assets/textures/signs/NAME.png, trimmed to the sign itself, aspect kept.
"""
import argparse
import os

import numpy as np
from PIL import Image

SIZE = 1024
ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "textures")


def seam_error(a):
    lr = np.abs(a[:, 0] - a[:, -1]).mean()
    tb = np.abs(a[0] - a[-1]).mean()
    inner = (np.abs(a[:, 1] - a[:, 0]).mean() + np.abs(a[1] - a[0]).mean()) / 2
    return max(lr, tb) - inner


def make_seamless(a):
    h, w = a.shape[:2]
    shifted = np.roll(np.roll(a, h // 2, axis=0), w // 2, axis=1)
    y = np.sin(np.linspace(0, np.pi, h))[:, None]
    x = np.sin(np.linspace(0, np.pi, w))[None, :]
    weight = np.clip(np.minimum(x, y) * 1.6, 0, 1) ** 1.5  # 1 in the middle, 0 at the edges
    return a * weight[..., None] + shifted * (1 - weight[..., None])


def blur_wrap(a, r):
    out = a.copy()
    for _ in range(r):
        out = (out + np.roll(out, 1, 0) + np.roll(out, -1, 0) + np.roll(out, 1, 1) + np.roll(out, -1, 1)) / 5
    return out


def normal_map(rgb, strength):
    height = blur_wrap(rgb.mean(axis=2) / 255.0, 2)
    dx = (np.roll(height, -1, 1) - np.roll(height, 1, 1)) * strength
    dy = (np.roll(height, -1, 0) - np.roll(height, 1, 0)) * strength
    n = np.dstack([-dx, dy, np.ones_like(height)])  # OpenGL-style (Godot) normal map
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    return ((n * 0.5 + 0.5) * 255).astype(np.uint8)


def roughness_map(rgb, base):
    lum = rgb.mean(axis=2) / 255.0
    detail = (lum - blur_wrap(lum, 6)) * 0.6  # small variation, darker crevices rougher
    r = np.clip(base - detail, 0.02, 1.0)
    return (r * 255).astype(np.uint8)


def trim_sign(im):
    a = np.asarray(im).astype(float)
    bg = np.median(np.concatenate([a[0], a[-1], a[:, 0], a[:, -1]]), axis=0)
    mask = np.abs(a - bg).sum(axis=2) > 40
    ys, xs = np.where(mask)
    return im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("image")
    p.add_argument("name")
    p.add_argument("--roughness", type=float, default=0.6)
    p.add_argument("--bump", type=float, default=4.0)
    p.add_argument("--sign", action="store_true")
    p.add_argument("--no-blend", action="store_true", help="keep as is: for regular patterns (bricks, tiles, slabs) that already tile")
    args = p.parse_args()
    im = Image.open(args.image).convert("RGB")
    if args.sign:
        out = os.path.join(ROOT, "signs")
        os.makedirs(out, exist_ok=True)
        sign = trim_sign(im)
        path = os.path.join(out, args.name + ".png")
        sign.save(path)
        print(f"{args.name}: sign {sign.size} -> {path}")
        return
    side = min(im.size)
    im = im.crop(((im.width - side) // 2, (im.height - side) // 2, (im.width + side) // 2, (im.height + side) // 2))
    a = np.asarray(im.resize((SIZE, SIZE), Image.LANCZOS)).astype(float)
    before = seam_error(a)
    if before > 2.0 and not args.no_blend:
        a = make_seamless(a)
    rgb = np.clip(a, 0, 255).astype(np.uint8)
    out = os.path.join(ROOT, args.name)
    os.makedirs(out, exist_ok=True)
    Image.fromarray(rgb).save(os.path.join(out, "albedo.png"))
    Image.fromarray(normal_map(a, args.bump)).save(os.path.join(out, "normal.png"))
    Image.fromarray(roughness_map(a, args.roughness), "L").save(os.path.join(out, "roughness.png"))
    print(f"{args.name}: seam {before:.1f} -> {seam_error(a):.1f}, saved {out}")


if __name__ == "__main__":
    main()
