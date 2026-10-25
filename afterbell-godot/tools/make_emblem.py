"""Generates the store's "B" medallion: a raised brass serif B on plum enamel inside a
roped brass ring. Writes albedo, normal and metal-mask PNGs to assets/textures/signs/.

    python3 tools/make_emblem.py
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

SIZE = 512
FONT = "/usr/share/fonts/truetype/liberation/LiberationSerif-Bold.ttf"
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "textures", "signs")

BRASS = np.array([201, 167, 94], float)
BRASS_DEEP = np.array([150, 116, 58], float)
PLUM = np.array([78, 31, 58], float)


def blur(a, r):
    img = Image.fromarray(np.clip(a * 255, 0, 255).astype(np.uint8))
    return np.asarray(img.filter(ImageFilter.GaussianBlur(r)), float) / 255.0


def main():
    c = (SIZE - 1) / 2.0
    y, x = np.mgrid[0:SIZE, 0:SIZE]
    r = np.hypot(x - c, y - c)
    ang = np.arctan2(y - c, x - c)

    outer = (r <= 250).astype(float)
    ring = ((r >= 214) & (r <= 250)).astype(float)
    inner = ((r >= 194) & (r <= 202)).astype(float)

    glyph = Image.new("L", (SIZE, SIZE), 0)
    d = ImageDraw.Draw(glyph)
    font = ImageFont.truetype(FONT, 300)
    box = d.textbbox((0, 0), "B", font=font)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text((c - w / 2 - box[0], c - h / 2 - box[1] - 4), "B", font=font, fill=255)
    for sx in (-1, 1):   # small brass studs either side of the letter
        cx, cy = c + sx * 150, c
        d.ellipse((cx - 9, cy - 9, cx + 9, cy + 9), fill=255)
    letter = np.asarray(glyph, float) / 255.0

    # Height: domed ring with a rope twist, a thin inner bead, the letter raised and bevelled.
    ring_profile = np.clip(1.0 - ((r - 232) / 18.0) ** 2, 0, 1)
    rope = 0.5 + 0.5 * np.sin(ang * 48 + (r - 214) * 0.35)
    height = ring * (0.75 * ring_profile + 0.25 * rope * ring_profile)
    height += inner * 0.4
    height += blur(letter, 3.0) * 0.9
    height = blur(height, 1.0)

    gy, gx = np.gradient(height)
    strength = 6.0
    nx, ny, nz = -gx * strength, gy * strength, np.ones_like(height)   # +y up in the texture
    n = np.sqrt(nx * nx + ny * ny + nz * nz)
    normal = np.stack([(nx / n) * 0.5 + 0.5, (ny / n) * 0.5 + 0.5, (nz / n) * 0.5 + 0.5], -1)

    metal = np.clip(ring + inner + letter, 0, 1)
    shade = 0.82 + 0.18 * np.clip(height, 0, 1)   # raised brass a touch brighter, recesses deeper
    brass = BRASS_DEEP[None, None] + (BRASS - BRASS_DEEP)[None, None] * shade[..., None]
    enamel = PLUM[None, None] * (0.92 + 0.08 * blur((r < 194).astype(float), 6.0))[..., None]
    albedo = enamel * (1 - metal[..., None]) + brass * metal[..., None]
    alpha = blur(outer, 0.8)

    os.makedirs(OUT, exist_ok=True)
    Image.fromarray(np.dstack([albedo, alpha * 255]).clip(0, 255).astype(np.uint8), "RGBA").save(os.path.join(OUT, "emblem_b.png"))
    Image.fromarray((normal * 255).clip(0, 255).astype(np.uint8), "RGB").save(os.path.join(OUT, "emblem_b_normal.png"))
    Image.fromarray((metal * 255).astype(np.uint8), "L").save(os.path.join(OUT, "emblem_b_metal.png"))


if __name__ == "__main__":
    main()
