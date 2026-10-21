import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, writeFile, readFile, rm } from 'node:fs/promises';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { generateCatalog, writeCatalog } from '../tools/generate-catalog.mjs';
const exec = promisify(execFile);
const fixture = () => ({version:1,ads:[{brand:'FIKTIVER TESTSPONSOR',headline:'Nur Testdaten',body:'Keine echte Vereinbarung und keine bezahlte Anzeige.',background:'#FFFFFF',foreground:'#111111'}]});

test('production generator gates sponsor mode and keeps preview visibly demo',()=>{
  assert.match(generateCatalog(fixture()),/DEMO · KEINE BEZAHLTE ANZEIGE/);
  assert.throws(()=>generateCatalog(fixture(),{sponsor:true}),/confirmation/);
  assert.throws(()=>generateCatalog(fixture(),{sponsor:true,confirmRightsAndContract:'yes'}),/confirmation/);
  assert.match(generateCatalog(fixture(),{sponsor:true,confirmRightsAndContract:true}),/WERBUNG · DIREKTER SPONSOR/);
});

test('strict catalog schema bounds text, contrast, count and forbids scripts, URLs and controls',()=>{
  const changes = [
    x=>x.ads.push(...Array(48).fill(x.ads[0])),x=>x.ads=[],x=>x.version=2,x=>x.extra='x',
    x=>x.ads[0].url='https://tracker.invalid',x=>x.ads[0].body='<script>alert(1)</script>',
    x=>x.ads[0].body='https://tracker.invalid/pixel',x=>x.ads[0].body='www.tracker.invalid',
    x=>x.ads[0].body='javascript:alert(1)',x=>x.ads[0].brand='x'.repeat(41),
    x=>x.ads[0].headline='a\nb\nc\nd',x=>x.ads[0].body='\ud800',x=>x.ads[0].body='hello\u202eevil',
    x=>x.ads[0].background='#fff',x=>x.ads[0].foreground='#FFFFFF',x=>x.ads[0].brand='',
  ];
  for(const mutate of changes){const value=fixture();mutate(value);assert.throws(()=>generateCatalog(value));}
});

test('generated Java compiles and preserves quote, slash, Unicode and newline text without code injection',async t=>{
  const dir=await mkdtemp(join(tmpdir(),'adscroll-catalog-')); t.after(()=>rm(dir,{recursive:true,force:true}));
  const value=fixture();value.ads[0].body='Quote " backslash \\ literal \\u000a\nÄpfel 🍎';
  const catalog=join(dir,'Catalog.java');await writeFile(catalog,generateCatalog(value));
  const harness=`import de.leterel.adscroll.Catalog;
public class Harness { public static void main(String[] args) throws Exception {
System.out.println(java.util.Base64.getEncoder().encodeToString(Catalog.ADS[0][2].getBytes("UTF-8")));
if(Catalog.index(-1)!=0 || Catalog.next(Long.MAX_VALUE)!=0 || Catalog.previous(0)!=0) throw new AssertionError();
System.out.println(Catalog.APP_LABEL);
}}`;
  await writeFile(join(dir,'Harness.java'),harness);await mkdir(join(dir,'classes'));
  await exec('javac',['-encoding','UTF-8','--release','8','-d',join(dir,'classes'),catalog,join(dir,'Harness.java')]);
  const {stdout}=await exec('java',['-cp',join(dir,'classes'),'Harness']);
  assert.equal(Buffer.from(stdout.split(/\r?\n/)[0],'base64').toString(),value.ads[0].body);
  assert.match(stdout,/DEMO/);
});

test('writing catalog preserves source and refuses existing outputs or oversized input',async t=>{
  const dir=await mkdtemp(join(tmpdir(),'adscroll-catalog-files-')); t.after(()=>rm(dir,{recursive:true,force:true}));
  const input=join(dir,'private.json');await writeFile(input,JSON.stringify(fixture()));
  const before=await readFile(input,'utf8');const output=join(dir,'new');
  await writeCatalog(input,output);
  await assert.rejects(writeCatalog(input,output),{code:'EEXIST'});
  assert.equal(await readFile(input,'utf8'),before);
  await writeFile(input,' '.repeat(65537));await assert.rejects(writeCatalog(input,join(dir,'too-large')),/64 KiB/);
});
