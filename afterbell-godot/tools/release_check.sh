#!/usr/bin/env bash
# Release gate for AFTERBELL: every check must pass before a build ships.
#   GODOT=/path/to/godot tools/release_check.sh [--export]
# 1. the six headless test suites; 2. every res:// path exists; 3. every scene runs with a real
# renderer and no script errors; 4. (--export) Linux and Windows exports, and the Linux build
# boots the title and the court with no script errors.
set -u
cd "$(dirname "$0")/.."
G="${GODOT:-godot}"
RENDER=(env VK_ICD_FILENAMES="${VK_ICD_FILENAMES:-/usr/share/vulkan/icd.d/lvp_icd.json}")
# Reuse an explicitly supplied display (including a TCP Xvfb in containers
# that do not expose Unix sockets). Otherwise create a temporary display.
if [[ -z "${DISPLAY:-}" ]]; then RENDER+=(xvfb-run -a); fi
fail=0
note() { printf '%-28s %s\n' "$1" "$2"; }

for t in room_test hats_test alterations_test sim_test paths_test chapter_test; do
	out=$("$G" --headless --path . -s "tests/$t.gd" 2>&1)
	if grep -q "RESULT: PASS" <<<"$out" && ! grep -q "SCRIPT ERROR" <<<"$out"; then note "$t" PASS
	else note "$t" FAIL; fail=1; grep -E "FAIL|SCRIPT ERROR" <<<"$out" | head -5; fi
done

if python3 tools/asset_paths.py; then note "asset paths" PASS; else note "asset paths" FAIL; fail=1; fi

out=$("${RENDER[@]}" "$G" --rendering-driver vulkan --path . -s res://tests/geometry_test.gd 2>&1)
if grep -q "RESULT: PASS" <<<"$out" && ! grep -q "SCRIPT ERROR" <<<"$out"; then note "geometry (rendered)" PASS
else note "geometry (rendered)" FAIL; fail=1; grep -E "FAIL|SCRIPT ERROR" <<<"$out" | head -5; fi

out=$("${RENDER[@]}" "$G" --rendering-driver vulkan --path . -s res://tools/scene_check.gd 2>&1)
if grep -q "SCENE CHECK: all" <<<"$out" && ! grep -qE "SCRIPT ERROR|SCENE CHECK FAIL|Failed loading resource" <<<"$out"; then
	note "scenes (rendered)" PASS
else note "scenes (rendered)" FAIL; fail=1; grep -E "SCRIPT ERROR|FAIL|Failed loading" <<<"$out" | sort | uniq -c | head -8; fi

if [[ "${1:-}" == "--export" ]]; then
	"$G" --headless --path . --export-release "Linux" ../build/linux/AFTERBELL.x86_64 >/dev/null 2>&1
	"$G" --headless --path . --export-release "Windows" ../build/windows/AFTERBELL.exe >/dev/null 2>&1
	[[ -s ../build/linux/AFTERBELL.x86_64 && -s ../build/windows/AFTERBELL.exe ]] && note "exports" PASS || { note "exports" FAIL; fail=1; }
	for sc in "" res://main.tscn; do
		out=$(cd ../build/linux && "${RENDER[@]}" ./AFTERBELL.x86_64 --rendering-driver vulkan $sc --quit-after 60 2>&1)
		if grep -q "SCRIPT ERROR" <<<"$out"; then note "boot ${sc:-title}" FAIL; fail=1; else note "boot ${sc:-title}" PASS; fi
	done
fi

[[ $fail == 0 ]] && echo "RELEASE CHECK: PASS" || echo "RELEASE CHECK: FAIL"
exit $fail
