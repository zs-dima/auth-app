import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;

/// Returns the current window origin for the HTTP client.
/// On non-web platforms, this returns an empty string as there is no window origin.
String $getOrigin() => '';

/// Creates an HTTP client optimized for native platforms (VM).
///
/// Uses [IOClient] which provides better performance and
/// connection pooling on native platforms.
http.Client $createHttpClient() => io_client.IOClient();
