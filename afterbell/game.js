/* AFTERBELL — Installment 002 greybox: BS-01 The Floor Manager (Menswear Court, DS-10).
   Zero-build. Uses the vendored global THREE (r160). Values come from the Installment 002
   timing table and are untested design targets. */
(() => {
'use strict';

const $ = s => document.querySelector(s);
const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const lerp = (a, b, t) => a + (b - a) * t;
const damp = (a, b, k, dt) => lerp(a, b, 1 - Math.exp(-k * dt));
const wrap = a => { while (a > Math.PI) a -= 2 * Math.PI; while (a < -Math.PI) a += 2 * Math.PI; return a; };
const dampAngle = (a, b, k, dt) => a + wrap(b - a) * (1 - Math.exp(-k * dt));
const yawTo = (fx, fz, tx, tz) => Math.atan2(tx - fx, tz - fz);
const dist = (ax, az, bx, bz) => Math.hypot(bx - ax, bz - az);
const DEG = Math.PI / 180;

// Building coordinates (Section 3: x east, y north, metres) -> world (x east, -z north).
// The court DS-10 spans x10–26, y22–40, so its centre (18,31) is the world origin.
const B = (x, y) => ({ x: x - 18, z: -(y - 31) });
const BELL = B(18, 38);                 // bell stand, shallow north-wall recess
const LEVER = { x: BELL.x, z: BELL.z + 0.9 }; // protruding low lever the bumper strikes (CAN-027)
const MARK = B(18, 32.5);               // presentation mark
const ENTRY = { x: -6.6, z: 7.4 };      // west door near the south-west corner
const BOUNDS = { minX: -7.6, maxX: 7.6, minZ: -5.6, maxZ: 8.6 };
const RACK_LANE_Z = 3.6;

// Section 11 timing table.
const T = {
  signTell: 1.0, signSpeed: 5, signSpeedP3: 6.5, reflectWindow: 0.18, missRecover: 1.3,
  sweepTell: 1.1, sweepArc: 100 * DEG, sweepReach: 2.6, sweepRecover: 1.4, sweepCloseTime: 2.0,
  rackTell: 1.2, rackSpeed: 3, rackRecover: 1.8,
  exposed: 5.5, exposedEasy: 8, heavyCharge: 0.8, playerRecover: 0.5,
  bellSettle: 0.4, phaseScene: 2.5, phaseSceneRepeat: 1.0,
  steer: 30 * DEG, steerEasy: 50 * DEG, launchSpeed: 7.5, freeze: 0.06
};

const settings = { easy: false, reflectAssist: false, aimHelp: false, keepProgress: false, shake: true };

/* ---------------- Audio: small synthesized cues, no external files ---------------- */
const Sfx = {
  ctx: null, out: null,
  init() {
    if (this.ctx) { this.ctx.resume(); return; }
    const C = window.AudioContext || window.webkitAudioContext;
    if (!C) return;
    this.ctx = new C();
    const comp = this.ctx.createDynamicsCompressor();
    comp.threshold.value = -16; comp.ratio.value = 4;
    this.out = this.ctx.createGain(); this.out.gain.value = 0.55;
    this.out.connect(comp); comp.connect(this.ctx.destination);
  },
  tone(f, dur, type = 'sine', vol = 0.25, when = 0, f2 = null) {
    if (!this.ctx) return;
    const t = this.ctx.currentTime + when;
    const o = this.ctx.createOscillator(), g = this.ctx.createGain();
    o.type = type; o.frequency.setValueAtTime(f, t);
    if (f2) o.frequency.exponentialRampToValueAtTime(f2, t + dur);
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + 0.006);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    o.connect(g); g.connect(this.out); o.start(t); o.stop(t + dur + 0.05);
  },
  noise(dur, vol = 0.2, freq = 900, q = 1, when = 0) {
    if (!this.ctx) return;
    const t = this.ctx.currentTime + when, n = Math.ceil(this.ctx.sampleRate * dur);
    const buf = this.ctx.createBuffer(1, n, this.ctx.sampleRate), d = buf.getChannelData(0);
    for (let i = 0; i < n; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / n);
    const s = this.ctx.createBufferSource(), f = this.ctx.createBiquadFilter(), g = this.ctx.createGain();
    s.buffer = buf; f.type = 'bandpass'; f.frequency.value = freq; f.Q.value = q; g.gain.value = vol;
    s.connect(f); f.connect(g); g.connect(this.out); s.start(t);
  },
  chime() { this.tone(880, 0.35, 'triangle', 0.22); this.tone(1175, 0.5, 'triangle', 0.22, 0.15); },
  reflect() { this.tone(1175, 0.18, 'triangle', 0.25); this.tone(1568, 0.3, 'triangle', 0.2, 0.06); this.noise(0.06, 0.3, 2500, 3); },
  thud() { this.tone(120, 0.2, 'sine', 0.35); this.noise(0.08, 0.2, 300); },
  knock() { this.tone(210, 0.1, 'square', 0.08); this.noise(0.06, 0.3, 900, 5); },
  click() { this.noise(0.025, 0.35, 3200, 8); },
  swing() { this.noise(0.14, 0.12, 1400, 0.7); },
  heavy() { this.noise(0.2, 0.25, 700, 0.8); this.tone(90, 0.25, 'sine', 0.4); },
  hurt() { this.tone(180, 0.22, 'sawtooth', 0.12, 0, 90); },
  squeak() { this.tone(1900, 0.09, 'sine', 0.05, 0, 2300); },
  rattle() { for (let i = 0; i < 8; i++) this.noise(0.03, 0.18, 1800 + Math.random() * 900, 6, i * 0.13); },
  spring() { this.tone(300, 0.35, 'triangle', 0.15, 0, 1200); },
  pip() { this.tone(1568, 0.11, 'sine', 0.15, 0.05); this.tone(2093, 0.16, 'sine', 0.15, 0.2); },
  bell() { // bright limited transient, short warm tail (Section 12)
    [[1, 0.22, 2.2], [2.0, 0.09, 1.4], [2.76, 0.07, 1.0], [5.4, 0.04, 0.5], [8.9, 0.025, 0.25]]
      .forEach(([m, v, d]) => this.tone(523 * m, d, 'sine', v));
    this.noise(0.04, 0.25, 4000, 2);
  }
};

/* ---------------- Renderer & scene ---------------- */
const canvas = $('#view');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.05;

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x1a1218);
scene.fog = new THREE.Fog(0x1a1218, 26, 48);
const camera = new THREE.PerspectiveCamera(46, 1, 0.1, 100);

const C = {
  cream: 0xefe3c8, ivory: 0xe6dccb, plum: 0x5b2a4a, plumDeep: 0x3a1a2f, carpet: 0x2f4a3a,
  carpetLight: 0x3d5e4a, brass: 0xb58d3f, red: 0xb0302a, black: 0x17161b, gray: 0x8c8378,
  wood: 0x8a6440, tile: 0xd8ccb0, steel: 0x9aa0a6, dark: 0x0c0a0d
};
const matCache = {};
function mat(color, rough = 0.7, metal = 0) {
  const k = color + ':' + rough + ':' + metal;
  return matCache[k] || (matCache[k] = new THREE.MeshStandardMaterial({ color, roughness: rough, metalness: metal }));
}
const brass = mat(C.brass, 0.35, 0.85);
function mesh(geo, m, x = 0, y = 0, z = 0, parent = null, cast = true) {
  const o = new THREE.Mesh(geo, m);
  o.position.set(x, y, z); o.castShadow = cast; o.receiveShadow = true;
  if (parent) parent.add(o);
  return o;
}
const box = (w, h, d) => new THREE.BoxGeometry(w, h, d);
const cyl = (rt, rb, h, s = 16) => new THREE.CylinderGeometry(rt, rb, h, s);

// Lighting: warm store interior, the bell is the brightest brass object (Section 3).
scene.add(new THREE.HemisphereLight(0xffe9c7, 0x2a1a22, 0.55));
const key = new THREE.DirectionalLight(0xfff0d6, 1.5);
key.position.set(-6, 14, 8); key.castShadow = true;
key.shadow.mapSize.set(2048, 2048);
Object.assign(key.shadow.camera, { left: -12, right: 12, top: 12, bottom: -12, near: 1, far: 40 });
scene.add(key);
const bellLight = new THREE.SpotLight(0xffd59a, 40, 9, 0.5, 0.6, 1.6);
bellLight.position.set(BELL.x, 5.2, BELL.z + 1.2);
bellLight.target.position.set(BELL.x, 1.2, BELL.z);
scene.add(bellLight, bellLight.target);
[[-5, 1], [5, 1], [0, 5]].forEach(([x, z]) => {
  const p = new THREE.PointLight(0xffc98a, 6, 9, 1.8); p.position.set(x, 3.6, z); scene.add(p);
});

