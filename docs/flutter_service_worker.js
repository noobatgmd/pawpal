'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ca11260cbbf8756100ebe3538ee65a9f",
"assets/AssetManifest.bin.json": "0674dbd4e475d14bff674b6d0b07549e",
"assets/AssetManifest.json": "8935a18fded63aa8359fe811007377e1",
"assets/assets/img/bamboocomb.png": "603676e4ff5b296fbf7fea667de85ad6",
"assets/assets/img/catindoorfood.png": "e6ba9cf66b582ad23e3a1f91b209c445",
"assets/assets/img/catlitterbox.png": "66af6fde1b92aa003cc2cfaeb8893dab",
"assets/assets/img/catscratchpost.png": "36809da28e78fdc1655550e3fe6502a9",
"assets/assets/img/cattreat.png": "7ccddc0e5d7783a321854d78c2bea7f7",
"assets/assets/img/cattreehouse.png": "0c0cf0e6d05aeedf2427523ad95f084c",
"assets/assets/img/cesarfood.png": "3a0dc3ddd784ec4bf8fce41ee718a6d8",
"assets/assets/img/chickenbonebroth.png": "9520b757965708e128da23794e98752c",
"assets/assets/img/dentalchew.png": "6caae7e8d440f7d90347f065b69d2da8",
"assets/assets/img/dogcage.png": "88a6d501c0366c429bc2ddf177103d33",
"assets/assets/img/doggroomingkit.png": "46d2cb4bd57f94a8046c6b18cb6026d4",
"assets/assets/img/dogshampoo.png": "39d57abe5595ca96debe4f5861b420d9",
"assets/assets/img/dogtoy.png": "946c86c7d4c7f6d3fa74e4ed49ff1e24",
"assets/assets/img/kittenwetfood.png": "b80673ed35d43d2203e7ef34d6b7f104",
"assets/assets/img/lilykitchencatfood.png": "c7a62caa549dbbb4cf333a5cf7914470",
"assets/assets/img/pawpal_logo.png": "d34423a42aefdef066adb8321e3887bf",
"assets/assets/img/pedigree.png": "9be8cb49bb5943fe3828071608a3e9d3",
"assets/assets/img/petcubes.png": "de8306d78353e8bf20944580b849b41d",
"assets/assets/img/petwipes.png": "ea24e91a267b27aecc8987037613b394",
"assets/assets/img/promo_banner.png": "3bc7334fb52759a43c448589effb6a5e",
"assets/assets/img/promo_banner_2.png": "57a8d6cffac215dfab978c8e6871f9b5",
"assets/assets/img/promo_banner_3.png": "7a1be29881c352073d97c4e14c2f3615",
"assets/assets/img/promo_banner_4.png": "1e68ccdded7937c57ca0777fe680e4e5",
"assets/assets/img/promo_banner_5.png": "21f161001d4dce7afec702276c587be3",
"assets/assets/img/salmonoilfordogsandcats.png": "e3ad56e0097032e08d4e01bf45f35f44",
"assets/assets/img/wanpydogchew.png": "0965e0538f480993f69534d14f3e267b",
"assets/assets/img/weepads.png": "b57d77918b3b3708898dc7caddffaddf",
"assets/assets/img/wheelfeeder.png": "aea47bc3b3d746bff7dbb14560385959",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "9e75d45abf0ba9740627dffac21bceda",
"assets/NOTICES": "e4e2ea767db28ca4829a4d84652e4b6c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "7fa1f2e06b8f421c0b7d3eb7d5c9ed8e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "a80e68bf7a3338ddc721c583cc683936",
"/": "a80e68bf7a3338ddc721c583cc683936",
"main.dart.js": "a0d79bca1907475d7987e797e8ff9407",
"manifest.json": "f1b3bafc4e62becac9c5f1660e2bf51f",
"version.json": "f8a84574e0d04c40ba59ecfc8d4039aa"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
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
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
