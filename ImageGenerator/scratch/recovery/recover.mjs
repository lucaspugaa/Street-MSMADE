import fs from 'node:fs';
import path from 'node:path';
const root = path.resolve('ImageGenerator');
const events = JSON.parse(fs.readFileSync(path.join(root,'scratch/recovery/events.json'),'utf8').replace(/^\uFEFF/,''));
const first = events.find(e=>e.timestamp==='2026-10-08T23:13:34.996Z').payload.item.stdout;
const initialPackage=first.slice(first.indexOf('{'),first.indexOf('\n}',first.indexOf('{'))+2).trim(); JSON.parse(initialPackage); fs.writeFileSync(path.join(root,'package.json'),initialPackage+'\n');
const recovered = new Map();
for (const e of events.sort((a,b)=>a.timestamp.localeCompare(b.timestamp))) {
 const input=e.payload.input;
 if (!input?.includes('tools.apply_patch(')) continue;
 const match=input.match(/tools\.apply_patch\(("(?:[^"\\]|\\.)*")\)/s);
 if (!match) throw new Error('Patch format '+e.timestamp);
 const patch=JSON.parse(match[1]);
 fs.writeFileSync(path.join(root,'scratch/recovery',e.ordinal+'.patch'),patch);
 const lines=patch.split('\n');
 for(let i=0;i<lines.length;i++) {
  const m=lines[i].match(/^\*\*\* (Add|Update) File: (.+)$/); if(!m) continue;
  const filename=path.resolve(m[2]);
  if(!filename.startsWith(root+path.sep)) throw new Error('Outside scope '+filename);
  let section=[]; while(i+1<lines.length&&!lines[i+1].startsWith('*** ')) section.push(lines[++i]);
  let content;
  if(m[1]==='Add') content=section.map(l=>{if(!l.startsWith('+'))throw new Error('Bad add');return l.slice(1)}).join('\n')+'\n';
  else {
   content=fs.readFileSync(filename,'utf8');
   const chunks=[]; let chunk=[];
   for(const l of section){if(l.startsWith('@@')) {if(chunk.length)chunks.push(chunk);chunk=[];} else chunk.push(l)} if(chunk.length)chunks.push(chunk);
   for(const c of chunks){const old=c.filter(l=>l[0]!=='+'&&l[0]!=='\\').map(l=>l.slice(1)).join('\n');const next=c.filter(l=>l[0]!=='-'&&l[0]!=='\\').map(l=>l.slice(1)).join('\n');if(!content.includes(old))throw new Error('Context mismatch '+filename);content=content.replace(old,next)}
  }
  fs.mkdirSync(path.dirname(filename),{recursive:true}); fs.writeFileSync(filename,content); recovered.set(path.relative(root,filename),e.timestamp);
 }
}
const latest = events.find(e=>e.timestamp==='2026-10-09T00:55:59.825Z').payload.item.stdout;
fs.writeFileSync(path.join(root,'lib/mockup.mjs'),latest.split(/\r?\n/).filter(l=>/^\s*\d+: /.test(l)).map(l=>l.replace(/^\s*\d+: /,'')).join('\n')+'\n');
const pkg=latest.slice(latest.lastIndexOf('\n{')).trim(); JSON.parse(pkg); fs.writeFileSync(path.join(root,'package.json'),pkg+'\n');
console.log('Recovered patches:',Object.fromEntries(recovered)); console.log('Recovered latest engine and package from complete readback');
for(const e of events){if(e.payload.item?.stdout && e.timestamp>'2026-10-09T00:55:00')fs.writeFileSync(path.join(root,'scratch/recovery',e.ordinal+'.stdout'),e.payload.item.stdout)}