/* ---------------- Arena DS-10: 16 m × 18 m ---------------- */
const arena = new THREE.Group(); scene.add(arena);
mesh(box(18, 0.1, 20), mat(C.tile, 0.8), 0, -0.05, 0, arena, false);
mesh(box(16, 0.02, 18), mat(C.carpet, 0.95), 0, 0.01, 0, arena, false);
// Three carpet inlays fan toward the bell: decoration that also reads as approach lanes.
const runner = mat(C.plum, 0.9), runnerEdge = mat(C.cream, 0.9);
mesh(box(4, 0.02, 12), runner, 0, 0.025, LEVER.z + 6.2, arena, false);
[-1, 1].forEach(s => {
  const strip = mesh(box(1.4, 0.02, 10), mat(C.carpetLight, 0.9), s * 4.2, 0.022, LEVER.z + 5.4, arena, false);
  strip.rotation.y = s * 0.33;
  mesh(box(0.08, 0.021, 12), runnerEdge, s * 2.04, 0.03, LEVER.z + 6.2, arena, false);
});
// North wall and recess.
const wallMat = mat(C.plumDeep, 0.85);
mesh(box(16, 4.2, 0.3), wallMat, 0, 2.1, -9.15, arena);
mesh(box(16, 0.18, 0.34), mat(C.cream, 0.6), 0, 0.09, -8.98, arena);
// Low display platform along the north wall, split around the bell recess.
[-1, 1].forEach(s => mesh(box(4.4, 0.32, 1.6), mat(C.wood, 0.6), s * 4.6, 0.16, -8.15, arena));
// West wall with the service door; east waist-high barrier over the atrium; low south wall + gate.
mesh(box(0.3, 2.6, 15.2), wallMat, -8.15, 1.3, -1.4, arena);
mesh(box(0.3, 2.6, 0.6), wallMat, -8.15, 1.3, 8.7, arena);
mesh(box(0.08, 2.2, 1.7), mat(C.wood, 0.5), -8.05, 1.1, 7.4, arena);  // door leaf
mesh(box(0.06, 0.06, 0.4), brass, -7.98, 1.0, 7.0, arena);
mesh(box(0.25, 1.05, 18), mat(C.cream, 0.6), 8.12, 0.52, 0, arena);
mesh(box(0.3, 0.08, 18), brass, 8.12, 1.07, 0, arena);
mesh(box(16, 1.0, 0.25), mat(C.cream, 0.6), 0, 0.5, 9.1, arena);
for (let i = -2; i <= 2; i++) mesh(box(0.05, 1.6, 0.05), brass, i * 0.45, 1.3, 9.1, arena);
// Atrium void beyond the east barrier (background geometry only).
mesh(box(10, 0.1, 30), mat(0x24161f, 1), 14, -4.2, 0, arena, false);
// Six low shoe plinths form the outer edge.
const plinths = [[-7.0, -3.6], [-7.0, 2.4], [7.0, -3.6], [7.0, 2.4], [-3.6, 8.0], [3.6, 8.0]].map(([x, z]) => {
  mesh(box(1.1, 0.5, 1.1), mat(C.cream, 0.6), x, 0.25, z, arena);
  mesh(box(1.14, 0.06, 1.14), mat(C.plum, 0.6), x, 0.52, z, arena);
  mesh(box(0.34, 0.14, 0.14), mat(C.red, 0.5), x, 0.62, z, arena);
  return { x, z, hw: 0.6, hd: 0.6 };
});

// Bell, stand, low lever, governor cabinet and SERVICE sign.
const bellGroup = new THREE.Group(); bellGroup.position.set(BELL.x, 0, BELL.z); arena.add(bellGroup);
mesh(cyl(0.5, 0.6, 0.12, 24), mat(C.black, 0.4), 0, 0.06, 0, bellGroup);
mesh(cyl(0.09, 0.11, 1.25, 12), mat(0x3b3430, 0.5, 0.4), 0, 0.68, 0, bellGroup);
const bellPts = [];
for (let i = 0; i <= 14; i++) { const t = i / 14; bellPts.push(new THREE.Vector2(0.72 * Math.sin(t * Math.PI / 2) + 0.02, 0.62 * Math.cos(t * Math.PI / 2))); }
const bellDome = mesh(new THREE.LatheGeometry(bellPts, 40), mat(0xd9ae55, 0.22, 1), 0, 1.32, 0, bellGroup);
bellDome.material = new THREE.MeshStandardMaterial({ color: 0xd9ae55, roughness: 0.22, metalness: 1, emissive: 0x3a2508, side: THREE.DoubleSide });
mesh(cyl(0.06, 0.06, 0.12), brass, 0, 1.98, 0, bellGroup);
const leverPivot = new THREE.Group(); leverPivot.position.set(0, 0.42, 0.25); bellGroup.add(leverPivot);
mesh(box(0.1, 0.08, 0.75), mat(0x3b3430, 0.5, 0.5), 0, 0, 0.35, leverPivot);
mesh(box(0.5, 0.36, 0.12), mat(C.red, 0.8), 0, 0, 0.75, leverPivot); // padded striking plate faces south
mesh(box(0.05, 0.9, 0.05), brass, 0.14, 0.42, 0.06, leverPivot);     // linkage rod to plunger
const cabinet = new THREE.Group(); cabinet.position.set(0, 2.85, -0.25); bellGroup.add(cabinet);
mesh(box(1.5, 1.1, 0.5), mat(C.cream, 0.55), 0, 0, 0, cabinet);
const cabDoor = new THREE.Group(); cabDoor.position.set(-0.7, 0, 0.26); cabinet.add(cabDoor);
mesh(box(1.4, 1.0, 0.04), mat(C.cream, 0.45), 0.7, 0, 0, cabDoor);
mesh(box(0.06, 0.2, 0.05), brass, 1.25, 0, 0.03, cabDoor);
const governor = mesh(cyl(0.07, 0.07, 0.3), brass, 0, 0, 0.02, cabinet); governor.rotation.z = Math.PI / 2;
const tabMeshes = [-0.4, 0, 0.4].map(x => mesh(box(0.2, 0.28, 0.04), brass, x, -0.42, 0.3, cabinet));
const tabFalls = [];
const signCanvas = document.createElement('canvas'); signCanvas.width = 512; signCanvas.height = 96;
{ const g = signCanvas.getContext('2d'); g.fillStyle = '#efe3c8'; g.fillRect(0, 0, 512, 96);
  g.strokeStyle = '#5b2a4a'; g.lineWidth = 6; g.strokeRect(8, 8, 496, 80);
  g.fillStyle = '#5b2a4a'; g.font = '56px Georgia, serif'; g.textAlign = 'center'; g.textBaseline = 'middle';
  g.fillText('S E R V I C E', 256, 52); }
const signTex = new THREE.CanvasTexture(signCanvas); signTex.colorSpace = THREE.SRGBColorSpace;
mesh(box(3.2, 0.6, 0.06), new THREE.MeshStandardMaterial({ map: signTex, roughness: 0.6 }), 0, 3.95, -0.3, bellGroup);

