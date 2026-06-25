#!/usr/bin/env python3
"""Programmatic placeholder art for Rogue Kaiju.

The project shipped with every entity drawn as a flat ColorRect. This script
generates native-resolution pixel sprites (the game runs at a 480x270 viewport
with nearest-neighbour filtering, so 1px == 1 game pixel) that the scenes/
scripts are rewired to use:

    assets/monsters/kaiju.png      22x40   player monster
    assets/enemies/soldier.png     10x16   military soldier
    assets/buildings/building.png  16x16   tileable lit-window facade
    assets/env/ground.png          16x16   tileable cracked street
    assets/env/sky.png            480x270  dusk gradient backdrop
    assets/env/skyline.png        256x96   tileable distant-city silhouette

Deliberately throwaway placeholders authored by code -- NOT final art.
Re-run with:  python3 tools/gen_placeholder_art.py
"""

import os
import math
import random

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ASSETS = os.path.normpath(os.path.join(HERE, "..", "assets"))


def px(img, x, y, c):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((int(x), int(y)), c)


def rect(img, x0, y0, x1, y1, c):
    for y in range(int(y0), int(y1) + 1):
        for x in range(int(x0), int(x1) + 1):
            px(img, x, y, c)


def save(img, *parts):
    path = os.path.join(ASSETS, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    return path


# --- seamless wrapped value noise -------------------------------------------

def wrapped_noise(w, h, cells, seed):
    rnd = random.Random(seed)
    grid = [[rnd.random() for _ in range(cells)] for _ in range(cells)]

    def sample(u, v):
        gx, gy = u * cells, v * cells
        x0, y0 = int(gx) % cells, int(gy) % cells
        x1, y1 = (x0 + 1) % cells, (y0 + 1) % cells
        fx, fy = gx - int(gx), gy - int(gy)
        fx = fx * fx * (3 - 2 * fx)
        fy = fy * fy * (3 - 2 * fy)
        top = grid[y0][x0] * (1 - fx) + grid[y0][x1] * fx
        bot = grid[y1][x0] * (1 - fx) + grid[y1][x1] * fx
        return top * (1 - fy) + bot * fy

    return [[sample(x / w, y / h) for x in range(w)] for y in range(h)]


# --- KAIJU (22x40) ----------------------------------------------------------

def gen_kaiju():
    img = Image.new("RGBA", (22, 40), (0, 0, 0, 0))
    OUT = (18, 54, 26, 255)
    BODY = (46, 168, 70, 255)
    DARK = (32, 120, 50, 255)
    BELLY = (148, 206, 120, 255)
    SPIKE = (214, 232, 150, 255)
    EYE = (250, 220, 70, 255)

    # tail sweeping out to the lower-left
    for i, (tx, ty) in enumerate([(2, 33), (3, 31), (5, 30), (7, 30), (9, 31)]):
        rect(img, tx, ty, tx + 2, ty + 2, DARK)

    # legs
    rect(img, 8, 30, 11, 39, BODY)
    rect(img, 13, 30, 16, 39, BODY)
    rect(img, 8, 37, 12, 39, DARK)      # feet
    rect(img, 13, 37, 17, 39, DARK)

    # torso
    rect(img, 8, 16, 17, 31, BODY)
    rect(img, 10, 20, 15, 30, BELLY)    # belly plates
    for by in range(21, 30, 3):
        rect(img, 10, by, 15, by, DARK)

    # arms
    rect(img, 6, 19, 8, 28, DARK)
    rect(img, 16, 19, 18, 28, BODY)

    # head, facing right
    rect(img, 13, 6, 20, 16, BODY)
    rect(img, 18, 9, 20, 13, DARK)      # snout shade
    px(img, 17, 9, EYE)
    px(img, 18, 9, EYE)

    # dorsal spikes along the back
    for sy, sx in [(14, 9), (11, 10), (8, 12)]:
        rect(img, sx, sy, sx + 1, sy + 2, SPIKE)

    # outline pass: darken transparent neighbours of body pixels
    base = img.copy()
    for y in range(40):
        for x in range(22):
            if base.getpixel((x, y))[3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < 22 and 0 <= ny < 40 and base.getpixel((nx, ny))[3] > 0:
                        px(img, x, y, OUT)
                        break
    save(img, "monsters", "kaiju.png")


# --- SOLDIER (10x16) --------------------------------------------------------

def gen_soldier():
    img = Image.new("RGBA", (10, 16), (0, 0, 0, 0))
    OUT = (24, 40, 22, 255)
    UNI = (74, 110, 60, 255)
    UNI_D = (52, 80, 42, 255)
    SKIN = (214, 168, 130, 255)
    HELM = (60, 78, 44, 255)
    GUN = (40, 40, 46, 255)

    rect(img, 3, 1, 7, 3, HELM)          # helmet
    rect(img, 4, 4, 6, 5, SKIN)          # face
    rect(img, 3, 6, 7, 11, UNI)          # torso
    rect(img, 3, 9, 7, 11, UNI_D)        # webbing/shade
    rect(img, 3, 12, 4, 15, UNI_D)       # legs
    rect(img, 6, 12, 7, 15, UNI_D)
    rect(img, 1, 7, 8, 7, GUN)           # rifle held across body
    px(img, 0, 7, GUN)

    base = img.copy()
    for y in range(16):
        for x in range(10):
            if base.getpixel((x, y))[3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < 10 and 0 <= ny < 16 and base.getpixel((nx, ny))[3] > 0:
                        px(img, x, y, OUT)
                        break
    save(img, "enemies", "soldier.png")


# --- BUILDING FACADE (16x16, tileable) --------------------------------------
# Light neutral concrete so the damage tint (modulate) reads cleanly.

def gen_building():
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 255))
    CONCRETE = (150, 156, 164, 255)
    CONCRETE_D = (122, 128, 138, 255)
    FRAME = (54, 60, 70, 255)
    LIT = (255, 214, 122, 255)
    DARK = (62, 72, 96, 255)

    rect(img, 0, 0, 15, 15, CONCRETE)
    for x in range(0, 16, 2):            # faint vertical concrete shading
        rect(img, x, 0, x, 15, CONCRETE_D if (x // 2) % 2 else CONCRETE)

    # two window columns x[2..5],[10..13]; two rows y[2..6],[10..14]
    lit_pattern = {(0, 0): LIT, (1, 0): DARK, (0, 1): DARK, (1, 1): LIT}
    for cxi, wx in enumerate((2, 10)):
        for cyi, wy in enumerate((2, 10)):
            rect(img, wx - 1, wy - 1, wx + 4, wy + 4, FRAME)
            rect(img, wx, wy, wx + 3, wy + 3, lit_pattern[(cxi, cyi)])
            px(img, wx, wy, (255, 255, 255, 60))  # glass glint
    save(img, "buildings", "building.png")


# --- GROUND (16x16, tileable cracked street) --------------------------------

def gen_ground():
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 255))
    shades = [(44, 40, 32, 255), (54, 49, 39, 255), (64, 58, 46, 255), (36, 33, 26, 255)]
    n = wrapped_noise(16, 16, 4, 77)
    for y in range(16):
        for x in range(16):
            v = n[y][x]
            idx = 0 if v < 0.35 else 1 if v < 0.62 else 2 if v < 0.82 else 3
            img.putpixel((x, y), shades[idx])
    # a couple of wrapped cracks/rubble bits
    rnd = random.Random(9)
    for _ in range(6):
        x, y = rnd.randrange(16), rnd.randrange(16)
        img.putpixel((x, y), (28, 26, 20, 255))
        img.putpixel(((x + 1) % 16, y), (78, 70, 54, 255))
    save(img, "env", "ground.png")


# --- SKY (480x270 dusk gradient) --------------------------------------------

def gen_sky():
    w, h = 480, 270
    img = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    top = (28, 26, 58)        # deep dusk blue
    mid = (92, 64, 96)        # purple
    horizon = (224, 120, 70)  # warm glow
    for y in range(h):
        t = y / (h - 1)
        if t < 0.6:
            k = t / 0.6
            c = tuple(int(top[i] + (mid[i] - top[i]) * k) for i in range(3))
        else:
            k = (t - 0.6) / 0.4
            c = tuple(int(mid[i] + (horizon[i] - mid[i]) * k) for i in range(3))
        rect(img, 0, y, w - 1, y, c + (255,))
    # a pale moon
    for yy in range(-7, 8):
        for xx in range(-7, 8):
            if xx * xx + yy * yy <= 49:
                px(img, 84 + xx, 58 + yy, (236, 236, 214, 255))
    save(img, "env", "sky.png")


# --- SKYLINE (256x96, tileable distant city silhouette) ---------------------

def gen_skyline():
    w, h = 256, 96
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    SIL = (40, 40, 66, 235)
    WIN = (120, 132, 170, 200)
    rnd = random.Random(5)
    x = 6
    while x < w - 6:
        bw = rnd.randrange(14, 30)
        bh = rnd.randrange(28, 78)
        if x + bw > w - 6:
            bw = (w - 6) - x
        rect(img, x, h - bh, x + bw - 1, h - 1, SIL)
        for wy in range(h - bh + 4, h - 4, 6):       # window dots
            for wx in range(x + 3, x + bw - 3, 5):
                if rnd.random() < 0.4:
                    px(img, wx, wy, WIN)
        x += bw + rnd.randrange(2, 6)
    save(img, "env", "skyline.png")


def main():
    gen_kaiju()
    gen_soldier()
    gen_building()
    gen_ground()
    gen_sky()
    gen_skyline()
    print("wrote kaiju, soldier, building, ground, sky, skyline to", ASSETS)


if __name__ == "__main__":
    main()
