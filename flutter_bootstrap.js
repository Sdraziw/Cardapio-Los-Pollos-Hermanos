// flutter_bootstrap.js

// This script is responsible for loading the Flutter web application.

(function() {
  // The URL of the main Dart entrypoint file.
  var scriptUrl = 'main.dart.js';

  // Create a script element to load the Dart entrypoint.
  var scriptElement = document.createElement('script');
  scriptElement.src = scriptUrl;
  scriptElement.type = 'application/javascript';

  // Append the script element to the document body.
  document.body.appendChild(scriptElement);
})();