// Racks: one chassis, two instances (Section 16 reuse rule).
function buildRack(colors) {
  const g = new THREE.Group();
  const frame = mat(0x2b2b2e, 0.4, 0.7);
  [-0.8, 0.8].forEach(z => { mesh(box(0.05, 1.6, 0.05), frame, 0, 0.85, z, g); mesh(box(0.6, 0.05, 0.05), frame, 0, 0.08, z, g);
    [-0.27, 0.27].forEach(x => mesh(new THREE.SphereGeometry(0.05, 8, 6), mat(C.black, 0.6), x, 0.05, z, g)); });
  mesh(box(0.05, 0.05, 1.7), frame, 0, 1.65, 0, g);
  const cloth = new THREE.Group(); cloth.position.y = 1.62; g.add(cloth);
  colors.forEach((c, i) => mesh(box(0.42, 0.95, 0.12), mat(c, 0.95), 0, -0.5, -0.6 + i * 0.3, cloth));
  mesh(box(0.08, 0.14, 0.3), mat(C.cream, 0.5), 0, 1.05, 0.86, g); // padded handle
  g.userData.cloth = cloth;
  return g;
}
const rackHome = [{ x: -4.9, z: 0.6 }, { x: 4.9, z: 0.6 }];
const racks = rackHome.map((p, i) => {
  const m = buildRack(i ? [C.gray, C.cream, C.plum, C.gray, C.cream] : [C.plum, C.cream, C.gray, C.plum, C.red]);
  m.position.set(p.x, 0, p.z); arena.add(m);
  return { mesh: m, x: p.x, z: p.z, tx: p.x, tz: p.z, state: 'park', dir: 1, hit: false };
});
// The lateral rack channel, painted in once phase two begins.
const laneMarks = new THREE.Group(); laneMarks.visible = false; arena.add(laneMarks);
for (let x = -7.2; x <= 7.2; x += 0.9) {
  mesh(box(0.5, 0.012, 0.08), mat(C.cream, 0.9), x, 0.03, RACK_LANE_Z - 0.95, laneMarks, false);
  mesh(box(0.5, 0.012, 0.08), mat(C.cream, 0.9), x, 0.03, RACK_LANE_Z + 0.95, laneMarks, false);
}

// Optional floor arrow (contextual aiming help).
const aimArrow = new THREE.Group(); aimArrow.visible = false; scene.add(aimArrow);
mesh(box(0.25, 0.01, 1.6), new THREE.MeshBasicMaterial({ color: C.cream, transparent: true, opacity: 0.75 }), 0, 0.05, 0.8, aimArrow, false);
{ const tri = new THREE.Shape(); tri.moveTo(-0.45, 0); tri.lineTo(0.45, 0); tri.lineTo(0, 0.7);
  const a = mesh(new THREE.ShapeGeometry(tri), new THREE.MeshBasicMaterial({ color: C.cream, transparent: true, opacity: 0.75, side: THREE.DoubleSide }), 0, 0.05, 1.6, aimArrow, false);
  a.rotation.x = Math.PI / 2; }

/* ---------------- The Floor Manager (BS-01) ---------------- */
function buildPlacard() {
  const g = new THREE.Group();
  mesh(box(0.92, 0.62, 0.035), mat(C.red, 0.6), 0, 0, -0.005, g);
  mesh(box(0.78, 0.48, 0.04), mat(C.cream, 0.6), 0, 0, 0, g);
  mesh(box(0.5, 0.07, 0.042), mat(C.red, 0.6), 0, 0.08, 0, g);
  mesh(box(0.36, 0.05, 0.042), mat(C.plum, 0.6), 0, -0.08, 0, g);
  return g;
}
function buildManager() {
  const root = new THREE.Group();
  const chair = new THREE.Group(); root.add(chair);
  const metal = mat(0x2d2a2c, 0.4, 0.6);
  for (let i = 0; i < 5; i++) { // five-star base, five casters
    const a = i * 2 * Math.PI / 5, leg = new THREE.Group(); leg.rotation.y = a; chair.add(leg);
    mesh(box(0.06, 0.05, 0.36), metal, 0, 0.12, 0.18, leg);
    mesh(new THREE.SphereGeometry(0.055, 10, 8), mat(C.black, 0.5), 0, 0.055, 0.36, leg);
  }
  mesh(cyl(0.05, 0.05, 0.32), metal, 0, 0.28, 0, chair);
  mesh(cyl(0.34, 0.32, 0.12, 20), mat(C.gray, 0.95), 0, 0.5, 0, chair);
  [-1, 1].forEach(s => { mesh(box(0.05, 0.16, 0.05), metal, s * 0.3, 0.62, 0, chair); mesh(box(0.07, 0.04, 0.3), mat(C.black, 0.6), s * 0.3, 0.71, 0, chair); });
  mesh(box(0.52, 0.16, 0.08), mat(0x6b2620, 0.85), 0, 0.22, 0.38, chair); // padded front bumper
  const paddle = mesh(box(0.3, 0.18, 0.04), mat(C.red, 0.5), 0, 0.42, -0.18, chair);

  const upper = new THREE.Group(); root.add(upper);
  const body = new THREE.Group(); upper.add(body);
  const ivory = mat(C.ivory, 0.45);
  mesh(cyl(0.065, 0.065, 0.95, 12), brass, 0, 1.03, 0, body);
  mesh(cyl(0.16, 0.2, 0.08, 16), brass, 0, 1.5, 0, body);
  mesh(box(0.62, 0.95, 0.34), mat(C.cream, 0.6), 0, 2.0, 0, body);
  [-1, 1].forEach(s => mesh(box(0.025, 0.95, 0.36), mat(C.plum, 0.6), s * 0.17, 2.0, 0.005, body));
  mesh(box(0.64, 0.025, 0.36), mat(C.plum, 0.6), 0, 1.53, 0, body);
  [-1, 1].forEach(s => mesh(box(0.06, 0.9, 0.08), brass, s * 0.42, 2.02, 0, body)); // shoulder rails
  mesh(cyl(0.07, 0.08, 0.16, 10), ivory, 0, 2.53, 0, body);
  const head = new THREE.Group(); head.position.y = 2.82; body.add(head);
  const skull = mesh(new THREE.SphereGeometry(1, 24, 18), ivory, 0, 0, 0, head); skull.scale.set(0.18, 0.29, 0.2);
  [-1, 1].forEach(s => mesh(box(0.07, 0.025, 0.02), mat(C.dark, 0.9), s * 0.07, 0.05, 0.185, head));
  mesh(box(0.1, 0.008, 0.02), mat(C.dark, 0.9), 0, -0.13, 0.17, head);
  mesh(new THREE.CylinderGeometry(0.15, 0.16, 0.06, 20, 1, true), brass, 0, 0.21, 0, head); // crown band
  [-0.08, 0, 0.08].forEach(x => { const h = mesh(new THREE.TorusGeometry(0.045, 0.008, 6, 12, Math.PI * 1.3), brass, x, 0.29, 0, head); h.rotation.z = Math.PI * 0.85; });
  // Price-tag sash: a short rigid chain.
  for (let i = 0; i < 6; i++) {
    const t = mesh(box(0.09, 0.12, 0.01), mat(C.cream, 0.7), -0.24 + i * 0.1, 2.32 - i * 0.14, 0.185, body);
    t.rotation.z = -0.55;
    if (i) mesh(box(0.06, 0.006, 0.006), mat(C.red, 0.7), -0.29 + i * 0.1, 2.39 - i * 0.14, 0.19, body);
  }
  // Six arms: three per rail (upper signs, middle hangers/displays, lower chair).
  const arms = [];
  [1, -1].forEach(s => [2.38, 2.06, 1.74].forEach((y, level) => {
    const sh = new THREE.Group(); sh.position.set(s * 0.47, y, 0); body.add(sh);
    mesh(new THREE.SphereGeometry(0.055, 10, 8), brass, 0, 0, 0, sh);
    mesh(cyl(0.035, 0.03, 0.5, 10), ivory, 0, -0.25, 0, sh);
    const el = new THREE.Group(); el.position.y = -0.5; sh.add(el);
    mesh(new THREE.SphereGeometry(0.04, 8, 6), brass, 0, 0, 0, el);
    mesh(cyl(0.03, 0.026, 0.46, 10), ivory, 0, -0.23, 0, el);
    mesh(new THREE.SphereGeometry(0.05, 10, 8), ivory, 0, -0.5, 0, el);
    arms.push({ sh, el, s, level, rx: 0, rz: 0, ex: 0 });
  }));
  const held = buildPlacard(); body.add(held);
  return { root, chair, upper, body, head, paddle, arms, held };
}
const BOSS = buildManager(); scene.add(BOSS.root);

