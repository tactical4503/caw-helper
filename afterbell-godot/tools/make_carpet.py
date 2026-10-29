"""Generates the store carpet: a soft teal wool with a woven diamond lattice and small brass-cream
medallions at the crossings, tileable, as assets/textures/carpet_deco/{albedo,normal,roughness}.png.
The game tints it (builders.CARPET_TINT), so the albedo stays mid-grey-teal.

    python3 tools/make_carpet.py        (run from afterbell-godot/)
"""
import math
import os
import random

from PIL import Image, ImageFilter

N = 1024            # pixels per tile (the game maps one tile to 2 m)
CELLS = 4           # diamonds across a tile: 0.5 m lattice
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "textures", "carpet_deco")

random.seed(11)
base = (46, 74, 70)       # teal wool
dark = (30, 52, 50)       # the lattice lines, woven darker
light = (172, 150, 104)   # brass-cream medallions


def tile_noise(scale):
    """Tileable value noise in 0..1 from a small random grid, bilinear and wrapped."""
    g = [[random.random() for _ in range(scale)] for _ in range(scale)]
    out = []
    for y in range(N):
        fy = y * scale / N
        y0 = int(fy) % scale
        y1 = (y0 + 1) % scale
        ty = fy - int(fy)
        row = []
        for x in range(N):
            fx = x * scale / N
            x0 = int(fx) % scale
            x1 = (x0 + 1) % scale
            tx = fx - int(fx)
            a = g[y0][x0] * (1 - tx) + g[y0][x1] * tx
            b = g[y1][x0] * (1 - tx) + g[y1][x1] * tx
            row.append(a * (1 - ty) + b * ty)
        out.append(row)
    return out


coarse = tile_noise(8)
fine = tile_noise(128)
alb = Image.new("RGB", (N, N))
height = Image.new("L", (N, N))
rough = Image.new("L", (N, N))
ap, hp, rp = alb.load(), height.load(), rough.load()
period = N / CELLS
for y in range(N):
    for x in range(N):
        # Diamond lattice: distance to the nearest line of the two diagonal families.
        u = (x + y) / period
        v = (x - y) / period
        du = abs(u - round(u))
        dv = abs(v - round(v))
        line = min(du, dv)
        on_line = max(0.0, 1.0 - line / 0.045)
        # Medallions where the lines cross (u, v both near integers), and at diamond centres.
        cross = math.hypot(du, dv)
        centre = math.hypot(abs(u - math.floor(u) - 0.5), abs(v - math.floor(v) - 0.5))
        medal = max(0.0, 1.0 - cross / 0.07) + 0.6 * max(0.0, 1.0 - centre / 0.05)
        wool = 0.86 + 0.18 * coarse[y][x] + 0.16 * (fine[y][x] - 0.5)
        c = [b * wool for b in base]
        c = [c[i] * (1 - on_line * 0.55) + dark[i] * on_line * 0.55 for i in range(3)]
        m = min(1.0, medal)
        c = [c[i] * (1 - m) + light[i] * m for i in range(3)]
        ap[x, y] = tuple(int(max(0, min(255, k))) for k in c)
        hp[x, y] = int(255 * (0.55 + 0.25 * fine[y][x] - 0.25 * on_line + 0.15 * m))
        rp[x, y] = int(255 * (0.9 - 0.25 * m))   # wool is matte; the brass thread has a little sheen

height = height.filter(ImageFilter.GaussianBlur(1.2))
hp = height.load()
nrm = Image.new("RGB", (N, N))
np_ = nrm.load()
for y in range(N):
    for x in range(N):
        dx = (hp[(x + 1) % N, y] - hp[(x - 1) % N, y]) / 255.0
        dy = (hp[x, (y + 1) % N] - hp[x, (y - 1) % N]) / 255.0
        nx, ny, nz = -dx * 2.0, -dy * 2.0, 1.0
        ln = math.sqrt(nx * nx + ny * ny + nz * nz)
        np_[x, y] = (int((nx / ln * 0.5 + 0.5) * 255), int((ny / ln * 0.5 + 0.5) * 255), int((nz / ln * 0.5 + 0.5) * 255))

os.makedirs(OUT, exist_ok=True)
alb.save(os.path.join(OUT, "albedo.png"))
nrm.save(os.path.join(OUT, "normal.png"))
rough.save(os.path.join(OUT, "roughness.png"))
print("wrote", OUT)
