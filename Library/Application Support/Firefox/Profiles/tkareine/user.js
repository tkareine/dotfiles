// Firefox user preferences, overriding settings in `about:config`
//
// Read more: https://kb.mozillazine.org/User.js_file
//
// To test, run in terminal:
// /Applications/Firefox.app/Contents/MacOS/firefox
//
// Semicolons ending JavaScript statements are mandatory.

// Scroll viewport with left/right swipe gestures.
user_pref("browser.gesture.swipe.left", "cmd_scrollLeft");
user_pref("browser.gesture.swipe.right", "cmd_scrollRight");

// Make SameSite=Lax as the default behavior for cookies that don't
// specify the SameSite attribute.
//
// Read more: https://web.dev/samesite-cookies-explained/
//
// Current status:
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite
user_pref("network.cookie.sameSite.laxByDefault", true);

// Force all connections to websites to use https.
//
// Read more: https://support.mozilla.org/en-US/kb/https-only-prefs
user_pref("dom.security.https_only_mode", true);

// Enable DNS-over-HTTPS
//
// Read more:
// - https://support.mozilla.org/en-US/kb/firefox-dns-over-https
// - https://wiki.mozilla.org/Trusted_Recursive_Resolver
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");

// Disable RTCPeerConnection of the WebRTC API. Prevents leaking source
// IP address.
//
// Read more:
// - https://wiki.mozilla.org/Media/WebRTC/Privacy
// - https://mozilla.github.io/webrtc-landing/gum_test.html
user_pref("media.peerconnection.enabled", false);