// Arm poses [raise, spread, elbow] for [upper, middle, lower]; mirrored per rail.
const POSES = {
  idle:        [[-1.0, 0.15, -1.1], [-0.3, 0.35, -0.8], [-0.2, 0.25, -1.3]],
  present:     [[-2.75, 0.12, -0.2], [-0.4, 0.4, -0.9], [-0.2, 0.25, -1.3]],
  throw:       [[-1.2, 0.1, 0.0], [-0.4, 0.4, -0.9], [-0.2, 0.25, -1.3]],
  sweepTell:   [[-1.0, 0.15, -1.1], [-0.1, 1.5, 0.0], [-0.2, 0.25, -1.3]],
  sweepActive: [[-1.0, 0.15, -1.1], [-1.5, 0.3, 0.0], [-0.2, 0.25, -1.3]],
  rack:        [[-1.0, 0.15, -1.1], [-1.35, 0.5, -0.2], [-0.2, 0.25, -1.3]],
  exposed:     [[-2.9, 0.6, -0.5], [-2.6, 0.9, -0.6], [-2.3, 1.0, -0.4]],
  parked:      [[0.05, 0.06, -2.5], [0.05, 0.06, -2.5], [0.05, 0.06, -2.5]]
};

/* ---------------- Ren (SU-01 stand-in) ---------------- */
function buildRen() {
  const root = new THREE.Group();
  const black = mat(C.black, 0.6), lacquer = mat(0x111014, 0.25, 0.3), red = mat(C.red, 0.5), cream = mat(C.cream, 0.6);
  const legs = [-1, 1].map(s => {
    const hip = new THREE.Group(); hip.position.set(s * 0.12, 0.85, 0); root.add(hip);
    mesh(new THREE.CapsuleGeometry(0.075, 0.6, 4, 10), black, 0, -0.38, 0, hip);
    mesh(box(0.15, 0.13, 0.28), red, 0, -0.78, 0.04, hip);
    mesh(box(0.16, 0.04, 0.3), cream, 0, -0.85, 0.04, hip);
    return hip;
  });
  mesh(new THREE.CapsuleGeometry(0.17, 0.42, 4, 12), black, 0, 1.18, 0, root);
  mesh(box(0.34, 0.3, 0.06), lacquer, 0, 1.28, 0.14, root);
  mesh(box(0.36, 0.07, 0.24), mat(0x3a3a3e, 0.4, 0.7), 0, 0.92, 0, root); // belt
  mesh(box(0.1, 0.08, 0.05), brass, 0, 0.92, 0.13, root);
  const head = new THREE.Group(); head.position.y = 1.68; root.add(head);
  mesh(new THREE.SphereGeometry(0.15, 18, 14), lacquer, 0, 0, 0, head);
  // Single sweeping visor band across the front of the helmet.
  mesh(new THREE.SphereGeometry(0.153, 18, 10, Math.PI / 2 - 0.95, 1.9, 1.05, 0.55), mat(0x060608, 0.08, 0.6), 0, 0, 0, head);
  mesh(box(0.02, 0.1, 0.03), mat(C.steel, 0.3, 0.9), 0, -0.01, 0.15, head);
  mesh(box(0.14, 0.06, 0.06), cream, 0, -0.11, 0.1, head);
  [-1, 1].forEach(s => { const f = mesh(box(0.02, 0.07, 0.18), lacquer, s * 0.08, 0.1, -0.13, head); f.rotation.x = -0.4; });
  const armL = new THREE.Group(); armL.position.set(-0.24, 1.42, 0); root.add(armL);
  mesh(new THREE.CapsuleGeometry(0.055, 0.42, 4, 8), black, 0, -0.25, 0, armL);
  mesh(new THREE.SphereGeometry(0.07, 10, 8), cream, 0, -0.52, 0, armL);
  const armR = new THREE.Group(); armR.position.set(0.24, 1.42, 0); root.add(armR);
  mesh(new THREE.CapsuleGeometry(0.055, 0.42, 4, 8), black, 0, -0.25, 0, armR);
  mesh(new THREE.SphereGeometry(0.07, 10, 8), cream, 0, -0.52, 0, armR);
  // Knock: a broad, blunt blade with a usable flat face.
  const sword = new THREE.Group(); sword.position.y = -0.54; armR.add(sword);
  mesh(box(0.05, 0.14, 0.05), mat(0x3b2a20, 0.7), 0, 0, 0, sword);
  mesh(box(0.26, 0.04, 0.06), brass, 0, -0.08, 0, sword);
  mesh(box(0.17, 0.9, 0.035), mat(C.steel, 0.35, 0.85), 0, -0.53, 0, sword);
  mesh(box(0.17, 0.06, 0.036), mat(C.cream, 0.5), 0, -0.98, 0, sword);
  const ring = new THREE.Mesh(new THREE.RingGeometry(0.55, 0.62, 32), new THREE.MeshBasicMaterial({ color: C.cream, transparent: true, opacity: 0 }));
  ring.rotation.x = -Math.PI / 2; ring.position.y = 0.04; root.add(ring);
  return { root, legs, armL, armR, sword, head, ring };
}
const REN = buildRen(); scene.add(REN.root);

/* ---------------- State ---------------- */
const S = { mode: 'title', time: 0, freeze: 0, shake: 0, bells: 0, phase: 1, seen: {}, failedReflects: 0,
  hintedAssist: false, lockedHits: 0, firstExposure: true, signsSaid: 0, victoryT: 0, rewardShown: false };
const P = { x: ENTRY.x, z: ENTRY.z, yaw: 0, hp: 6, biscuits: 2, inv: 0, act: 'none', actT: 0, guard: false,
  guardPressT: -9, charging: false, chargeT: 0, clicks: 0, dodgeCd: 0, dx: 0, dz: 0, kx: 0, kz: 0, walk: 0 };
const M = { x: MARK.x, z: MARK.z - 2, yaw: Math.PI, chairYaw: Math.PI, state: 'enter', t: 1.6, close: 0,
  next: 'sign', pose: 'idle', lx: 0, lz: 0, travel: 0, sweepHit: false, flinch: 0, lower: 0, steerTo: 0 };
let sign = null; // the one active placard

function resetAttempt(keep) {
  Object.assign(P, { x: ENTRY.x, z: ENTRY.z, yaw: 0.6, hp: 6, biscuits: 2, inv: 0, act: 'none', actT: 0,
    charging: false, guard: false, kx: 0, kz: 0 });
  if (!keep) { S.bells = 0; S.phase = 1; }
  Object.assign(M, { x: MARK.x, z: MARK.z - 2, yaw: Math.PI, chairYaw: Math.PI, state: 'enter', t: 1.2,
    close: 0, next: 'sign', pose: 'idle', flinch: 0, lower: 0 });
  S.lockedHits = 0; S.firstExposure = S.bells === 0; S.victoryT = 0; S.rewardShown = false;
  if (sign) { scene.remove(sign.mesh); sign = null; }
  tabMeshes.forEach((t, i) => { t.visible = i >= S.bells; t.position.y = -0.42; t.rotation.set(0, 0, 0); });
  tabFalls.length = 0;
  cabDoor.rotation.y = 0; BOSS.upper.position.y = 0;
  racks.forEach((r, i) => {
    const p = S.phase >= 2 ? (i ? { x: 7.0, z: -5.2 } : { x: -7.2, z: RACK_LANE_Z }) : rackHome[i];
    Object.assign(r, { x: p.x, z: p.z, tx: p.x, tz: p.z, state: 'park', dir: 1 });
  });
  laneMarks.visible = S.phase >= 2;
  subs.length = 0; subT = 0;
  say('MIKA', 'Bell’s behind him. Get his brake open and we can reach the governor.', 3);
  updateHud();
}

/* ---------------- Subtitles & HUD ---------------- */
const subs = []; let subT = 0, subCur = null;
function say(who, text, dur = 2.6) { subs.push({ who, text, dur }); }
function updateSubs(dt) {
  if (subCur) { subT -= dt; if (subT <= 0) subCur = null; }
  if (!subCur && subs.length) { subCur = subs.shift(); subT = subCur.dur; }
  const el = $('#subtitle');
  const html = subCur ? (subCur.who ? `<b>${subCur.who}</b>` : '') + subCur.text : '';
  if (el.innerHTML !== html) el.innerHTML = html;
}
let promptText = '';
function setPrompt(t) { if (t !== promptText) { promptText = t; $('#prompt').textContent = t; } }
function updateHud() {
  $('#health').innerHTML = Array.from({ length: 6 }, (_, i) => `<i class="${i < P.hp ? '' : 'empty'}"></i>`).join('');
  $('#biscuits').innerHTML = '<i></i>'.repeat(P.biscuits);
  [...$('#tabs').children].forEach((t, i) => t.classList.toggle('gone', i < S.bells));
}

