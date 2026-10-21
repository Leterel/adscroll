import { readFile, mkdir, writeFile, stat } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';

function keys(value, expected) {
  if (!value || typeof value !== 'object' || Array.isArray(value) || Object.keys(value).sort().join(',') !== [...expected].sort().join(',')) throw Error('Unexpected or missing catalog fields');
}
function text(value, max, lines = 1) {
  if (typeof value !== 'string' || !value.trim() || value.length > max || !value.isWellFormed() || value.split('\n').length > lines || /[\u0000-\u0009\u000b-\u001f\u007f<>\u200b-\u200f\u202a-\u202e\u2066-\u2069]/u.test(value) || /(?:[a-z][a-z0-9+.-]*:|www\.|\/\/)/i.test(value)) throw Error('Invalid text: bounded plain text only, no URLs or markup');
  return value;
}
const java = value => '"' + value.replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\n', '\\n') + '"';
function luminance(hex) { return [1,3,5].map(i => parseInt(hex.slice(i,i+2),16)/255).map(v => v <= .04045 ? v/12.92 : ((v+.055)/1.055)**2.4).reduce((s,v,i)=>s+v*[.2126,.7152,.0722][i],0); }

export function generateCatalog(input, { sponsor = false, confirmRightsAndContract = false } = {}) {
  if (sponsor && confirmRightsAndContract !== true) throw Error('Sponsor mode requires explicit rights and contract confirmation');
  keys(input, ['version','ads']);
  if (input.version !== 1 || !Array.isArray(input.ads) || input.ads.length < 1 || input.ads.length > 48) throw Error('Version 1 and 1–48 ads required');
  const rows = input.ads.map((ad, i) => {
    keys(ad, ['brand','headline','body','background','foreground']);
    const fields = [text(ad.brand,40),text(ad.headline,100,3),text(ad.body,240,4)];
    for (const color of [ad.background,ad.foreground]) if (typeof color !== 'string' || !/^#[0-9a-fA-F]{6}$/.test(color)) throw Error('Colors must be #RRGGBB');
    const a = luminance(ad.background), b = luminance(ad.foreground);
    if ((Math.max(a,b)+.05)/(Math.min(a,b)+.05) < 4.5) throw Error('Text contrast must be at least 4.5:1');
    return '        {' + [...fields,ad.background,ad.foreground,String(i+1).padStart(2,'0')].map(java).join(', ') + '}';
  });
  return `package de.leterel.adscroll;

/** Generated locally from validated text. No network or impression tracking. */
public final class Catalog {
    private Catalog() {}
    public static final String APP_LABEL = ${java(sponsor ? 'adscroll.     SPONSOREN' : 'adscroll.     DEMO')};
    public static final String DISCLOSURE = ${java(sponsor ? 'WERBUNG · DIREKTER SPONSOR' : 'DEMO · KEINE BEZAHLTE ANZEIGE')};
    public static final String POSITION_LABEL = ${java(sponsor ? 'WERBUNG / ' : 'DEMO / ')};
    public static final String ANNOUNCEMENT_PREFIX = ${java(sponsor ? 'Sponsor-Anzeige ' : 'Demo-Anzeige ')};
    public static final String[][] ADS = {
${rows.join(',\n')}
    };
    public static int index(long position) { return (int) Math.floorMod(position, (long) ADS.length); }
    public static long next(long position) { return position == Long.MAX_VALUE ? 0 : Math.max(0, position + 1); }
    public static long previous(long position) { return Math.max(0, position - (position > 0 ? 1 : 0)); }
}
`;
}

export async function writeCatalog(inputPath, outputDirectory, options = {}) {
  if ((await stat(inputPath)).size > 65536) throw Error('Catalog JSON exceeds 64 KiB');
  const input = JSON.parse(await readFile(inputPath, 'utf8'));
  const source = generateCatalog(input, options);
  await mkdir(outputDirectory); // New output only; never replace the demo source.
  await writeFile(join(outputDirectory,'Catalog.java'), source, { flag: 'wx' });
  return join(outputDirectory,'Catalog.java');
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const [input, output, ...flags] = process.argv.slice(2);
    if (!input || !output || flags.some(f => !['--sponsor','--confirm-rights-and-contract'].includes(f))) throw Error('Usage: node tools/generate-catalog.mjs input.json NEW_OUTPUT_DIR [--sponsor --confirm-rights-and-contract]');
    console.log(await writeCatalog(input,output,{sponsor:flags.includes('--sponsor'),confirmRightsAndContract:flags.includes('--confirm-rights-and-contract')}));
  } catch(error) { console.error(error.message); process.exitCode=1; }
}
