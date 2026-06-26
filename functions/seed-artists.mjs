// seed-artists.mjs — Adiciona artistas ao Firestore via REST API
// Rode com: node functions/seed-artists.mjs

import { readFileSync } from 'fs';
import { join } from 'path';
import { request } from 'https';
import os from 'os';

// --- 1. Lê credenciais Firebase CLI ---
const credFile = join(
  process.env.APPDATA || join(os.homedir(), 'AppData', 'Roaming'),
  'firebase',
  'victorandrey02_gmail_com_application_default_credentials.json'
);

const cred = JSON.parse(readFileSync(credFile, 'utf8'));

// --- 2. Obtém access token via refresh token ---
function getAccessToken() {
  const body = new URLSearchParams({
    client_id: cred.client_id,
    client_secret: cred.client_secret,
    refresh_token: cred.refresh_token,
    grant_type: 'refresh_token',
  }).toString();

  return new Promise((resolve, reject) => {
    const req = request(
      {
        hostname: 'oauth2.googleapis.com',
        path: '/token',
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          const parsed = JSON.parse(data);
          if (parsed.access_token) resolve(parsed.access_token);
          else reject(new Error('Token inválido: ' + data));
        });
      }
    );
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

// --- 3. Adiciona documento ao Firestore ---
function addDocument(token, collection, data) {
  const projectId = 'outvision-app-24329';
  const body = JSON.stringify({
    fields: Object.fromEntries(
      Object.entries(data).map(([k, v]) => {
        if (typeof v === 'string') return [k, { stringValue: v }];
        if (typeof v === 'object' && v !== null) {
          return [k, {
            mapValue: {
              fields: Object.fromEntries(
                Object.entries(v).map(([mk, mv]) => [mk, { stringValue: mv }])
              ),
            },
          }];
        }
        return [k, { stringValue: String(v) }];
      })
    ),
  });

  return new Promise((resolve, reject) => {
    const path = `/v1/projects/${projectId}/databases/(default)/documents/${collection}`;
    const req = request(
      {
        hostname: 'firestore.googleapis.com',
        path,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (c) => (raw += c));
        res.on('end', () => {
          const parsed = JSON.parse(raw);
          if (res.statusCode >= 200 && res.statusCode < 300) resolve(parsed.name);
          else reject(new Error(`HTTP ${res.statusCode}: ${raw}`));
        });
      }
    );
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

// --- 4. Dados dos artistas ---
const base =
  'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Artistas%2F';

const artists = [
  {
    name: 'Evandro Soares',
    artist_photo: base + 'Evandro%20Soares.jpg?alt=media',
    bio: { pt: '', en: '', es: '' },
    website: '',
  },
  {
    name: 'Jessie Kleemann',
    artist_photo: base + 'Jessie%20Kleemann.jpg?alt=media',
    bio: { pt: '', en: '', es: '' },
    website: '',
  },
  {
    name: 'James Kudo',
    artist_photo: base + 'James%20Kudo.jpg?alt=media',
    bio: { pt: '', en: '', es: '' },
    website: '',
  },
];

// --- 5. Executa ---
console.log('Obtendo token de acesso...');
const token = await getAccessToken();
console.log('Token obtido. Adicionando artistas...\n');

for (const artist of artists) {
  const docName = await addDocument(token, 'artists', artist);
  const id = docName.split('/').pop();
  console.log(`✓ ${artist.name} — ID: ${id}`);
}

console.log('\nPronto!');
process.exit(0);