/* ---------------- Input ---------------- */
const keys = new Set();
const pressed = new Set();
const KEYMAP = { KeyW: 'up', ArrowUp: 'up', KeyS: 'down', ArrowDown: 'down', KeyA: 'left', ArrowLeft: 'left',
  KeyD: 'right', ArrowRight: 'right', KeyJ: 'attack', KeyK: 'guard', Space: 'dodge', KeyE: 'eat',
  KeyR: 'retreat', Escape: 'pause', KeyT: 'assist' };
function down(a) { if (!keys.has(a)) pressed.add(a); keys.add(a); }
function up(a) { keys.delete(a); }
addEventListener('keydown', e => { const a = KEYMAP[e.code]; if (!a) return; e.preventDefault(); down(a); });
addEventListener('keyup', e => { const a = KEYMAP[e.code]; if (a) up(a); });
canvas.addEventListener('mousedown', e => { down(e.button === 2 ? 'guard' : 'attack'); });
addEventListener('mouseup', e => { up(e.button === 2 ? 'guard' : 'attack'); });
canvas.addEventListener('contextmenu', e => e.preventDefault());
addEventListener('blur', () => keys.clear());

const stick = { x: 0, y: 0, id: null };
const coarse = matchMedia('(pointer: coarse)').matches;
{
  const el = $('#stick'), knob = $('#knob');
  const move = e => { const r = el.getBoundingClientRect();
    let x = (e.clientX - r.left - r.width / 2) / (r.width / 2), y = (e.clientY - r.top - r.height / 2) / (r.height / 2);
    const l = Math.hypot(x, y); if (l > 1) { x /= l; y /= l; }
    stick.x = x; stick.y = y; knob.style.transform = `translate(${x * 40}px, ${y * 40}px)`; };
  el.addEventListener('pointerdown', e => { stick.id = e.pointerId; el.setPointerCapture(e.pointerId); move(e); });
  el.addEventListener('pointermove', e => { if (e.pointerId === stick.id) move(e); });
  const end = () => { stick.id = null; stick.x = stick.y = 0; knob.style.transform = ''; };
  el.addEventListener('pointerup', end); el.addEventListener('pointercancel', end);
  document.querySelectorAll('.tbtns button').forEach(b => {
    b.addEventListener('pointerdown', e => { e.preventDefault(); down(b.dataset.key); });
    ['pointerup', 'pointercancel', 'pointerleave'].forEach(ev => b.addEventListener(ev, () => up(b.dataset.key)));
  });
}

/* ---------------- Combat helpers ---------------- */
function hurtPlayer(n, fx, fz) {
  if (P.inv > 0 || P.act === 'dodge' || S.mode !== 'play') return false;
  P.hp = Math.max(0, P.hp - n); P.inv = 0.9;
  const d = dist(fx, fz, P.x, P.z) || 1;
  P.kx = (P.x - fx) / d * 6; P.kz = (P.z - fz) / d * 6;
  P.charging = false; if (P.act !== 'none') P.act = 'none';
  Sfx.hurt(); addShake(0.12); updateHud();
  if (P.hp <= 0) defeat();
  return true;
}
function addShake(a) { if (settings.shake) S.shake = Math.max(S.shake, a); }
const committed = () => ['present', 'sweepTell', 'sweepActive', 'rackTell', 'rackActive', 'launch'].includes(M.state);

function startExposure() {
  M.state = 'exposed'; M.t = settings.easy ? T.exposedEasy : T.exposed; M.pose = 'exposed';
  M.steerTo = yawTo(M.x, M.z, LEVER.x, LEVER.z);
  Sfx.thud(); Sfx.squeak(); addShake(0.08);
  if (S.firstExposure) { S.firstExposure = false; say('MIKA', 'Brake’s out! Get behind the red paddle — wind it and send him into the bell.', 3.4); }
}
function heavyStrike() {
  if (M.state === 'exposed' && dist(P.x, P.z, M.x, M.z) < 2.8) {
    const d = dist(P.x, P.z, M.x, M.z) || 1;
    const hx = (M.x - P.x) / d, hz = (M.z - P.z) / d;
    const bd = dist(M.x, M.z, LEVER.x, LEVER.z) || 1;
    const bx = (LEVER.x - M.x) / bd, bz = (LEVER.z - M.z) / bd;
    const off = Math.acos(clamp(hx * bx + hz * bz, -1, 1));
    S.freeze = T.freeze; Sfx.heavy(); addShake(0.15);
    if (off <= (settings.easy ? T.steerEasy : T.steer)) {
      // Forgiving steering: the front casters swivel toward the lever; no teleport.
      M.state = 'launch'; M.lx = hx; M.lz = hz; M.steerTo = Math.atan2(bx, bz); M.pose = 'exposed';
    } else {
      M.state = 'wrongRoll'; M.lx = hx; M.lz = hz; M.travel = 0; M.steerTo = Math.atan2(hx, hz);
    }
    return;
  }
  if (dist(P.x, P.z, M.x, M.z) < 2.6) hitLocked(true);
}
function lightStrike() {
  if (dist(P.x, P.z, M.x, M.z) > 2.3) return;
  if (M.state === 'sweepTell') { Sfx.knock(); M.state = 'recover'; M.t = 0.9; M.pose = 'idle'; M.flinch = 1; return; }
  if (M.state === 'exposed') { Sfx.knock(); M.flinch = 0.5; if (!S.seen.windHint) { S.seen.windHint = 1; say('MIKA', 'Not a tap. Hold it — let the spring wind.', 2.4); } return; }
  hitLocked(false);
}
function hitLocked(heavy) {
  Sfx.knock(); M.flinch = heavy ? 1 : 0.6;
  if (++S.lockedHits >= 3 && !S.seen.locked) { S.seen.locked = 1; say('', 'The chair is locked.', 2.2); }
}

function throwSign() {
  const speed = S.phase >= 3 ? T.signSpeedP3 : T.signSpeed;
  const sx = M.x + Math.sin(M.yaw) * 0.6, sz = M.z + Math.cos(M.yaw) * 0.6;
  const d = dist(sx, sz, P.x, P.z) || 1;
  const m = buildPlacard(); scene.add(m);
  sign = { mesh: m, x: sx, y: 1.45, z: sz, vx: (P.x - sx) / d * speed, vz: (P.z - sz) / d * speed, state: 'out', t: 0 };
  m.position.set(sx, 1.45, sz); m.rotation.y = Math.atan2(sign.vx, sign.vz);
  BOSS.held.visible = false;
}
function signResolved(reflected) {
  if (!reflected && M.state === 'waitSign') { M.state = 'recover'; M.t = T.missRecover; M.pose = 'idle'; }
}
function noteFailedReflect() {
  S.failedReflects++;
  if (S.failedReflects >= 3 && !settings.reflectAssist && !S.hintedAssist) {
    S.hintedAssist = true;
    say('NELL', 'He repeats himself. Tap guard right as the bordered sign arrives — or press T to turn on reflection assist.', 4);
  }
}
function updateSign(dt) {
  if (!sign) return;
  const s = sign; s.t += dt;
  if (s.state === 'out') {
    s.x += s.vx * dt; s.z += s.vz * dt;
    s.mesh.rotation.z += dt * 0.6;
    if (dist(s.x, s.z, P.x, P.z) < 0.75 && P.act !== 'dodge') {
      const timed = S.time - P.guardPressT <= T.reflectWindow;
      if (P.guard && (timed || settings.reflectAssist)) {
        s.state = 'back'; Sfx.reflect(); S.freeze = T.freeze; S.failedReflects = 0;
      } else if (P.guard) {
        s.state = 'drop'; Sfx.thud(); noteFailedReflect(); signResolved(false);
      } else {
        hurtPlayer(1, s.x - s.vx, s.z - s.vz); s.state = 'drop'; noteFailedReflect(); signResolved(false);
      }
    } else if (s.t > 5 || Math.abs(s.x) > 9 || Math.abs(s.z) > 10) {
      scene.remove(s.mesh); sign = null; signResolved(false); return;
    }
  } else if (s.state === 'back') {
    const tx = M.x, tz = M.z, d = dist(s.x, s.z, tx, tz);
    const v = 10 * dt;
    s.x += (tx - s.x) / d * Math.min(v, d); s.z += (tz - s.z) / d * Math.min(v, d);
    s.y = damp(s.y, 1.9, 6, dt); s.mesh.rotation.y += dt * 9;
    if (d < 0.55) {
      scene.remove(s.mesh); sign = null;
      if (M.state === 'waitSign' || M.state === 'recover' || M.state === 'idle') startExposure();
      return;
    }
  } else if (s.state === 'drop') {
    s.y = Math.max(0.05, s.y - dt * 3); s.mesh.rotation.x = damp(s.mesh.rotation.x, -Math.PI / 2, 8, dt);
    if (s.t > 2.2) { scene.remove(s.mesh); sign = null; return; }
  }
  s.mesh.position.set(s.x, s.y, s.z);
}

