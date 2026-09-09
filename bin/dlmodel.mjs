#!/usr/bin/env node
/**
 * dlmodel — download GGUF files from Hugging Face into a flat local models dir.
 *
 * Single file, zero dependencies (Node >= 20). Resumable, parallel shard
 * downloads, live progress.
 *
 *   dlmodel <owner/repo>                     list .gguf files in the repo
 *   dlmodel <owner/repo> <file | glob>       download (mmproj auto-matched
 *                                            with --mmproj)
 *
 * Interrupted downloads are kept as *.part and resume on re-run. Resume sends
 * the saved ETag / Last-Modified as If-Range, so a part whose upstream file
 * changed is restarted instead of spliced. --force discards the .part files.
 * mmproj files without a model prefix (e.g. mmproj-BF16.gguf) are saved as
 * <model>-mmproj-... to match the local naming convention. Shards are saved
 * as separate -NNNNN-of-NMMMM.gguf files (never merged: split GGUFs carry an
 * index that merging breaks).
 */
import {
  existsSync, mkdirSync, createWriteStream,
  readFileSync, writeFileSync, statSync, renameSync, rmSync,
} from 'node:fs';
import { Readable } from 'node:stream';
import { homedir } from 'node:os';
import path from 'node:path';

const HF = 'https://huggingface.co';
const OUT_DIR = path.resolve(process.env.DLMODEL_DIR || path.join(homedir(), '.cache', 'models'));
const CONCURRENCY = 4;
const RETRIES = 4;

// Quant suffixes: Q4_0, Q8_K_XL, UD-Q8_K_XL, IQ1_S, BF16, F16, F32, ...
const QUANT_RE = /-(?:UD-)?(?:[IQ]Q\d+|Q\d+|BF\d+|F\d+)[A-Z0-9_]*$/i;
const SHARD_RE = /^(.+)-(\d{5})-of-(\d{5})\.gguf$/i;
const SHARD_SUFFIX_RE = /-\d{5}-of-\d{5}(?=\.gguf$)/i;

// ------------------------------------------------------------- run lifecycle

class Aborted extends Error {}

let interrupted = false;      // SIGINT or first fatal download error
let runError = null;          // first error message, reported at exit
const inflight = new Set();   // AbortControllers of live requests

function abortRun(msg) {
  if (msg && !runError) runError = msg;
  interrupted = true;
  for (const c of inflight) c.abort();
}

async function backoff(ms) {
  if (interrupted) throw new Aborted();
  await sleep(ms);
  if (interrupted) throw new Aborted();
}

// ---------------------------------------------------------------- utilities

function die(msg) { console.error(`dlmodel: ${msg}`); process.exit(1); }
const sleep = ms => new Promise(r => setTimeout(r, ms));
const base = p => p.split('/').pop();
const fileSize = p => (existsSync(p) ? statSync(p).size : 0);
const isMmproj = f => f.name.toLowerCase().includes('mmproj');

async function drainBody(res) {
  try { await res.body?.cancel(); } catch { /* already gone */ }
}

function human(n) {
  const u = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
  let i = 0;
  while (n >= 1024 && i < u.length - 1) { n /= 1024; i++; }
  return `${n >= 100 ? n.toFixed(0) : n.toFixed(1)} ${u[i]}`;
}

function fmtEta(s) {
  if (s < 90) return `${Math.ceil(s)}s`;
  const m = Math.floor(s / 60);
  if (m < 90) return `${m}m${Math.round(s % 60) ? Math.round(s % 60) + 's' : ''}`;
  return `${Math.floor(m / 60)}h${String(m % 60).padStart(2, '0')}m`;
}

