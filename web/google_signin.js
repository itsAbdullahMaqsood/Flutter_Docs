let googleUser;

function initGoogleSignIn(clientId, callbackName) {
  google.accounts.id.initialize({
    client_id: clientId,
    callback: (response) => {
      // Call back into Dart
      window[callbackName](response);
    },
  });

  // Render the button inside a div with id="g_id_signin"
  google.accounts.id.renderButton(
    document.getElementById("g_id_signin"),
    { theme: "outline", size: "large" } // styling options
  );

  // Optionally show One Tap prompt
  google.accounts.id.prompt();
}