/* ---------------- Manager AI ---------------- */
function idleDuration() { return S.phase >= 3 ? 1.0 : S.phase === 2 ? 1.5 : 2.0; }
function updateManager(dt) {
  M.t -= dt;
  const dP = dist(M.x, M.z, P.x, P.z);
  const faceP = yawTo(M.x, M.z, P.x, P.z);
  const st = M.state;

  if (st === 'enter') {
    M.pose = 'idle';
    if (M.t <= 0) { M.state = 'roll'; if (!S.seen.valued) { S.seen.valued = 1; say('FLOOR MANAGER', 'Valued— … Valued customers. The court is closed for fitting.', 3); } }
  } else if (st === 'roll') {
    const d = dist(M.x, M.z, MARK.x, MARK.z);
    if (d < 0.08) { M.state = 'idle'; M.t = idleDuration(); }
    else {
      const sp = Math.min(2.2 * dt, d);
      M.x += (MARK.x - M.x) / d * sp; M.z += (MARK.z - M.z) / d * sp;
      M.steerTo = yawTo(M.x, M.z, MARK.x, MARK.z);
      if (Math.random() < dt * 1.2) Sfx.squeak();
    }
    M.pose = 'idle';
  } else if (st === 'idle' || st === 'recover') {
    M.pose = 'idle'; M.steerTo = faceP;
    if (dP < 3.0) M.close += dt; else M.close = Math.max(0, M.close - dt);
    if (M.close > T.sweepCloseTime) { M.close = 0; M.state = 'sweepTell'; M.t = T.sweepTell; M.sweepHit = false; }
    else if (M.t <= 0) {
      if (st === 'recover') { M.state = 'idle'; M.t = idleDuration() * 0.5; }
      else if (S.phase >= 2 && M.next === 'rack' && !sign && racks[0].state === 'park') { M.state = 'rackTell'; M.t = T.rackTell; M.next = 'sign'; startRackTell(); }
      else if (!sign) { M.state = 'present'; M.t = T.signTell; Sfx.chime(); if (S.phase >= 2) M.next = 'rack';
        if (S.signsSaid++ < 2) say('FLOOR MANAGER', 'Please read.', 1.1); }
    }
  } else if (st === 'present') {
    M.pose = 'present'; M.steerTo = faceP; BOSS.held.visible = true;
    if (M.t <= 0) { throwSign(); M.state = 'waitSign'; M.pose = 'throw'; M.t = 4; Sfx.swing(); }
  } else if (st === 'waitSign') {
    M.steerTo = faceP; if (M.t < 3.6) M.pose = 'idle';
  } else if (st === 'sweepTell') {
    M.pose = 'sweepTell'; // chair stops; no turning once active
    if (M.t <= 0) { M.state = 'sweepActive'; M.t = 0.2; Sfx.swing(); }
    else M.steerTo = faceP;
  } else if (st === 'sweepActive') {
    M.pose = 'sweepActive';
    if (!M.sweepHit && dP < T.sweepReach + 0.4 && Math.abs(wrap(faceP - M.yaw)) < T.sweepArc / 2) { M.sweepHit = true; hurtPlayer(1, M.x, M.z); }
    if (M.t <= 0) { M.state = 'sweepRecover'; M.t = T.sweepRecover; }
  } else if (st === 'sweepRecover') {
    M.pose = 'idle'; if (M.t <= 0) { M.state = 'idle'; M.t = idleDuration() * 0.6; }
  } else if (st === 'rackTell') {
    M.pose = 'rack'; M.steerTo = yawTo(M.x, M.z, racks[0].x, racks[0].z);
    if (M.t <= 0) { M.state = 'rackActive'; racks[0].state = 'move'; racks[0].hit = false; }
  } else if (st === 'rackActive') {
    M.pose = 'idle'; M.steerTo = faceP;
    if (racks[0].state === 'park') { M.state = 'rackRecover'; M.t = T.rackRecover; }
  } else if (st === 'rackRecover') {
    M.pose = 'idle'; M.steerTo = faceP; if (M.t <= 0) { M.state = 'idle'; M.t = idleDuration() * 0.5; }
  } else if (st === 'exposed') {
    M.pose = 'exposed'; M.steerTo = yawTo(M.x, M.z, LEVER.x, LEVER.z);
    if (M.t <= 0) { M.state = 'recover'; M.t = 1.0; M.pose = 'idle'; Sfx.squeak(); }
  } else if (st === 'launch') {
    M.pose = 'exposed';
    const d = dist(M.x, M.z, LEVER.x, LEVER.z);
    // Steer the travel vector toward the lever over a few tenths of a second.
    const bx = (LEVER.x - M.x) / d, bz = (LEVER.z - M.z) / d;
    M.lx = damp(M.lx, bx, 10, dt); M.lz = damp(M.lz, bz, 10, dt);
    const l = Math.hypot(M.lx, M.lz); M.lx /= l; M.lz /= l;
    M.steerTo = Math.atan2(M.lx, M.lz);
    const sp = T.launchSpeed * dt;
    M.x += M.lx * sp; M.z += M.lz * sp;
    if (d < 0.75) bellCollision();
  } else if (st === 'wrongRoll') {
    const sp = 5 * dt * Math.max(0.2, 1 - M.travel / 2.6);
    M.x = clamp(M.x + M.lx * sp, BOUNDS.minX + 0.9, BOUNDS.maxX - 0.9);
    M.z = clamp(M.z + M.lz * sp, BOUNDS.minZ, BOUNDS.maxZ - 0.9);
    M.travel += sp;
    if (M.travel > 2.4) { M.state = 'stopStun'; M.t = 1.5; Sfx.thud(); say('', 'Wrong side — he hit the padded display stop.', 1.8); }
  } else if (st === 'stopStun') {
    M.pose = 'idle'; if (M.t <= 0) { M.state = 'roll'; M.pose = 'idle'; }
  } else if (st === 'bellScene') {
    M.pose = 'idle'; M.steerTo = faceP;
    if (M.t <= 0) {
      if (S.bells >= 3) { victory(); return; }
      M.state = 'roll';
    }
  } else if (st === 'defeated') {
    M.pose = 'parked';
    M.lower = damp(M.lower, 1, 1.5, dt);
  }

  M.chairYaw = dampAngle(M.chairYaw, M.steerTo, st === 'launch' ? 14 : 5, dt);
  const upperTarget = st === 'exposed' || st === 'launch' ? M.chairYaw : (st === 'sweepActive' ? M.yaw : faceP);
  M.yaw = dampAngle(M.yaw, upperTarget, st === 'defeated' ? 0.6 : 4, dt);
  M.flinch = Math.max(0, M.flinch - dt * 3);
}
function bellCollision() {
  S.bells++; S.freeze = T.freeze; Sfx.bell(); addShake(0.12);
  M.state = 'bellScene'; M.pose = 'idle';
  M.x -= M.lx * 0.4; M.z -= M.lz * 0.4;
  leverKick = 1;
  const tab = tabMeshes[S.bells - 1]; tabFalls.push({ m: tab, v: 0 });
  updateHud();
  const key = 'scene' + S.bells, first = !S.seen[key]; S.seen[key] = 1;
  M.t = T.bellSettle + (first ? T.phaseScene : T.phaseSceneRepeat);
  if (S.bells === 1) {
    if (first) { say('FLOOR MANAGER', 'The bell is for staff.', 2); say('NELL', 'Got the other rack — the service door’s clear!', 2.2); }
    S.phase = 2; laneMarks.visible = true;
    racks[0].tx = -7.2; racks[0].tz = RACK_LANE_Z; racks[0].state = 'reposition';
    racks[1].tx = 7.0; racks[1].tz = -5.2; racks[1].state = 'reposition';
  } else if (S.bells === 2) {
    if (first) { say('', '(His price-tag sash has caught on the lever. He frees it, carefully.)', 2.2); say('MIKA', 'He’s faster now. Same sign, same answer.', 2.2); }
    S.phase = 3;
  }
}
let leverKick = 0;

