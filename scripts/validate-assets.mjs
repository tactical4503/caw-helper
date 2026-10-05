// Verifies every local asset reference, the art manifest, and the placeholder ban.
// Usage: node scripts/validate-assets.mjs   (exit code 1 on any error)
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';

const errors = [];
const warn = [];
const RUNTIME = ['index.html', 'app.js', 'styles.css'];

// 1. Every literal local path referenced by the runtime exists.
const PATH_RE = /(?:assets|data)\/[A-Za-z0-9_\-./]+\.(?:svg|webp|png|jpe?g|avif|json)/g;
for (const file of RUNTIME) {
  const src = readFileSync(file, 'utf8');
  for (const ref of new Set(src.match(PATH_RE) || [])) if (!existsSync(ref)) errors.push(`${file}: missing ${ref}`);
  // 2. No remote images: only the Google Fonts stylesheet may be external.
  for (const url of src.match(/https?:\/\/[^\s'")]+/g) || []) if (!url.startsWith('https://fonts.googleapis.com/')) errors.push(`${file}: external URL ${url}`);
  // 3. Placeholder ban (the HTML input `placeholder=` attribute is a real control, not art).
  const scrubbed = src.replace(/placeholder="[^"]*"/g, '');
  for (const term of ['placeholder', 'unsplash', 'image1', 'test.jpg', 'dummy', 'coming soon', 'TODO', '/mnt/data'])
    if (scrubbed.toLowerCase().includes(term.toLowerCase())) errors.push(`${file}: forbidden term "${term}"`);
}

// 4. Asset filenames must be meaningful.
const walk = d => readdirSync(d).flatMap(f => (statSync(join(d, f)).isDirectory() ? walk(join(d, f)) : [join(d, f)]));
for (const f of walk('assets'))
  if (/(placeholder|dummy|temp|stock|unsplash|image\d|final\d*|newimage|test)\.[a-z]+$/i.test(f)) errors.push(`bad asset name: ${f}`);

// 5. Manifest integrity.
const manifest = JSON.parse(readFileSync('data/art-manifest.json', 'utf8'));
const appIds = [...readFileSync('app.js', 'utf8').matchAll(/^\s*\['([a-z-]+)','/gm)].map(m => m[1]);
const manifestIds = manifest.masks.map(m => m.id);
for (const id of appIds) if (!manifestIds.includes(id)) errors.push(`app.js mask "${id}" has no manifest entry`);
for (const id of manifestIds) if (!appIds.includes(id)) errors.push(`manifest mask "${id}" is not in app.js`);

const check = (label, entry) => {
  const files = Object.values(entry.files);
  if (entry.status === 'approved') {
    for (const f of files) if (!existsSync(f)) errors.push(`${label} is approved but ${f} is missing`);
  } else if (entry.status === 'needs-generation') {
    if (files.some(existsSync)) warn.push(`${label} has files on disk but is not approved`);
  } else errors.push(`${label}: unknown status "${entry.status}"`);
};
for (const w of manifest.worlds) {
  check(`world:${w.id}`, w);
  if (w.current && !existsSync(w.current)) errors.push(`world:${w.id} current art missing: ${w.current}`);
}
for (const m of manifest.masks) {
  if (!existsSync(m.current)) errors.push(`mask:${m.id} current art missing: ${m.current}`);
  if (m.model3d && !existsSync(m.model3d)) errors.push(`mask:${m.id} model missing: ${m.model3d}`);
  for (const v of m.views) check(`mask:${m.id}:${v.angle}`, v);
}

// Summary.
const views = manifest.masks.flatMap(m => m.views);
const approvedWorlds = manifest.worlds.filter(w => w.status === 'approved').length;
const approvedViews = views.filter(v => v.status === 'approved').length;
console.log(`Generated art: worlds ${approvedWorlds}/${manifest.worlds.length}, mask views ${approvedViews}/${views.length}.`);
if (approvedWorlds < manifest.worlds.length || approvedViews < views.length) console.log('Outstanding assets are listed in ASSET_PROMPTS.md.');
for (const w of warn) console.warn(`warning: ${w}`);
if (errors.length) {
  for (const e of errors) console.error(`error: ${e}`);
  process.exit(1);
}
console.log('Asset validation passed.');
