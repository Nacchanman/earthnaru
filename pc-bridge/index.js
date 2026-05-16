import os from 'node:os';
import process from 'node:process';
import { WebSocketServer } from 'ws';

const port = Number(process.env.PORT ?? 8787);
const wss = new WebSocketServer({ port });
let totalKeys = 0;

function payload(type = 'key') {
  return JSON.stringify({
    type,
    totalKeys,
    sentAt: new Date().toISOString(),
  });
}

function broadcast(message) {
  for (const client of wss.clients) {
    if (client.readyState === client.OPEN) {
      client.send(message);
    }
  }
}

function localAddresses() {
  const networks = os.networkInterfaces();
  const addresses = [];

  for (const entries of Object.values(networks)) {
    for (const entry of entries ?? []) {
      if (entry.family === 'IPv4' && !entry.internal) {
        addresses.push(entry.address);
      }
    }
  }

  return addresses;
}

wss.on('connection', (socket, request) => {
  console.log(`iPhone connected from ${request.socket.remoteAddress}`);
  socket.send(payload('sync'));

  socket.on('close', () => {
    console.log('iPhone disconnected');
  });
});

process.stdin.setRawMode?.(true);
process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.on('data', (key) => {
  if (key === '\u0003') {
    console.log('\nStopping EarthNaru bridge.');
    process.exit(0);
  }

  // Ignore arrow-key escape sequences as one terminal control gesture.
  if (key.startsWith('\u001b')) {
    return;
  }

  totalKeys += Array.from(key).length;
  broadcast(payload('key'));
  process.stdout.write(`\rTotal keys: ${totalKeys} | Connected iPhones: ${wss.clients.size}   `);
});

console.log(`EarthNaru bridge listening on ws://localhost:${port}`);
for (const address of localAddresses()) {
  console.log(`Try from iPhone: ws://${address}:${port}`);
}
console.log('Focus this terminal and type. Press Ctrl+C to stop.');
