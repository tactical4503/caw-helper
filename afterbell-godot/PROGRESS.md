# AFTERBELL — chapter progress log

Source of truth: the Installment 002 bible (the user's first message in the build session,
"Closing Time: Bellwether's Department Store", canon 0.2), plus this folder's README and code.
Visual target: the user's department-store reference (4:3, golden bell on the MENSWEAR
mezzanine, foreground perfume counters, cream-bordered teal carpet, plum flower table).
Undocumented additions are listed under **Proposals** below, not treated as canon.

## Scope decision
Build one finished, playable **chapter** from what exists, not new rooms:
Title → DS-01 Cosmetics → DS-02 Hats → DS-03 Alterations / DS-04 Receiving → the Floor
Manager's court (DS-10, `main.tscn`, inside the atrium) → victory, reward, chapter end → title.
The atrium (DS-05) is experienced as the court's surroundings. Vestibule, upper landing,
linens, toys and the service passage stay out of scope until this chapter is finished.

## Prioritized task list
1. **Atrium / court view to the reference** (first milestone)
   - [ ] 4:3 presentation and a repeatable comparison camera (`tools/room_shots.gd`).
   - [ ] Golden service bell clearly visible: the grand bell on the MENSWEAR mezzanine, linked by
         cable to the court's striking stand; tall SERVICE board removed; bell partition lowered.
   - [ ] Floor Manager starts off the bell's sightline (function unchanged).
   - [ ] Broad cream borders around carpet sections instead of thin white lines.
   - [ ] Central flower arrangement visible on the aisle axis.
   - [ ] Foreground stocked counters framing the court's south corners.
   - [ ] Larger botanical banner artwork, fuller palms, coordinated storefront displays.
2. **Game shell**
   - [ ] Title screen (in-engine store view): New game / Continue / Controls / Quit.
   - [ ] Pause menu (Esc): resume, controls, volume sliders, restart checkpoint, quit to title.
   - [ ] Chapter checkpoint save per room (user://), reliable Continue.
   - [ ] Chapter-end screen with reward; return to title. Dev labels hidden in play.
3. **Chapter flow and charm**: objective chain synced across rooms; department chime on
   errands; cash register on reward; bell response; inspectables; second-line reactions.
4. **Assets**: mannequin bodies and hands; Leather Goods stock (handbags, belts, wallets,
   luggage); Meshy only for distinctive missing props (one candidate each).
5. **Audio**: footsteps, UI, interaction, ambience, encounter; levels tuned together.
6. **Verification**: tests, comparison renders, moving viewpoints, performance, export.

## Current task
Milestone 1: atrium / court view.

## Next exact action
Restore the stashed bell work (`git stash list`, "bell landmark WIP") and rework it into the
mezzanine bell + court striking stand.

## Completed and verified
- Checkpoint branch `checkpoint/pre-chapter` pushed at e5b1c5b (tags are refused by the remote).
- Engine: Godot 4.3 stable, Forward+ (MSAA 2x). Boots clean under a real renderer; headless
  runs print "Parameter m is null" from mesh baking without a renderer (harmless, headless-only).
- Forward+ renders in this container via Mesa lavapipe (`VK_ICD_FILENAMES=.../lvp_icd.json`).

## Changed files and asset paths
(updated per milestone)

## Meshy jobs
None yet.

## Known defects and blockers
- Atrium lighting: a clipped white line on the left escalator under the current key angle.
- The four-image comparison sheet mentioned in the brief was not attached; the department-store
  reference image is used instead.

## Proposals (not canon)
- The grand bell sits on the MENSWEAR mezzanine (as in the reference) and is rung through a
  cable from the court's striking stand; the bible puts the stand in a north-wall recess.
