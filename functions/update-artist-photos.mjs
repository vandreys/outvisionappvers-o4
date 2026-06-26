import { readFileSync } from 'fs';
import { join } from 'path';
import { request } from 'https';
import os from 'os';

const cred = JSON.parse(readFileSync(join(process.env.APPDATA || join(os.homedir(), 'AppData', 'Roaming'), 'firebase', 'victorandrey02_gmail_com_application_default_credentials.json'), 'utf8'));

function getToken() {
  const body = new URLSearchParams({ client_id: cred.client_id, client_secret: cred.client_secret, refresh_token: cred.refresh_token, grant_type: 'refresh_token' }).toString();
  return new Promise((res, rej) => {
    const req = request({ hostname: 'oauth2.googleapis.com', path: '/token', method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }, r => {
      let d = ''; r.on('data', c => d += c); r.on('end', () => res(JSON.parse(d).access_token));
    });
    req.on('error', rej); req.write(body); req.end();
  });
}

function patchPhoto(token, docId, photoUrl) {
  const body = JSON.stringify({
    fields: { artist_photo: { stringValue: photoUrl } }
  });
  return new Promise((res, rej) => {
    const path = `/v1/projects/outvision-app-24329/databases/(default)/documents/artists/${docId}?updateMask.fieldPaths=artist_photo`;
    const req = request({ hostname: 'firestore.googleapis.com', path, method: 'PATCH', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token } }, r => {
      let d = ''; r.on('data', c => d += c); r.on('end', () => res(r.statusCode));
    });
    req.on('error', rej); req.write(body); req.end();
  });
}

const base = 'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Artistas%2F';

const artists = [
  { id: 'EAI3FcIGVDEfcMtIn6Ix', name: 'Jessie Kleemann', file: 'JessieKleemann.png' },
  { id: '3gOQ0pUD0iVmDiQHzwVp', name: 'Iêda Jardim',     file: 'b30823d6-1d8b-49be-9429-73777eecc5e4.jpeg' },
  { id: 'nO2JiTS5X0k7m2pKEvZj', name: 'Evandro Soares',  file: 'evandro%20soares.jpg' },
];

const token = await getToken();
for (const a of artists) {
  const url = base + encodeURIComponent(a.file).replace(/%2520/g, '%20') + '?alt=media';
  const status = await patchPhoto(token, a.id, url);
  console.log(status === 200 ? `✓ ${a.name}\n  ${url}` : `✗ ${a.name} — HTTP ${status}`);
}
console.log('\nPronto!');
process.exit(0);
