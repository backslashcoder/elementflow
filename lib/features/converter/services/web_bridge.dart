/// Browser-only functionality (sandboxed iframe, file download) behind a
/// conditional import so everything else stays testable on the Dart VM.
library;

export 'web_bridge_stub.dart'
    if (dart.library.js_interop) 'web_bridge_web.dart';