function startRackTell() { Sfx.rattle(); racks[0].state = 'tell'; racks[0].dir = racks[0].x < 0 ? 1 : -1; }
function updateRacks(dt) {
  racks.forEach((r, i) => {
    if (r.state === 'reposition') {
      const d = dist(r.x, r.z, r.tx, r.tz);
      if (d < 0.05) r.state = 'park';
      else { const sp = Math.min(2.4 * dt, d); r.x += (r.tx - r.x) / d * sp; r.z += (r.tz - r.z) / d * sp; }
    } else if (r.state === 'tell') {
      r.mesh.userData.cloth.rotation.x = Math.sin(S.time * 30) * 0.05; // wheel-swivel shiver
    } else if (r.state === 'move') {
      r.x += r.dir * T.rackSpeed * dt;
      if ((r.dir > 0 && r.x >= 7.2) || (r.dir < 0 && r.x <= -7.2)) { r.x = clamp(r.x, -7.2, 7.2); r.state = 'park'; }
      if (!r.hit && Math.abs(P.x - r.x) < 0.55 && Math.abs(P.z - r.z) < 1.15) {
        if (hurtPlayer(1, r.x - r.dir, P.z)) r.hit = true;
      }
    }
    r.mesh.position.set(r.x, 0, r.z);
    r.mesh.userData.cloth.rotation.z = damp(r.mesh.userData.cloth.rotation.z, r.state === 'move' ? -r.dir * 0.12 : 0, 6, dt);
  });
}

/* ---------------- Player ---------------- */
function updatePlayer(dt) {
  let ix = (keys.has('right') ? 1 : 0) - (keys.has('left') ? 1 : 0) + stick.x;
  let iz = (keys.has('down') ? 1 : 0) - (keys.has('up') ? 1 : 0) + stick.y;
  const il = Math.hypot(ix, iz); if (il > 1) { ix /= il; iz /= il; }

  P.inv = Math.max(0, P.inv - dt); P.dodgeCd = Math.max(0, P.dodgeCd - dt);
  if (P.act !== 'none') { P.actT -= dt; if (P.actT <= 0) { if (P.act === 'eat') { P.hp = Math.min(6, P.hp + 2); updateHud(); Sfx.pip(); } P.act = 'none'; } }

  const free = P.act === 'none';
  const wasGuard = P.guard;
  P.guard = keys.has('guard') && free && !P.charging;
  if (P.guard && !wasGuard) P.guardPressT = S.time;

  if (pressed.has('attack') && free && !P.charging) { P.charging = true; P.chargeT = 0; P.clicks = 0; }
  if (P.charging) {
    P.chargeT += dt;
    const c = Math.min(3, Math.floor(P.chargeT / (T.heavyCharge / 3) + 0.001));
    while (P.clicks < c) { P.clicks++; Sfx.click(); }
    if (!keys.has('attack')) {
      P.charging = false;
      faceTarget();
      if (P.chargeT >= T.heavyCharge) { P.act = 'heavy'; P.actT = T.playerRecover + 0.15; heavyStrike(); }
      else { P.act = 'light'; P.actT = 0.32; Sfx.swing(); lightStrike(); }
    }
  }
  if (pressed.has('dodge') && free && P.dodgeCd <= 0) {
    P.charging = false;
    let dx = ix, dz = iz; if (Math.hypot(dx, dz) < 0.2) { dx = -Math.sin(P.yaw); dz = -Math.cos(P.yaw); }
    const l = Math.hypot(dx, dz); P.dx = dx / l; P.dz = dz / l; P.act = 'dodge'; P.actT = 0.28; P.dodgeCd = 0.55; Sfx.swing();
  }
  if (pressed.has('eat') && free && P.biscuits > 0 && P.hp < 6) { P.biscuits--; P.act = 'eat'; P.actT = 0.9; P.charging = false; updateHud(); }

  let speed = 5;
  if (P.guard) speed = 1.6; else if (P.charging) speed = 2.6; else if (P.act === 'eat') speed = 1.0;
  else if (P.act === 'light' || P.act === 'heavy') speed = 0.6;
  let vx = ix * speed, vz = iz * speed;
  if (P.act === 'dodge') { vx = P.dx * 11; vz = P.dz * 11; }
  vx += P.kx; vz += P.kz; P.kx = damp(P.kx, 0, 8, dt); P.kz = damp(P.kz, 0, 8, dt);
  P.x = clamp(P.x + vx * dt, BOUNDS.minX, BOUNDS.maxX);
  P.z = clamp(P.z + vz * dt, BOUNDS.minZ, BOUNDS.maxZ);
  const solids = plinths.concat(racks.filter(r => r.state !== 'move').map(r => ({ x: r.x, z: r.z, hw: 0.3, hd: 0.85 })));
  for (const p of solids) { // push out of plinths and racks
    const ox = P.x - p.x, oz = P.z - p.z, px = p.hw + 0.3 - Math.abs(ox), pz = p.hd + 0.3 - Math.abs(oz);
    if (px > 0 && pz > 0) { if (px < pz) P.x += Math.sign(ox) * px; else P.z += Math.sign(oz) * pz; }
  }
  const dm = dist(P.x, P.z, M.x, M.z);
  if (dm < 1.05 && dm > 0.001) { P.x = M.x + (P.x - M.x) / dm * 1.05; P.z = M.z + (P.z - M.z) / dm * 1.05; }

  if (P.guard || P.charging) faceTarget(dt);
  else if (Math.hypot(ix, iz) > 0.1) P.yaw = dampAngle(P.yaw, Math.atan2(ix, iz), 14, dt);
  P.speed = Math.hypot(vx, vz); P.walk += P.speed * dt * 2.2;

  // Retreat: the west door is available whenever the boss is not committed.
  const nearDoor = P.x < -6.6 && P.z > 6.2;
  if (nearDoor && !committed() && M.state !== 'defeated') {
    setPrompt('R — Retreat to the service passage (resets this attempt, keeps the shortcut)');
    if (pressed.has('retreat')) { say('', 'Retreated to the service passage.', 1.8); resetAttempt(settings.keepProgress); }
  } else if (P.charging && P.chargeT >= T.heavyCharge) setPrompt('Wound — release');
  else setPrompt('');
}
function faceTarget(dt) {
  const y = yawTo(P.x, P.z, M.x, M.z);
  P.yaw = dt ? dampAngle(P.yaw, y, 16, dt) : y;
}

/* ---------------- Flow ---------------- */
function defeat() {
  S.mode = 'end';
  showEnd('Defeat', 'Ren is down', settings.keepProgress
    ? 'Back at the service passage with full health and two biscuits. Bell progress is kept.'
    : 'Back at the service passage with full health and two biscuits. The Manager starts again from phase one.', 'Try again');
}
function victory() {
  M.state = 'defeated'; S.victoryT = 0;
  if (sign) { scene.remove(sign.mesh); sign = null; }
  Sfx.squeak();
  [['REN', 'Are you finished?'], ['FLOOR MANAGER', 'I have not completed the closing procedure.'], ['MIKA', 'Neither has the town.'],
   ['FLOOR MANAGER', 'If we close, where do they go?'], ['HESTA', 'We count them first.']].forEach(([w, t]) => say(w, t, 2.8));
}
function showEnd(eyebrow, title, body, btn) {
  $('#end-eyebrow').textContent = eyebrow; $('#end-title').textContent = title; $('#end-body').textContent = body;
  $('#again').textContent = btn; $('#end').hidden = false;
}

