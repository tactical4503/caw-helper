#!/usr/bin/env python3
"""Synthesizes the game's sound set (original, owned, no samples or melodies borrowed).

    python3 tools/make_sfx.py

Writes 22.05/44.1 kHz mono WAVs to assets/sfx/, named after the cues Sfx.play_file() looks for.
Every sound is built from sine partials, filtered noise and envelopes, so it can be regenerated
and retuned here.
"""
import os
import wave

import numpy as np

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx")
rng = np.random.default_rng(7)


def t_axis(dur):
    return np.arange(int(RATE * dur)) / RATE


def env(t, attack, decay):
    a = np.clip(t / max(attack, 1e-4), 0, 1)
    return a * np.exp(-t / decay)


def lowpass(x, cutoff):
    # one-pole filter run twice: soft, cheap
    a = np.exp(-2 * np.pi * cutoff / RATE)
    for _ in range(2):
        y = np.empty_like(x)
        acc = 0.0
        for i, v in enumerate(x):
            acc = (1 - a) * v + a * acc
            y[i] = acc
        x = y
    return x


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def bell_tone(freq, dur, partials, decay, strike=0.004):
    t = t_axis(dur)
    s = np.zeros_like(t)
    for ratio, amp, dk in partials:
        s += amp * np.sin(2 * np.pi * freq * ratio * t + rng.random() * 6.28) * np.exp(-t / (decay * dk))
    s *= np.clip(t / strike, 0, 1)
    return s


def write(name, x, peak=0.8):
    x = np.asarray(x, float)
    m = np.max(np.abs(x)) or 1.0
    x = x / m * peak
    fade = min(len(x), int(RATE * 0.01))
    x[-fade:] *= np.linspace(1, 0, fade)
    data = (x * 32767).astype(np.int16)
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())
    print(name, round(len(x) / RATE, 2), "s")


def pad(x, dur):
    out = np.zeros(int(RATE * dur))
    out[: len(x)] = x[: len(out)]
    return out


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def delayed(x, sec):
    return np.concatenate([np.zeros(int(RATE * sec)), x])


# The great service bell: a struck brass dome, inharmonic partials, a long warm tail.
BELL_PARTIALS = [(1.0, 1.0, 1.0), (2.01, 0.45, 0.6), (2.76, 0.3, 0.45), (5.4, 0.12, 0.25), (8.9, 0.05, 0.12)]
bell = bell_tone(392.0, 4.5, BELL_PARTIALS, 1.6)
bell += 0.4 * highpass(rng.standard_normal(len(bell)), 2500) * np.exp(-t_axis(4.5) / 0.012)   # the strike
write("bell", bell, 0.85)

# Department chime: three soft bell notes, descending, for a completed errand.
notes = [(1046.5, 0.0), (783.99, 0.28), (659.25, 0.56)]   # C6, G5, E5
chime = mix(*[delayed(bell_tone(f, 1.8, [(1, 1, 1), (2.0, 0.25, 0.5), (3.0, 0.08, 0.3)], 0.55), d) for f, d in notes])
write("chime_errand", chime, 0.6)

# The sale-sign tell keeps its two quick notes, now as small struck bells.
tell = mix(bell_tone(880, 0.6, [(1, 1, 1), (2.0, 0.3, 0.5)], 0.18), delayed(bell_tone(1175, 0.7, [(1, 1, 1), (2.0, 0.3, 0.5)], 0.2), 0.15))
write("chime", tell, 0.55)

# Cash register: key clack, drawer roll and thump, then the little bell.
clack = highpass(rng.standard_normal(int(RATE * 0.03)), 1800) * np.exp(-t_axis(0.03) / 0.006)
roll_t = t_axis(0.22)
roll = lowpass(rng.standard_normal(len(roll_t)), 900) * (0.6 + 0.4 * np.sin(2 * np.pi * 38 * roll_t)) * env(roll_t, 0.02, 0.12)
thump = np.sin(2 * np.pi * 95 * t_axis(0.18)) * np.exp(-t_axis(0.18) / 0.05)
ding = bell_tone(2093.0, 1.4, [(1, 1, 1), (2.4, 0.3, 0.4), (3.9, 0.12, 0.25)], 0.45)
register = mix(clack, delayed(clack * 0.7, 0.07), delayed(roll * 0.8, 0.1), delayed(thump * 0.9, 0.3), delayed(ding * 0.7, 0.34))
write("register", register, 0.75)

# Footsteps: a soft heel thud and a short brush; carpet is dull, stone a little brighter.
for i in range(4):
    t = t_axis(0.16)
    thud = np.sin(2 * np.pi * (70 + 12 * i) * t) * np.exp(-t / 0.035)
    brush = lowpass(rng.standard_normal(len(t)), 1400 + 200 * i) * env(t, 0.004, 0.03)
    write("step_carpet_%d" % i, thud * 0.8 + brush * 0.5, 0.5)
    click = highpass(rng.standard_normal(len(t)), 2200) * env(t, 0.001, 0.012)
    write("step_stone_%d" % i, thud * 0.6 + brush * 0.3 + click * 0.35, 0.55)

# Reflect: a bright flat "tock" of the blade on card, rising.
t = t_axis(0.5)
reflect = bell_tone(1175, 0.5, [(1, 1, 1), (1.5, 0.5, 0.6), (2.0, 0.3, 0.4)], 0.12) + 0.5 * highpass(rng.standard_normal(len(t)), 3000) * np.exp(-t / 0.01)
write("reflect", reflect, 0.6)

# Interaction confirm: a small wooden "tick" for examining things.
t = t_axis(0.12)
write("interact", np.sin(2 * np.pi * 660 * t) * np.exp(-t / 0.03) + 0.4 * np.sin(2 * np.pi * 990 * t) * np.exp(-t / 0.02), 0.4)

# Store ambience: low air and a far, soft murmur, 24 s, crossfaded to loop seamlessly.
dur = 24.0
n = int(RATE * dur)
air = lowpass(rng.standard_normal(n + RATE * 2), 220)
murmur_src = lowpass(rng.standard_normal(n + RATE * 2), 700)
swell = 0.5 + 0.5 * np.sin(2 * np.pi * np.arange(len(murmur_src)) / RATE / 6.0 + 1.0)
amb = air * 1.0 + murmur_src * swell * 0.35
xf = RATE * 2
loop = amb[:n].copy()
loop[:xf] = loop[:xf] * np.linspace(0, 1, xf) + amb[n:n + xf] * np.linspace(1, 0, xf)
write("amb_store", loop, 0.35)
