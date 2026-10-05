// Renders ASSET_PROMPTS.md (copy-paste ChatGPT image prompts) from data/art-manifest.json.
// Usage: node scripts/build-prompts.mjs
import { readFileSync, writeFileSync } from 'node:fs';

const manifest = JSON.parse(readFileSync('data/art-manifest.json', 'utf8'));

const ORIGINALITY = 'Create a completely original design. Do not reproduce or imitate a specific real wrestler, existing wrestling mask, copyrighted artwork, brand, game interface, or recognizable character. No text, lettering, numbers, logos or watermarks anywhere in the image.';
const QUALITY = 'Premium cinematic production artwork. Physically believable. Carefully designed. No generic AI fantasy art. No random details. No visual artifacts. This is artwork content only — not a user interface, not a screenshot, no buttons, panels or HUD elements.';
const LANGUAGE = 'CAW Helper visual language: grand, tactile, archival, theatrical, wrestling-history inspired; black, warm paper, bone, muted red, steel and restrained gold; real materials, controlled composition, atmospheric depth. Not cyberpunk, not glossy fantasy, not a stock photo.';

const worldPrompt = w => `Create an original environment illustration specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
${w.ui}

Subject:
${w.subject}

Composition:
${w.composition}

Physical construction:
${w.construction}

Lighting:
${w.lighting}

Color:
${w.color}

Atmosphere:
${w.atmosphere}

Design language:
${LANGUAGE}

Originality:
${ORIGINALITY}

Quality:
${QUALITY} Photoreal cinematic still, no people.

Output:
${w.aspect}.`;

const maskFrontPrompt = m => `Create an original wrestling mask product render specifically for CAW Helper, a fan-made wrestling character-creation platform.

Purpose:
Primary object art for the "${m.name}" mask in the Mask Archive wall, the inspector and the study view. This is the FRONT view; four more angles will be generated from it.

Subject:
${m.concept} It must read as a real, physically constructed, wearable wrestling mask (a full fabric/leather hood that covers the whole head), mounted on an invisible head form so it holds full head volume with a hollow, slightly visible neck opening.

Silhouette:
${m.silhouette}

Physical construction:
${m.construction}

Eye openings:
${m.eyes}

Mouth treatment:
${m.mouth}

Surface and materials:
${m.surface} Show panel seams, stitch lines, edge thickness where panels overlap, and how each material responds to light.

Composition:
FRONT view. Camera dead-on at eye level, 85mm product lens, mask centred with about 12% empty margin on every side.

Lighting:
Studio product lighting: large soft key from upper left, gentle fill from the right, crisp rim light from behind to separate the silhouette, soft self-shadowing in the eye sockets and under the brow.

Color:
${m.palette.replace(/\.$/, "")}. Keep the palette controlled; no extra accent colours.

Background:
Fully transparent background (PNG with alpha). No floor, no pedestal, no cast shadow on a surface.

Personality:
${m.personality}

Originality:
${ORIGINALITY}

Quality:
${QUALITY}

Output:
1:1 square, 1024×1024, transparent PNG.`;

const maskViewPrompt = (m, v) => `Using the attached approved FRONT image of the CAW Helper "${m.name}" mask as the exact design reference, render the SAME mask — identical construction, panels, seams, materials, colours, eye and mouth shapes — from a new angle. Do not redesign, add or remove any element.

View: ${v.label}
Camera: ${v.camera}

Keep the same studio product lighting (soft key upper left relative to the camera, gentle fill, crisp rim), the same 85mm lens, the same scale in frame, the same invisible head form, and a fully transparent background (PNG with alpha), no floor, no pedestal.

Wrestling-mask construction reminders: ${m.construction}

${ORIGINALITY}
${QUALITY}

Output: 1:1 square, 1024×1024, transparent PNG.`;

const status = s => (s === 'approved' ? '[x] approved' : '[ ] needs generation');
const out = [];
out.push(`# CAW Helper — ChatGPT Image Generation Prompts

Generated from \`data/art-manifest.json\` by \`node scripts/build-prompts.mjs\`. Do not edit by hand; edit the manifest and rebuild.

Workflow for every asset: **generate → inspect against the QC checklist in ASSET_PIPELINE.md → revise → ingest** with
\`node scripts/ingest-art.mjs <key> <downloaded.png> --reviewed\`.

## Checklist

### World art (${manifest.worlds.filter(w => w.status === 'approved').length}/${manifest.worlds.length} approved)
`);
for (const w of manifest.worlds) out.push(`- ${status(w.status)} \`world:${w.id}\` — ${w.title}`);
const views = manifest.masks.flatMap(m => m.views);
out.push(`\n### Masks (${views.filter(v => v.status === 'approved').length}/${views.length} views approved)\n`);
for (const m of manifest.masks) out.push(`- **${m.name}**: ${m.views.map(v => `${v.status === 'approved' ? '✔' : '☐'} ${v.angle}`).join(' · ')}`);

out.push('\n---\n\n## World art prompts\n');
for (const w of manifest.worlds) {
  out.push(`### \`world:${w.id}\` — ${w.title}

| | |
|---|---|
| What is it? | ${w.what} |
| Why does it exist? | ${w.why} |
| Where is it used? | ${w.ui} |
| What does it communicate? | ${w.communicates} |
| How does it differ? | ${w.differs} |
| Files | ${Object.values(w.files).map(f => `\`${f}\``).join(', ')} |

\`\`\`text
${worldPrompt(w)}
\`\`\`
`);
}

out.push('---\n\n## Mask prompts\n\nGenerate the FRONT first. After it passes review, attach it to each of the other four prompts so all angles stay the same object.\n');
for (const m of manifest.masks) {
  out.push(`### ${m.name} (\`mask:${m.id}:<angle>\`)

${m.concept} — *${m.personality}*

#### FRONT — \`mask:${m.id}:front\`

\`\`\`text
${maskFrontPrompt(m)}
\`\`\`
`);
  for (const v of m.views.filter(v => v.angle !== 'front')) {
    out.push(`#### ${v.label} — \`mask:${m.id}:${v.angle}\` (attach the approved front image)

\`\`\`text
${maskViewPrompt(m, v)}
\`\`\`
`);
  }
}

writeFileSync('ASSET_PROMPTS.md', out.join('\n'));
console.log(`ASSET_PROMPTS.md written: ${manifest.worlds.length} worlds, ${views.length} mask views.`);