/* ---------------- Visual update ---------------- */
function poseArms(dt) {
  const pose = POSES[M.pose] || POSES.idle;
  BOSS.arms.forEach(a => {
    const [rx, rz, ex] = pose[a.level];
    a.rx = damp(a.rx, rx, 9, dt); a.rz = damp(a.rz, rz, 9, dt); a.ex = damp(a.ex, ex, 9, dt);
    a.sh.rotation.set(a.rx, 0, a.s * a.rz); a.el.rotation.x = a.ex;
  });
}
function render(dt) {
  // Manager
  BOSS.root.position.set(M.x, 0, M.z);
  BOSS.chair.rotation.y = M.chairYaw;
  BOSS.upper.rotation.y = M.yaw;
  BOSS.upper.position.y = -0.55 * M.lower; // telescoping column lowers him
  BOSS.body.rotation.x = -M.flinch * 0.12 + (M.state === 'exposed' ? -0.06 : 0);
  poseArms(dt);
  const exp = M.state === 'exposed' || M.state === 'launch';
  BOSS.paddle.position.z = damp(BOSS.paddle.position.z, exp ? -0.44 : -0.18, 10, dt);
  BOSS.paddle.position.y = damp(BOSS.paddle.position.y, exp ? 0.34 : 0.44, 10, dt);
  BOSS.paddle.material.emissive.setHex(exp ? 0x551008 : 0x000000);
  const present = M.state === 'present';
  BOSS.held.visible = present || M.state === 'roll' || (!sign && (M.state === 'idle' || M.state === 'recover'));
  BOSS.held.position.set(0, present ? 3.35 : 2.05, present ? 0.3 : 0.55);
  BOSS.held.rotation.x = present ? -0.15 : 0.1;

  aimArrow.visible = settings.aimHelp && M.state === 'exposed';
  if (aimArrow.visible) {
    const y = yawTo(M.x, M.z, LEVER.x, LEVER.z);
    aimArrow.position.set(M.x - Math.sin(y) * 2.6, 0, M.z - Math.cos(y) * 2.6); aimArrow.rotation.y = y;
  }

  // Bell, lever, tabs, cabinet
  leverKick = Math.max(0, leverKick - dt * 3);
  leverPivot.rotation.x = -leverKick * 0.25;
  bellDome.rotation.z = Math.sin(S.time * 60) * 0.02 * leverKick;
  tabFalls.forEach(f => { if (f.m.position.y > -3.0) { f.v += 9 * dt; f.m.position.y -= f.v * dt; f.m.rotation.z += dt * 4; } else f.m.visible = false; });
  if (M.state === 'defeated') cabDoor.rotation.y = damp(cabDoor.rotation.y, -1.9, 2, dt);

  // Ren
  REN.root.position.set(P.x, 0, P.z); REN.root.rotation.y = P.yaw;
  P.stride = damp(P.stride || 0, P.speed > 0.5 ? 1 : 0, 10, dt);
  const moving = Math.abs(Math.sin(P.walk)) * P.stride;
  REN.legs[0].rotation.x = Math.sin(P.walk) * 0.6 * P.stride; REN.legs[1].rotation.x = -Math.sin(P.walk) * 0.6 * P.stride;
  REN.armL.rotation.x = -Math.sin(P.walk) * 0.4 * P.stride;
  let ax = -0.35, ay = 0, az = 0.15;
  if (P.guard) { ax = -1.45; ay = -0.9; az = 0; }
  else if (P.charging) { const k = Math.min(1, P.chargeT / T.heavyCharge); ax = lerp(-0.6, -2.7, k); az = -0.35; }
  else if (P.act === 'light') { const k = 1 - P.actT / 0.32; ax = lerp(-2.2, -0.5, k); az = lerp(-0.7, 0.8, k); }
  else if (P.act === 'heavy') { const k = clamp(1 - P.actT / 0.65, 0, 1); ax = lerp(-2.7, -0.3, Math.min(1, k * 2.5)); az = 0.9; }
  else if (P.act === 'eat') { ax = -2.2; az = 0.4; }
  REN.armR.rotation.x = damp(REN.armR.rotation.x, ax, P.act === 'none' ? 14 : 40, dt);
  REN.armR.rotation.y = damp(REN.armR.rotation.y, ay, 14, dt);
  REN.armR.rotation.z = damp(REN.armR.rotation.z, az, 14, dt);
  REN.root.position.y = P.act === 'dodge' ? 0 : moving * 0.03;
  REN.root.rotation.z = P.act === 'dodge' ? 0.2 : 0;
  REN.root.visible = !(P.inv > 0 && Math.floor(S.time * 20) % 2 === 0);
  const wound = P.charging && P.chargeT >= T.heavyCharge;
  REN.ring.material.opacity = damp(REN.ring.material.opacity, wound ? 0.85 : (P.charging ? 0.3 : 0), 12, dt);

  // Camera: high three-quarter view; pulls back during the opening to show chair and bell together.
  const wide = exp || M.state === 'bellScene' ? 1.18 : 1;
  // Portrait: frame further south so Ren stays clear of the thumb controls.
  const portrait = innerWidth < innerHeight;
  const fx = P.x * (portrait ? 0.8 : 0.6) + M.x * (portrait ? 0.2 : 0.4), fz = P.z * 0.62 + M.z * 0.38 + (portrait ? 2.6 : 0);
  const tx = fx, tz = fz + 10.5 * wide, ty = 11.5 * wide;
  camera.position.x = damp(camera.position.x, tx, 4, dt);
  camera.position.y = damp(camera.position.y, ty, 4, dt);
  camera.position.z = damp(camera.position.z, tz, 4, dt);
  S.shake = Math.max(0, S.shake - dt);
  const sh = S.shake * 0.4;
  camera.lookAt(fx + (Math.random() - 0.5) * sh, 1 + (Math.random() - 0.5) * sh, fz - 0.6);

  renderer.render(scene, camera);
}

function resize() {
  const w = innerWidth, h = innerHeight;
  renderer.setSize(w, h, false); camera.aspect = w / h;
  camera.fov = w < h ? 62 : 46; // portrait: a wider lens rather than a shrunken frame
  camera.updateProjectionMatrix();
}
addEventListener('resize', resize); resize();

let last = performance.now();
function frame(now) {
  const raw = Math.min(0.05, (now - last) / 1000); last = now;
  if (S.mode === 'play') {
    if (pressed.has('pause')) { S.mode = 'paused'; $('#title').hidden = false; $('#touch').hidden = true; $('#start').textContent = 'Resume'; }
    if (pressed.has('assist')) { settings.reflectAssist = !settings.reflectAssist; $('#opt-reflect').checked = settings.reflectAssist;
      say('', 'Reflection assist ' + (settings.reflectAssist ? 'on: a held guard reflects marked signs.' : 'off.'), 2); }
  }
  let dt = raw;
  if (S.freeze > 0) { S.freeze -= raw; dt = 0; }
  if (S.mode === 'play') {
    S.time += dt;
    updatePlayer(dt); updateManager(dt); updateRacks(dt); updateSign(dt);
    if (M.state === 'defeated') {
      S.victoryT += dt;
      if (S.victoryT > 15 && !S.rewardShown) {
        S.rewardShown = true; Sfx.spring(); Sfx.pip(); S.mode = 'end';
        showEnd('Key item · Q-01', 'Store Governor', 'A brass cylinder the length of Ren’s palm, cream inspection sleeve, silver fork, Meridian Works mark. Mika takes it by the sleeve. — End of the greybox slice.', 'Replay');
      }
    }
  }
  updateSubs(S.mode === 'play' ? raw : 0);
  render(S.mode === 'play' ? dt : raw * 0.2);
  pressed.clear();
  requestAnimationFrame(frame);
}

/* ---------------- Menus ---------------- */
const bindOpt = (id, k) => { const el = $(id); el.checked = settings[k]; el.addEventListener('change', () => settings[k] = el.checked); };
bindOpt('#opt-easy', 'easy'); bindOpt('#opt-reflect', 'reflectAssist'); bindOpt('#opt-aim', 'aimHelp');
bindOpt('#opt-keep', 'keepProgress'); bindOpt('#opt-shake', 'shake');
$('#start').addEventListener('click', () => {
  Sfx.init(); $('#title').hidden = true; $('#hud').hidden = false; $('#touch').hidden = !coarse;
  if (S.mode === 'title') resetAttempt(false);
  S.mode = 'play'; last = performance.now();
});
$('#again').addEventListener('click', () => {
  Sfx.init(); $('#end').hidden = true;
  const keep = settings.keepProgress && P.hp <= 0 && M.state !== 'defeated';
  resetAttempt(keep); S.mode = 'play';
});

camera.position.set(0, 12, 14);
if (/[?&]debug\b/.test(location.search)) window.__afterbell = { S, P, M, settings, racks, get sign() { return sign; },
  down, up, // fixed-step simulation for automated checks (software-rendered browsers run too slowly for real time)
  step(n = 1, dt = 1 / 60) { for (let i = 0; i < n && S.mode === 'play'; i++) { S.time += dt; updatePlayer(dt); updateManager(dt); updateRacks(dt); updateSign(dt);
    if (M.state === 'defeated') S.victoryT += dt; pressed.clear(); } } };
requestAnimationFrame(frame);
})();
