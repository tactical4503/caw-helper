# AFTERBELL — Installment 002 greybox

Playable greybox of **BS-01, the Floor Manager** (Menswear Court, DS-10) from *Closing Time: Bellwether's Department Store*.

Open `index.html` directly in a browser. There is no build step and no network access: Three.js r160 is vendored in `vendor/` (MIT, see `vendor/THREE_LICENSE.txt`).

## What is implemented
- DS-10 arena at its specified 16 × 18 m size, laid out in the building coordinates (bell stand at x18,y38, low bumper-operated lever per CAN-027, three carpet inlays, six shoe plinths, two racks, waist-high atrium barrier, west retreat door).
- The full loop: "Please read" → sign thrown at 5 m/s → reflect it (0.18 s window, or held-guard assist) → 5.5 s exposure (8 s on easy) → 0.8 s wound heavy strike from the paddle side → up to 30° steering (50° on easy) → bell collision → a service tab drops. Three bells and the fight is won. The boss has no hidden health pool.
- Wrong-side strike: the chair rolls into a padded stop. Light hits on the locked chair knock dully and show "The chair is locked." There are no damage numbers.
- Close hand sweep (stand within 3 m for 2 s): 1.1 s tell, 100° arc, 2.6 m reach. Phase 2 rack shove in one marked lane (1.2 s rattle tell, 3 m/s). Phase 3 uses the faster single sign (CAN-026 default).
- Six health segments, two biscuits, retreat, defeat/retry, victory dialogue, Store Governor Q-01 reward card.
- Options: easy assist, reflection assist (T toggles it in play), aiming arrow, keep boss progress, camera shake. Touch controls appear on touch devices.

## Not done
- There is no art or animation beyond primitive stand-ins and procedural poses, and sound is synthesized beeps. Mika and Nell are voices only. The rest of the store has not been built.
- Tuning values come from the design table and are **untested with players**.

## Verification
Simulation logic was checked headlessly in Chromium (`?debug` exposes a fixed-step hook). Checks covered timed reflection without assist, three bells to victory, a wrong-side roll, the locked-chair hint, the sweep hit, the rack shove hit and defeat. It was also screenshotted at desktop and phone sizes. Real-time feel has not been playtested.