function globToRe(g) {
  const re = g.replace(/[.+^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*').replace(/\?/g, '.');
  return new RegExp(`^${re}$`);
}

const stripShard = name => name.replace(SHARD_SUFFIX_RE, '');

function modelPrefixFromBase(name) {
  return stripShard(base(name)).replace(/\.gguf$/i, '').replace(QUANT_RE, '');
}
function modelPrefixFromRepo(repo) {
  return repo.split('/').pop().replace(/-GGUF$/i, '').replace(QUANT_RE, '');
}
// mmproj-BF16.gguf -> <prefix>-mmproj-BF16.gguf ; names that already carry the
// model prefix (mmproj-ModelA-BF16.gguf) are left alone
function localNameFor(name, prefix) {
  if (!prefix || !/mmproj/i.test(name) || !/^mmproj[-_]/i.test(name)) return name;
  if (name.toLowerCase().includes(prefix.toLowerCase())) return name;
  return `${prefix}-${name}`;
}

// ------------------------------------------------------------------- network

function authHint(status, what) {
  if (status === 404) return `${what}: not found (check owner/repo)`;
  if (status === 401 || status === 403) return `${what}: gated or private — set HF_TOKEN`;
  return null;
}

async function fetchWithRetry(url, extraHeaders = {}, signal) {
  const headers = { ...extraHeaders };
  if (process.env.HF_TOKEN) headers.Authorization = `Bearer ${process.env.HF_TOKEN}`;
  let lastErr;
  for (let attempt = 1; attempt <= RETRIES; attempt++) {
    if (signal?.aborted) throw new Aborted();
    try {
      const res = await fetch(url, { headers, redirect: 'follow', signal });
      if (res.status === 429 || res.status >= 500) {
        await drainBody(res);
        lastErr = new Error(`HTTP ${res.status}`);
      } else return res;
    } catch (e) {
      if (signal?.aborted) throw new Aborted();
      lastErr = e;
    }
    if (attempt < RETRIES) await backoff(1000 * 2 ** (attempt - 1));
  }
  throw lastErr;
}

async function repoTree(repo, signal) {
  let res;
  try {
    res = await fetchWithRetry(`${HF}/api/models/${repo}/tree/main?recursive=true`, {}, signal);
  } catch (e) {
    if (interrupted) process.exit(130);
    die(`cannot reach huggingface.co: ${e.message}`);
  }
  if (!res.ok) {
    const hint = authHint(res.status, repo);
    if (hint) die(hint);
    die(`HF API error: HTTP ${res.status} for ${repo}`);
  }
  const entries = await res.json();
  return entries
    .filter(e => e.type === 'file' && /\.gguf$/i.test(e.path) && !e.path.endsWith('.incomplete'))
    .map(e => ({ path: e.path, size: e.size ?? 0, name: base(e.path) }));
}

function resolveUrl(repo, filePath) {
  return `${HF}/${repo}/resolve/main/${filePath.split('/').map(encodeURIComponent).join('/')}?download=true`;
}

// ------------------------------------------------- resume metadata (.part.meta)

const strongValidator = res => {
  const etag = res.headers.get('etag');
  if (etag && !etag.startsWith('W/')) return etag;      // weak etags are invalid in If-Range
  return res.headers.get('last-modified');
};

function readMeta(p) {
  try { return JSON.parse(readFileSync(p.metaPath, 'utf8')); } catch { return {}; }
}
function writeMeta(p, meta) {
  try { writeFileSync(p.metaPath, JSON.stringify(meta)); } catch { /* best effort */ }
}
function dropMeta(p) { rmSync(p.metaPath, { force: true }); }

// A stale .part can only be trusted when its validator still matches upstream
// (If-Range) and it was not truncated from under us (meta.bytes).
function discardPart(p, why) {
  console.error(`  discarding ${path.basename(p.tmp)} (${why})`);
  rmSync(p.tmp, { force: true });
  dropMeta(p);
}

// ------------------------------------------------------------------ progress

class Progress {
  constructor() {
    this.rows = [];
    this.tty = !!process.stderr.isTTY;
    this.lines = 0;
    this.timer = setInterval(() => this.draw(), this.tty ? 200 : 5000);
    this.timer.unref();
  }
  add(label, startDone, total) {
    const row = { label: label.slice(0, 40), done: startDone, start: startDone, total, t0: Date.now(), lastSlow: 0 };
    this.rows.push(row);
    this.draw();
    return row;
  }
  bump(row, n) { row.done += n; }
  finish(row) { this.rows = this.rows.filter(r => r !== row); this.draw(); }
  draw() {
    if (!this.tty) return this.drawSlow();
    if (this.lines) process.stderr.write(`\x1b[${this.lines}A\x1b[J`);
    this.lines = 0;
    for (const r of this.rows) {
      const el = (Date.now() - r.t0) / 1000 || 1;
      const speed = (r.done - r.start) / el;
      const pct = r.total ? `${Math.floor(100 * r.done / r.total)}%` : '';
      const eta = r.total > r.done && speed > 0 ? `eta ${fmtEta((r.total - r.done) / speed)}` : '';
      process.stderr.write(`  ${r.label}  ${human(r.done)}/${human(r.total)} ${pct}  ${human(speed)}/s  ${eta}\n`);
      this.lines++;
    }
  }
  drawSlow() {
    const now = Date.now();
    for (const r of this.rows) {
      if (now - r.lastSlow > 5000) {
        r.lastSlow = now;
        const pct = r.total ? ` ${Math.floor(100 * r.done / r.total)}%` : '';
        console.error(`  ${r.label}  ${human(r.done)}/${human(r.total)}${pct}`);
      }
    }
  }
}

// ------------------------------------------------------------------ download

async function downloadPart(p, pro) {
  for (let attempt = 1; ; attempt++) {
    if (interrupted) throw new Aborted();

    // a .part longer than the remote file is stale or corrupt — never usable
    if (p.size && fileSize(p.tmp) > p.size) discardPart(p, `${fileSize(p.tmp)} > ${p.size} bytes`);
    if (p.size && fileSize(p.tmp) >= p.size) { p.done = true; return; }

    const controller = new AbortController();
    inflight.add(controller);
    let have = fileSize(p.tmp);
    try {
      const headers = {};
      if (have > 0) {
        const meta = readMeta(p);
        if (Number.isFinite(meta.bytes) && meta.bytes > have) {
          discardPart(p, 'part shrank since last attempt');
          have = 0;
        } else {
          headers.Range = `bytes=${have}-`;
          if (meta.validator) headers['If-Range'] = meta.validator;
        }
      }

      let res;
      try {
        res = await fetchWithRetry(p.url, headers, controller.signal);
      } catch (e) {
        if (e instanceof Aborted) throw e;
        throw new Error(`${p.f.path}: ${e.message || e} (kept as ${path.basename(p.tmp)} — re-run to resume)`);
      }

      if (!res.ok) {
        await drainBody(res);
        if (res.status === 416) {
          // range unsatisfiable — with an oversized part already discarded above,
          // this only means "fully downloaded" when the sizes line up
          if (p.size && fileSize(p.tmp) === p.size) { p.done = true; return; }
          throw new Error(`${p.f.path}: HTTP 416 but part is ${fileSize(p.tmp)}/${p.size || '?'} bytes `
            + `(delete ${path.basename(p.tmp)} and re-run)`);
        }
        throw new Error(authHint(res.status, p.f.path) ?? `${p.f.path}: HTTP ${res.status}`);
      }

      if (have > 0 && res.status === 200) {
        // Range ignored, or If-Range validator no longer matches upstream:
        // the content changed, so anything we already have is wrong. Restarting
        // without a Range header (next attempt) downloads the file in full.
        await drainBody(res);
        const validatorRejected = Boolean(readMeta(p).validator) && Boolean(res.headers.get('etag'));
        discardPart(p, validatorRejected ? 'upstream file changed since the part was started' : 'server ignored Range header');
        if (attempt >= RETRIES) throw new Error(`${p.f.path}: cannot resume (no usable Range support)`);
        continue;
      }

      // store the validator up front: an interrupted part must still be able
      // to prove it matches upstream on the next run
      const validator = strongValidator(res);
      writeMeta(p, { validator, bytes: have });
      const row = pro.add(p.label, have, p.size);
      const out = createWriteStream(p.tmp, { flags: have > 0 ? 'a' : 'w' });
      try {
        for await (const chunk of Readable.fromWeb(res.body)) {
          if (!out.write(chunk)) await new Promise(r => out.once('drain', r));
          pro.bump(row, chunk.length);
        }
        await new Promise(r => out.end(r));           // flush before we size-check
        const got = fileSize(p.tmp);
        if (p.size && got !== p.size)
          throw new Error(`stream ended early at ${got}/${p.size} bytes`); // retryable: resume
        p.done = true;
        return;
      } catch (e) {
        out.destroy();
        if (interrupted) throw new Aborted();
        if (p.size && fileSize(p.tmp) > p.size) discardPart(p, 'oversized after write');
        if (attempt >= RETRIES)
          throw new Error(`${p.f.path}: ${e.message || e} (kept as ${path.basename(p.tmp)} — re-run to resume)`);
        console.error(`  retry ${attempt + 1}/${RETRIES} ${p.f.name}: ${e.message || e}`);
        await backoff(1000 * attempt);
        continue;
      } finally {
        pro.finish(row);
      }
    } finally {
      inflight.delete(controller);
    }
  }
}

function finalize(job, renamedFrom) {
  const [p] = job.parts;
  renameSync(p.tmp, job.finalPath);
  dropMeta(p);
  const actual = fileSize(job.finalPath);
  if (job.total && actual !== job.total)
    console.error(`dlmodel: WARNING size mismatch for ${job.final} — got ${actual}, expected ${job.total}`);
  if (renamedFrom) console.error(`  renamed: ${renamedFrom} -> ${job.final}`);
  console.error(`ok: ${job.final} (${human(actual)})`);
}

// --------------------------------------------------------------------- list

function printList(repo, files, outDir) {
  const prefix = modelPrefixFromRepo(repo);
  const shards = new Map();
  const singles = [];
  for (const f of files) {
    const m = f.name.match(SHARD_RE);
    if (m) {
      const key = `${path.posix.dirname(f.path)}|${m[1]}|${m[3]}`;
      const g = shards.get(key) ?? { prefix: m[1], count: +m[3], size: 0, seen: 0 };
      g.size += f.size; g.seen++;
      shards.set(key, g);
    } else singles.push(f);
  }
  const byName = (a, b) => a.name.localeCompare(b.name, undefined, { numeric: true });
  const bases = singles.filter(f => !isMmproj(f)).sort(byName);
  const mms = singles.filter(isMmproj).sort(byName);

  // show the names the flat output dir will actually end up with
  const locals = bases.map(f => ({ final: f.name, path: f.path }));
  dedupeLocalNames(locals, { quiet: true });
  const localOf = new Map(locals.map(r => [r.path, r.final]));

  const sections = [];
  const push = (sec, row) => {
    let s = sections.find(x => x.sec === sec);
    if (!s) { s = { sec, rows: [] }; sections.push(s); }
    s.rows.push(row);
  };
  for (const f of bases) push('base models:', { label: f.path, size: f.size, local: localOf.get(f.path) });
  for (const g of [...shards.values()].sort((a, b) => a.prefix.localeCompare(b.prefix))) {
    const parts = `${g.seen}/${g.count} parts`;
    push('base models:', {
      label: `${g.prefix} (${parts})`,
      size: g.size,
      local: null,
      note: g.seen === g.count
        ? `saved as separate shards: ${g.prefix}-NNNNN-of-${String(g.count).padStart(5, '0')}.gguf`
        : `INCOMPLETE in repo (expected 1-${g.count})`,
    });
  }
  if (mms.length) {
    // an mmproj whose repo name already carries a model name needs no prefix
    const known = [...bases.map(f => modelPrefixFromBase(f.path)), ...[...shards.values()].map(g => g.prefix)]
      .filter(p => p.length > 3);
    const mmName = f => {
      const n = localNameFor(f.name, prefix);
      return n !== f.name && known.some(k => f.name.toLowerCase().includes(k.toLowerCase())) ? f.name : n;
    };
    const mmLocals = mms.map(f => ({ final: mmName(f), path: f.path }));
    dedupeLocalNames(mmLocals, { quiet: true });
    for (const r of mmLocals) {
      const f = mms.find(x => x.path === r.path);
      push('mmproj:', { label: f.path, size: f.size, local: r.final });
    }
  }

  const width = Math.min(72, 2 + Math.max(30, ...sections.flatMap(s => s.rows).map(r => r.label.length)));
  console.log(`${repo}\n`);
  for (const s of sections) {
    console.log(`  ${s.sec}`);
    for (const r of s.rows) {
      const mark = r.local && existsSync(path.join(outDir, r.local)) ? '✓ ' : '  ';
      const hint = r.local && r.local !== base(r.label) ? `  (saved as ${r.local})` : '';
      console.log(`  ${mark}${r.label.padEnd(width)} ${human(r.size).padStart(10)}${r.note ? `  ${r.note}` : ''}${hint}`);
    }
    console.log('');
  }
  console.log(`  download: dlmodel ${repo} <file> [--mmproj]   (saved to ${outDir})`);
  console.log('  files inside subdirectories must be given by their full path');
}

// ---------------------------------------------------------------------- main

function help() {
  console.log(`dlmodel — download GGUF files from Hugging Face

Usage:
  dlmodel <owner/repo>                  list .gguf files in the repo
  dlmodel <owner/repo> <file | glob>    download to the local models dir
    --mmproj       also download the matching mmproj (vision projector)
    --force        re-download from scratch (discards saved .part files)
    --keep-name    keep prefix-less mmproj names (e.g. mmproj-BF16.gguf)
    -o, --out DIR  output dir (default: $DLMODEL_DIR or ~/.cache/models)

Sharded files (-00001-of-00003.gguf) download in parallel and stay as separate
shard files, so llama.cpp can discover them; they are never merged.
Interrupted downloads keep their .part file and resume on re-run, guarded by
If-Range so a changed upstream file is restarted rather than spliced.
Files with the same basename in different repo directories are saved under
directory-prefixed names. HF_TOKEN env var is sent when set (gated repos).`);
}

// The output dir is flat, so two repo files sharing a basename (different repo
// directories) would write to the same .part. Give each one a unique name.
// Items need { final, path }; item.final is rewritten in place.
function dedupeLocalNames(items, { quiet = false } = {}) {
  const byFinal = new Map();
  for (const item of items) {
    const arr = byFinal.get(item.final) ?? [];
    arr.push(item);
    byFinal.set(item.final, arr);
  }
  for (const [final, arr] of byFinal) {
    if (arr.length < 2) continue;
    for (const item of arr) {
      const dir = path.posix.dirname(item.path);
      if (dir !== '.') item.final = dir.replaceAll('/', '-') + '-' + item.final;
    }
    const taken = new Set();
    for (const item of arr) {
      let name = item.final, n = 1;
      while (taken.has(name)) name = item.final.replace(/\.gguf$/i, '') + `-${n++}.gguf`;
      taken.add(name);
      item.final = name;
    }
    if (quiet) continue;
    console.error(`note: ${arr.length} files share the name "${final}" in different repo dirs, saving as:`);
    for (const item of arr) console.error(`  ${item.path} -> ${item.final}`);
  }
}

async function main() {
  const argv = process.argv.slice(2);
  let mmproj = false, force = false, keepName = false, outDir = OUT_DIR;
  const pos = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-h' || a === '--help') { help(); process.exit(0); }
    else if (a === '--mmproj') mmproj = true;
    else if (a === '--force') force = true;
    else if (a === '--keep-name') keepName = true;
    else if (a === '-o' || a === '--out') {
      const v = argv[++i];
      if (!v) die('--out needs a directory');
      outDir = path.resolve(v);
    } else if (a.startsWith('--out=')) outDir = path.resolve(a.slice('--out='.length));
    else if (a.startsWith('-') && a !== '-') die(`unknown flag: ${a} (see --help)`);
    else pos.push(a);
  }
  const [repo, fileArg] = pos;
  if (!repo || pos.length > 2) { help(); process.exit(pos.length ? 1 : 0); }
  if (!/^[\w.-]+\/[\w.-]+$/.test(repo)) die(`expected <owner>/<repo>, got "${repo}"`);

  const rootController = new AbortController();
  inflight.add(rootController);
  process.on('SIGINT', () => {
    if (interrupted) process.exit(130);   // second Ctrl-C: leave now
    console.error('\ninterrupted — partial files kept, re-run the same command to resume');
    abortRun(null);
  });

  const files = await repoTree(repo, rootController.signal);
  if (!files.length) die(`no .gguf files found in ${repo}`);
  if (!fileArg) { printList(repo, files, outDir); return; }

  let selected;
  const exact = files.find(f => f.path === fileArg || f.name === fileArg);
  if (exact) selected = [exact];
  else {
    const re = globToRe(fileArg);
    selected = files.filter(f => re.test(f.path) || re.test(f.name));
  }
  if (!selected.length) {
    const low = fileArg.toLowerCase();
    const near = files.filter(f => f.path.toLowerCase().includes(low));
    if (near.length === 1) {
      console.error(`note: matched ${near[0].path}`);
      selected = [near[0]];
    } else {
      console.error(`no files in ${repo} match "${fileArg}"`);
      if (near.length) {
        console.error('  closest:');
        for (const f of near.slice(0, 10)) console.error(`    ${f.path}`);
      }
      process.exit(1);
    }
  }

  const baseSel = selected.find(f => !isMmproj(f));
  const prefix = baseSel ? modelPrefixFromBase(baseSel.path) : modelPrefixFromRepo(repo);

  if (mmproj) {
    const cand = files.filter(f => isMmproj(f) && !selected.includes(f));
    const withP = cand.filter(f => f.path.toLowerCase().includes(prefix.toLowerCase()));
    let pool = withP.length ? withP : cand;
    if (!pool.length) die('no mmproj file found in this repo');
    // prefer BF16, then F16 (llama.cpp convention), then anything else
    const rank = n => (/mmproj-bf16/i.test(n) ? 0 : /mmproj-f16/i.test(n) ? 1 : 2);
    pool = [...pool].sort((a, b) => rank(a.name) - rank(b.name));
    if (pool.length > 1 && rank(pool[0].name) === rank(pool[1].name)) {
      console.error('multiple mmproj candidates — pass one explicitly:');
      for (const f of pool) console.error(`  ${f.path}`);
      process.exit(1);
    }
    if (pool.length > 1) console.error(`note: picking ${pool[0].name} over ${pool.map(f => f.name).slice(1).join(', ')}`);
    selected.push(pool[0]);
  }
  selected = [...new Set(selected)];

  // auto-expand a shard part to all its siblings in the repo
  {
    const sel = new Set(selected);
    for (const f of selected) {
      const m = f.name.match(SHARD_RE);
      if (!m) continue;
      const dir = path.posix.dirname(f.path);
      for (const g of files) {
        const gm = g.name.match(SHARD_RE);
        if (gm && gm[1] === m[1] && gm[3] === m[3] && path.posix.dirname(g.path) === dir) sel.add(g);
      }
    }
    selected = [...sel];
  }

  mkdirSync(outDir, { recursive: true });

  // Build jobs: one per file. Shards are kept as separate -NNNNN-of-NMMMM.gguf
  // names so llama.cpp can discover them; never merged (split GGUFs have an
  // index that merging breaks).
  const jobs = [];
  const shardGroups = new Map();
  for (const f of selected) {
    const m = f.name.match(SHARD_RE);
    if (m) {
      const key = `${path.posix.dirname(f.path)}|${m[1]}|${m[3]}`;
      if (!shardGroups.has(key)) shardGroups.set(key, new Map());
      shardGroups.get(key).set(+m[2], f);
    } else {
      jobs.push({ files: [f], path: f.path, final: keepName ? f.name : localNameFor(f.name, prefix) });
    }
  }
  for (const g of shardGroups.values()) {
    const parts = [...g.entries()].sort(([a], [b]) => a - b);
    const count = +(parts[0][1].name.match(SHARD_RE)[3]);
    const missing = [];
    for (let n = 1; n <= count; n++) if (!g.has(n)) missing.push(n);
    if (missing.length)
      console.error(`warning: ${repo} is missing shard(s) ${missing.join(', ')} of ${parts[0][1].name.match(SHARD_RE)[1]}`
        + ` (-of-${String(count).padStart(5, '0')}) — llama.cpp will not load this set`);
    for (const [, f] of parts) jobs.push({ files: [f], path: f.path, final: f.name });
  }
  dedupeLocalNames(jobs);

  for (const job of jobs) {
    job.finalPath = path.join(outDir, job.final);
    job.total = job.files.reduce((s, f) => s + f.size, 0);
    job.parts = job.files.map(f => {
      const tmp = path.join(outDir, job.final + '.part');
      return {
        f,
        size: f.size,
        url: resolveUrl(repo, f.path),
        tmp,
        metaPath: tmp + '.meta',
        label: job.final,
        done: false,
      };
    });
    if (force) for (const p of job.parts) { rmSync(p.tmp, { force: true }); dropMeta(p); }
    if (!force && existsSync(job.finalPath) && (!job.total || fileSize(job.finalPath) === job.total)) {
      for (const p of job.parts) p.done = true;
      console.error(`skip (already present${job.total ? '' : ', size unknown — not verified'}): ${job.final}`);
    }
  }

  const pro = new Progress();
  const queue = [];
  for (const job of jobs) for (const p of job.parts) if (!p.done) queue.push({ job, p });

  if (!queue.length) return;
  console.error(`downloading ${queue.length} file(s) -> ${outDir}\n`);

  let qi = 0, stopped = false;
  async function worker() {
    while (!stopped && !interrupted && qi < queue.length) {
      const { job, p } = queue[qi++];
      try {
        await downloadPart(p, pro);
        if (!job.finalizing && job.parts.every(x => x.done)) {
          job.finalizing = true;
          finalize(job, job.final !== job.files[0].name ? job.files[0].name : null);
        }
      } catch (e) {
        stopped = true;
        if (!(e instanceof Aborted)) abortRun(`${e.message || e}`);
        return;
      }
    }
  }
  await Promise.all(Array.from({ length: Math.min(CONCURRENCY, queue.length) || 1 }, worker));
  pro.draw();
  if (runError) { console.error(`dlmodel: ${runError}`); process.exitCode = 1; }
  else if (interrupted) process.exitCode = 130;
}

main().catch(e => die(e.stack || String(e)));
