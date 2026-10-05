// Ingests a reviewed ChatGPT-generated image into the repository.
// Usage:
//   node scripts/ingest-art.mjs world:<id> <source.png> --reviewed
//   node scripts/ingest-art.mjs mask:<id>:<angle> <source.png> --reviewed
// Writes optimized WebP sizes listed in the manifest, then marks the entry `approved`.
// Requires ImageMagick (`magick` or `convert`) with WebP support.
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { execFileSync } from 'node:child_process';

const [key, source, ...flags] = process.argv.slice(2);
const fail = msg => { console.error(`ingest-art: ${msg}`); process.exit(1); };

if (!key || !source) fail('usage: node scripts/ingest-art.mjs <world:id | mask:id:angle> <source image> --reviewed');
if (!flags.includes('--reviewed')) fail('refusing to ingest: pass --reviewed once the image has passed the QC checklist in ASSET_PIPELINE.md.');
if (!existsSync(source)) fail(`source image not found: ${source}`);

const manifestPath = 'data/art-manifest.json';
const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
const [kind, id, angle] = key.split(':');

let entry, kindSizes;
if (kind === 'world') {
  entry = manifest.worlds.find(w => w.id === id);
  kindSizes = manifest.sizes.world;
} else if (kind === 'mask') {
  entry = manifest.masks.find(m => m.id === id)?.views.find(v => v.angle === angle);
  kindSizes = manifest.sizes.mask;
} else fail(`unknown asset kind "${kind}"`);
if (!entry) fail(`no manifest entry for ${key}`);

const tool = ['magick', 'convert'].find(t => { try { execFileSync(t, ['-version'], { stdio: 'ignore' }); return true; } catch { return false; } });
if (!tool) fail('ImageMagick not found (need `magick` or `convert`).');

const identify = execFileSync(tool, [source, '-format', '%w %h %A', 'info:']).toString().trim().split(' ');
const [width, height] = identify.map(Number);
if (kind === 'mask' && !/true|blend/i.test(identify[2])) console.warn('ingest-art: warning — mask source has no alpha channel; masks should be transparent PNGs.');

for (const size of kindSizes) {
  const out = entry.files[size];
  mkdirSync(dirname(out), { recursive: true });
  // `>` only shrinks; never upscale past the generated resolution.
  execFileSync(tool, [source, '-strip', '-resize', `${size}x${size}>`, '-quality', size <= 400 ? '78' : '82', '-define', 'webp:method=6', '-define', 'webp:alpha-quality=90', out]);
  console.log(`  wrote ${out}`);
}

entry.status = 'approved';
entry.approved = { at: new Date().toISOString().slice(0, 10), source: { width, height }, generator: manifest.generator };
writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
console.log(`ingest-art: ${key} approved. Run \`npm run prompts\` and \`npm run validate\`.`);
