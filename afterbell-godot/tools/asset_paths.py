"""Checks that every res:// path named in the project's scripts and scenes exists on disk.

Paths under assets/imports/ are the local-only package models (gitignored); the game skips them
when absent, so a missing one is reported as optional, not a failure.

    python3 tools/asset_paths.py            (run from afterbell-godot/)
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PAT = re.compile(r'res://([A-Za-z0-9_\-./ ()]+?\.(?:gd|tscn|tres|png|jpg|glb|gltf|obj|fbx|wav|ogg|ttf|otf|json))')

missing, optional, checked = [], [], set()
for folder in ["scripts", "rooms", "rigs", "."]:   # game code (tests name a fake room on purpose)
    base = os.path.join(ROOT, folder)
    for name in os.listdir(base):
        if not os.path.isfile(os.path.join(base, name)) or not name.endswith((".gd", ".tscn", ".godot", ".cfg")):
            continue
        text = open(os.path.join(base, name), encoding="utf-8", errors="replace").read()
        for m in PAT.finditer(text):
            rel = m.group(1)
            if "%" in rel or rel in checked:
                continue
            checked.add(rel)
            if not os.path.exists(os.path.join(ROOT, rel)):
                (optional if rel.startswith("assets/imports/") else missing).append(f"{name}: res://{rel}")

print(f"asset paths: {len(checked)} checked, {len(missing)} missing, {len(optional)} optional absent")
for m in missing:
    print("  MISSING", m)
for m in optional:
    print("  optional", m)
sys.exit(1 if missing else 0)
