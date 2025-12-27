'use strict';
const CACHE_PREFIX    = 'flutter-app';
const CACHE_VERSION   = '1766867207168';
const CACHE_NAME      = `${CACHE_PREFIX}-${CACHE_VERSION}`;
const TEMP_CACHE      = `${CACHE_PREFIX}-temp-${CACHE_VERSION}`;
const MANIFEST_CACHE  = `${CACHE_PREFIX}-manifest`;
const MANIFEST_KEY    = '__sw-manifest__';
const RETRY_DELAY     = 500;
const MEDIA_EXT       = /\.(png|jpe?g|svg|gif|webp|ico|woff2?|ttf|otf|eot|mp4|webm|ogg|mp3|wav|pdf|json|jsonp)$/i;
const NETWORK_ONLY    = /\.(php|ashx|api)$/i;
const RESOURCES_SIZE  = 31922358;
const RESOURCES = {
"/": {
"name": "index.html",
"size": 32526,
"hash": "cc7c3134f2c5ab618ff1def14b234caa"
},
"canvaskit/canvaskit.js": {
"name": "canvaskit.js",
"size": 86619,
"hash": "8331fe38e66b3a898c4f37648aaf7ee2"
},
"canvaskit/canvaskit.js.symbols": {
"name": "canvaskit.js.symbols",
"size": 1341680,
"hash": "a3c9f77715b642d0437d9c275caba91e"
},
"canvaskit/canvaskit.wasm": {
"name": "canvaskit.wasm",
"size": 7083768,
"hash": "9b6a7830bf26959b200594729d73538e"
},
"canvaskit/chromium/canvaskit.js": {
"name": "canvaskit.js",
"size": 86256,
"hash": "a80c765aaa8af8645c9fb1aae53f9abf"
},
"canvaskit/chromium/canvaskit.js.symbols": {
"name": "canvaskit.js.symbols",
"size": 1263564,
"hash": "e2d09f0e434bc118bf67dae526737d07"
},
"canvaskit/chromium/canvaskit.wasm": {
"name": "canvaskit.wasm",
"size": 5708955,
"hash": "a726e3f75a84fcdf495a15817c63a35d"
},
"canvaskit/skwasm.js": {
"name": "skwasm.js",
"size": 60657,
"hash": "8060d46e9a4901ca9991edd3a26be4f0"
},
"canvaskit/skwasm.js.symbols": {
"name": "skwasm.js.symbols",
"size": 1519144,
"hash": "3a4aadf4e8141f284bd524976b1d6bdc"
},
"canvaskit/skwasm.wasm": {
"name": "skwasm.wasm",
"size": 3551820,
"hash": "7e5f3afdd3b0747a1fd4517cea239898"
},
"canvaskit/skwasm_heavy.js": {
"name": "skwasm_heavy.js",
"size": 60770,
"hash": "740d43a6b8240ef9e23eed8c48840da4"
},
"canvaskit/skwasm_heavy.js.symbols": {
"name": "skwasm_heavy.js.symbols",
"size": 1638235,
"hash": "0755b4fb399918388d71b59ad390b055"
},
"canvaskit/skwasm_heavy.wasm": {
"name": "skwasm_heavy.wasm",
"size": 5047312,
"hash": "b0be7910760d205ea4e011458df6ee01"
},
"flutter.js": {
"name": "flutter.js",
"size": 9412,
"hash": "24bc71911b75b5f8135c949e27a2984e"
},
"flutter_bootstrap.js": {
"name": "flutter_bootstrap.js",
"size": 9765,
"hash": "1862e4360531fbac2baf8fce252390eb"
},
"index.html": {
"name": "index.html",
"size": 32526,
"hash": "cc7c3134f2c5ab618ff1def14b234caa"
},
"main.dart.js": {
"name": "main.dart.js",
"size": 4421789,
"hash": "e0a730e44db09eec42b507d93a59f871"
},
"version.json": {
"name": "version.json",
"size": 86,
"hash": "ea43cf67a3ec579df937dc08d884f2ec"
}
};
const CORE = [
"index.html",
"main.dart.js"
];
self.addEventListener("install", (event) => {
self.skipWaiting();
return event.waitUntil(
caches.open(TEMP_CACHE).then((cache) => {
return cache.addAll(
CORE.map((value) => new Request(value, {'cache': 'reload'})));
})
);
});
self.addEventListener("activate", function(event) {
return event.waitUntil(async function() {
try {
var contentCache = await caches.open(CACHE_NAME);
var tempCache = await caches.open(TEMP_CACHE);
var manifestCache = await caches.open(MANIFEST_CACHE);
var manifest = await manifestCache.match(MANIFEST_KEY);
if (!manifest) {
await caches.delete(CACHE_NAME);
contentCache = await caches.open(CACHE_NAME);
const tempKeys = await tempCache.keys();
for (let i = 0; i < tempKeys.length; i++) {
const request = tempKeys[i];
const resourceKey = getResourceKey(request);
const resourceInfo = RESOURCES[resourceKey] || RESOURCES['/'];
var response = await tempCache.match(request);
await contentCache.put(request, response);
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: resourceInfo?.size || 0,
status: 'completed'
});
}
await caches.delete(TEMP_CACHE);
await manifestCache.put(MANIFEST_KEY, new Response(JSON.stringify(RESOURCES)));
self.clients.claim();
return;
}
var oldManifest = await manifest.json();
var origin = self.location.origin;
const contentKeys = await contentCache.keys();
for (var request of contentKeys) {
var key = request.url.substring(origin.length + 1);
if (key == "") key = "/";
if (!RESOURCES[key] || RESOURCES[key]?.hash != oldManifest[key]?.hash) {
await contentCache.delete(request);
}
}
const tempKeys = await tempCache.keys();
for (let i = 0; i < tempKeys.length; i++) {
const request = tempKeys[i];
const resourceKey = getResourceKey(request);
const resourceInfo = RESOURCES[resourceKey] || RESOURCES['/'];
var response = await tempCache.match(request);
await contentCache.put(request, response);
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: resourceInfo?.size || 0,
status: 'updated'
});
}
await caches.delete(TEMP_CACHE);
await manifestCache.put(MANIFEST_KEY, new Response(JSON.stringify(RESOURCES)));
self.clients.claim();
return;
} catch (err) {
console.error('Failed to upgrade service worker: ' + err);
await caches.delete(CACHE_NAME);
await caches.delete(TEMP_CACHE);
await caches.delete(MANIFEST_CACHE);
}
}());
});
self.addEventListener("fetch", (event) => {
if (event.request.method !== 'GET') return;
var origin = self.location.origin;
var resourceKey = getResourceKey(event.request);
if (resourceKey.indexOf('?v=') != -1) resourceKey = resourceKey.split('?v=')[0];
if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || resourceKey == '')
resourceKey = '/';
var resourceInfo = RESOURCES[resourceKey];
if (!resourceInfo) return;
if (resourceKey == '/') return onlineFirst(event);
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: event.request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: 0,
status: 'loading'
});
event.respondWith(caches.open(CACHE_NAME)
.then((cache) =>  {
return cache.match(event.request).then((response) => {
return response || fetch(event.request).then((response) => {
if (response && Boolean(response.ok)) {
cache.put(event.request, response.clone());
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: event.request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: resourceInfo?.size || 0,
status: 'completed'
});
}
return response;
});
})
})
);
});
self.addEventListener('message', (event) => {
if (event.data === 'skipWaiting') {
self.skipWaiting();
return;
}
if (event.data === 'downloadOffline') {
downloadOffline();
return;
}
});
async function downloadOffline() {
var resources = [];
var contentCache = await caches.open(CACHE_NAME);
var currentContent = {};
var origin = self.location.origin;
for (var request of await contentCache.keys()) {
var key = request.url.substring(origin.length + 1);
if (key == "") {
key = "/";
}
currentContent[key] = true;
}
for (var resourceKey of Object.keys(RESOURCES)) {
if (!currentContent[resourceKey]) {
resources.push(resourceKey);
}
}
return contentCache.addAll(resources);
}
function onlineFirst(event) {
var resourceKey = getResourceKey(event.request);
var resourceInfo = RESOURCES[resourceKey] || RESOURCES['/'];
return event.respondWith(
fetch(event.request).then((response) => {
return caches.open(CACHE_NAME).then((cache) => {
cache.put(event.request, response.clone());
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: event.request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: resourceInfo?.size || 0,
status: 'completed'
});
return response;
});
}).catch((error) => {
return caches.open(CACHE_NAME).then((cache) => {
return cache.match(event.request).then((response) => {
if (response != null) {
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: event.request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: resourceInfo?.size || 0,
status: 'cached'
});
return response;
}
notifyClients({
resourceName: resourceInfo?.name || resourceKey,
resourceUrl: event.request.url,
resourceKey: resourceKey,
resourceSize: resourceInfo?.size || 0,
loaded: 0,
status: 'error',
error: error.message
});
throw error;
});
});
})
);
}
function getResourceKey(requestOrUrl) {
const url = typeof requestOrUrl === 'string'
? new URL(requestOrUrl, self.location.origin)
: new URL(requestOrUrl.url);
url.hash = '';
url.search = '';
let key = url.pathname;
if (key.startsWith('/')) key = key.slice(1);
if (key.endsWith('/') && key !== '/') key = key.slice(0, -1);
return key === '' ? '/' : key;
}
async function notifyClients(data) {
const allClients = await self.clients.matchAll({ includeUncontrolled: true });
allClients.forEach(client => {
try {
client.postMessage({
type: 'sw-progress',
timestamp: Date.now(),
resourcesSize: RESOURCES_SIZE,
...data
});
} catch {}
});
}