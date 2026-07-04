// Extracts launch parameters (message, referrer, UTM) into window._appInitialParams for Dart.
// External file: the prod CSP has no 'unsafe-inline'. Must run before the deferred bootstrap.
(function () {
  var data = { message: null, referrer: null, params: {} };

  // 1. Try window.name (primary channel)
  if (window.name) {
    try {
      var parsed = JSON.parse(window.name);
      if (parsed && typeof parsed === 'object' && ('message' in parsed || 'referrer' in parsed)) {
        data.message = parsed.message || null;
        data.referrer = parsed.referrer || null;
        if (parsed.params && typeof parsed.params === 'object') {
          data.params = parsed.params;
        }
        window.name = ''; // Clear after reading
      }
    } catch (e) {
      // Not our data, ignore
    }
  }

  // 2. Read query parameters (present in both primary and fallback)
  var searchParams = new URLSearchParams(window.location.search);
  if (!data.referrer) {
    data.referrer = searchParams.get('referrer') || null;
  }
  // Extract custom params from URL (fallback path puts them in query)
  searchParams.forEach(function (value, key) {
    if (key !== 'auto_accept_policies' && key !== 'referrer') {
      if (!data.params[key]) {
        data.params[key] = value;
      }
    }
  });

  // 3. Read message from hash (fallback path only)
  if (!data.message && window.location.hash.length > 1) {
    try {
      data.message = decodeURIComponent(window.location.hash.substring(1));
    } catch (e) {
      data.message = window.location.hash.substring(1);
    }
  }

  // Expose to Dart (URL cleanup is handled on the Dart side)
  window._appInitialParams = data;
})();
