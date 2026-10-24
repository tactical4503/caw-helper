#!/usr/bin/env python3
"""Regenerate the store's surface textures as quiet, readable sets.

    python3 tools/quiet_textures.py [name ...]      (default: all of them)

Writes assets/textures/NAME/{albedo,normal,roughness}.png. Every texture follows the same rules:
a calm base colour, soft large-scale variation, a little wear, and one larger detail you can read
from across a room (a carpet lattice, stone coursing, floor tiles). No pixel-scale speckle, which
only turns into shimmer at a distance. All noise is band-limited in frequency space, so every
texture tiles seamlessly.
"""
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "textures")
N = 1024


def noise(scale, seed, stretch=(1.0, 1.0)):
    """Seamless smooth noise in [-1, 1]; `scale` is the feature size in pixels."""
    rng = np.random.default_rng(seed)
    white = rng.standard_normal((N, N))
    fy = np.fft.fftfreq(N)[:, None] * stretch[1]
    fx = np.fft.fftfreq(N)[None, :] * stretch[0]
    f = np.sqrt(fx * fx + fy * fy) * scale
    out = np.real(np.fft.ifft2(np.fft.fft2(white) * np.exp(-f * f * 4.0)))
    out -= out.mean()
    return out / (np.abs(out).max() + 1e-9)


def hexc(h):
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], float) / 255.0


def grid():
    y, x = np.mgrid[0:N, 0:N].astype(float)
    return x, y


def smooth(e0, e1, v):
    t = np.clip((v - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def save(name, albedo, height, rough, normal_strength=2.0):
    d = os.path.join(ROOT, name)
    os.makedirs(d, exist_ok=True)
    Image.fromarray((np.clip(albedo, 0, 1) * 255 + 0.5).astype(np.uint8), "RGB").save(os.path.join(d, "albedo.png"))
    gy, gx = np.gradient(height)
    # wrap-aware gradient at the borders so the normal map tiles too
    gx[:, 0] = (height[:, 1] - height[:, -1]) * 0.5
    gx[:, -1] = (height[:, 0] - height[:, -2]) * 0.5
    gy[0, :] = (height[1, :] - height[-1, :]) * 0.5
    gy[-1, :] = (height[0, :] - height[-2, :]) * 0.5
    nx, ny, nz = -gx * normal_strength, -gy * normal_strength, np.ones_like(height)
    length = np.sqrt(nx * nx + ny * ny + nz * nz)
    nrm = np.stack([nx / length, ny / length, nz / length], -1) * 0.5 + 0.5
    Image.fromarray((nrm * 255 + 0.5).astype(np.uint8), "RGB").save(os.path.join(d, "normal.png"))
    Image.fromarray((np.clip(rough, 0, 1) * 255 + 0.5).astype(np.uint8), "L").save(os.path.join(d, "roughness.png"))
    print(f"{name}: albedo mean {np.clip(albedo, 0, 1).reshape(-1, 3).mean(0).round(3)}")


def tint(base, light):
    """Brightness variation `light` (around 0) applied to a base colour."""
    return base[None, None, :] * (1.0 + light[..., None])


def wear_mask(seed, coverage=0.25, scale=180):
    w = noise(scale, seed) * 0.5 + 0.5
    return smooth(1.0 - coverage, 1.0 - coverage + 0.25, w)


# ---------------------------------------------------------------- carpets

def carpet(name, base, accent, seed, lattice=True):
    """Pile carpet: soft mottling, faint pile direction, worn traffic patches and, optionally, a
    tone-on-tone diamond lattice with a small medallion, repeating every quarter of the tile."""
    x, y = grid()
    light = noise(140, seed) * 0.035 + noise(28, seed + 1) * 0.012
    light += noise(10, seed + 2, stretch=(0.25, 1.0)) * 0.012          # pile direction
    pattern = np.zeros((N, N))
    if not lattice:   # border runner: two quiet bands along its length
        band = np.abs(((x % (N / 2.0)) - N / 4.0))
        pattern = (1.0 - smooth(4.0, 9.0, np.abs(band - 150.0))) * 0.8
    if lattice:
        p = N / 4.0
        u = np.abs(((x + y) % p) - p / 2.0)
        v = np.abs(((x - y) % p) - p / 2.0)
        line = 1.0 - smooth(2.0, 6.0, np.minimum(u, v))                # diamond lines
        cx = np.abs((x % p) - p / 2.0)
        cy = np.abs((y % p) - p / 2.0)
        medal = 1.0 - smooth(10.0, 16.0, np.hypot(cx, cy))              # medallion in each diamond
        ring = 1.0 - smooth(1.5, 4.0, np.abs(np.hypot(cx, cy) - 24.0))
        pattern = line * 0.9 + medal * 0.7 + ring * 0.5
    a = tint(base, light)
    a = a * (1.0 - pattern[..., None] * 0.35) + accent[None, None, :] * pattern[..., None] * 0.35
    wear = wear_mask(seed + 3, 0.2)
    grey = a.mean(-1, keepdims=True)
    a = a * (1.0 - wear[..., None] * 0.25) + (grey * 1.12) * wear[..., None] * 0.25   # flattened, faded pile
    height = noise(10, seed + 2, stretch=(0.25, 1.0)) * 0.3 + noise(28, seed + 1) * 0.3 - pattern * 0.6 - wear * 0.3
    rough = 0.9 + noise(60, seed + 4) * 0.03 - wear * 0.05
    save(name, a, height, rough, 1.6)


# ---------------------------------------------------------------- walls and floors

def plaster(name, base, seed):
    """Smooth painted plaster: broad soft clouding, faint trowel sweeps, scuffs low on the wall."""
    x, y = grid()
    light = noise(220, seed) * 0.03 + noise(60, seed + 1) * 0.012
    sweep = noise(40, seed + 2, stretch=(0.35, 1.0)) * 0.012            # trowel direction
    scuff = wear_mask(seed + 3, 0.12, 120) * smooth(0.7, 1.0, y / N)    # lower part of each tile
    a = tint(base, light + sweep - scuff * 0.05)
    height = noise(60, seed + 1) * 0.4 + noise(40, seed + 2, stretch=(0.35, 1.0)) * 0.3
    rough = 0.8 + noise(120, seed + 4) * 0.04
    save(name, a, height, rough, 0.8)


def stone(name, base, seed):
    """Dressed stone in running bond: blocks 2 tiles across and 8 high per texture, a soft
    tone shift per block, chamfered edges, recessed mortar, gentle weathering."""
    x, y = grid()
    rows, cols = 8, 2
    bh, bw = N / rows, N / cols
    row = np.floor(y / bh)
    xs = x + (row % 2) * bw / 2.0
    col = np.floor(xs / bw) % cols
    fx = (xs % bw)
    fy = (y % bh)
    edge = np.minimum(np.minimum(fx, bw - fx), np.minimum(fy, bh - fy))
    mortar = 1.0 - smooth(2.0, 4.0, edge)
    bevel = smooth(3.0, 10.0, edge)
    rng = np.random.default_rng(seed)
    tones = rng.uniform(-0.05, 0.05, (rows, cols))
    block = tones[row.astype(int) % rows, col.astype(int)]
    light = block + noise(90, seed + 1) * 0.025 + noise(24, seed + 2) * 0.008
    a = tint(base, light)
    a = a * (1.0 - mortar[..., None] * 0.22)
    weather = wear_mask(seed + 3, 0.18, 160)
    a = a * (1.0 - weather[..., None] * 0.04)
    height = bevel * 0.8 + noise(24, seed + 2) * 0.08 - mortar * 0.4
    rough = 0.78 + mortar * 0.15 + noise(90, seed + 4) * 0.03
    save(name, a, height, rough, 3.0)


def tile(name, base, seed):
    """Large cream floor tiles, 4 per texture side, slightly varied, with soft marbling,
    grey grout and a satin wax that has worn duller in patches."""
    x, y = grid()
    n = 4
    s = N / n
    fx, fy = x % s, y % s
    edge = np.minimum(np.minimum(fx, s - fx), np.minimum(fy, s - fy))
    grout = 1.0 - smooth(2.0, 4.5, edge)
    rng = np.random.default_rng(seed)
    tones = rng.uniform(-0.03, 0.03, (n, n))
    t = tones[(y // s).astype(int) % n, (x // s).astype(int) % n]
    vein = np.abs(noise(110, seed + 1, stretch=(1.0, 0.35)))
    vein = (1.0 - smooth(0.0, 0.18, vein)) * (noise(200, seed + 5) * 0.5 + 0.5)   # broad, fading veins
    light = t + noise(160, seed + 2) * 0.02 - vein * 0.025
    a = tint(base, light)
    a = a * (1.0 - grout[..., None] * 0.3)
    wear = wear_mask(seed + 3, 0.22, 200)
    height = smooth(2.0, 6.0, edge) * 0.6 - grout * 0.3
    rough = 0.5 + wear * 0.15 + grout * 0.3 + noise(120, seed + 4) * 0.03
    save(name, a, height, rough, 2.0)


def laminate(name, base, seed):
    """Plum display-base laminate: near-flat colour with long faint streaks and soft rub marks."""
    light = noise(30, seed, stretch=(0.12, 1.0)) * 0.03 + noise(200, seed + 1) * 0.025
    rub = wear_mask(seed + 2, 0.15, 150)
    a = tint(base, light + rub * 0.06)
    height = noise(30, seed, stretch=(0.12, 1.0)) * 0.15
    rough = 0.65 + rub * 0.08 + noise(150, seed + 3) * 0.03
    save(name, a, height, rough, 0.6)


def velvet(name, base, seed):
    """Velvet: soft broad sheen changes where the nap has been brushed different ways."""
    light = noise(120, seed) * 0.07 + noise(30, seed + 1) * 0.015
    a = tint(base, light)
    height = noise(30, seed + 1) * 0.2
    rough = 0.93 + noise(120, seed + 2) * 0.03
    save(name, a, height, rough, 0.6)


def linen(name, base, seed):
    """Linen: a visible but gentle weave (8 px threads) with slubs and soft creasing."""
    x, y = grid()
    weave = (np.sin(x * np.pi / 4.0) * np.sin(y * np.pi / 4.0)) * 0.018
    slub = noise(6, seed, stretch=(1.0, 0.15)) * 0.02
    crease = noise(120, seed + 1) * 0.04
    a = tint(base, weave + slub + crease)
    height = weave * 8.0 + crease * 2.0
    rough = 0.88 + noise(80, seed + 2) * 0.03
    save(name, a, height, rough, 1.0)


SETS = {
    "carpet_forest": lambda: carpet("carpet_forest", hexc("#1f3c2c"), hexc("#2f5a40"), 11),
    "carpet_green": lambda: carpet("carpet_green", hexc("#24452f"), hexc("#355f44"), 12),
    "carpet_sage": lambda: carpet("carpet_sage", hexc("#3b5c48"), hexc("#4c6f58"), 13, lattice=False),
    "carpet_plum": lambda: carpet("carpet_plum", hexc("#4e1a36"), hexc("#6b2a4c"), 14),
    "plaster_cream": lambda: plaster("plaster_cream", hexc("#e2d3b4"), 21),
    "plaster_plum": lambda: plaster("plaster_plum", hexc("#4a1d36"), 22),
    "plaster_sage": lambda: plaster("plaster_sage", hexc("#90a68d"), 23),
    "stone_cream": lambda: stone("stone_cream", hexc("#d9cbad"), 31),
    "tile_cream": lambda: tile("tile_cream", hexc("#dccfb3"), 41),
    "laminate_plum": lambda: laminate("laminate_plum", hexc("#5a1c34"), 51),
    "velvet_red": lambda: velvet("velvet_red", hexc("#7a1b2a"), 61),
    "linen_cream": lambda: linen("linen_cream", hexc("#e6dac2"), 71),
}

if __name__ == "__main__":
    for name in (sys.argv[1:] or SETS):
        SETS[name]()
