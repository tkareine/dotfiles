// Firefox user preferences, overriding settings in `about:config`
//
// Read more:
// - https://kb.mozillazine.org/User.js_file
// - https://wiki.archlinux.org/title/Firefox/Privacy
//
// In order to test validity of preferences, run in terminal:
//
// /Applications/Firefox.app/Contents/MacOS/firefox
//
// Semicolons ending JavaScript statements are mandatory.

// Scroll viewport with left/right swipe gestures.
user_pref("browser.gesture.swipe.left", "cmd_scrollLeft");
user_pref("browser.gesture.swipe.right", "cmd_scrollRight");

// Disable double tap to zoom
//
// Read more: https://support.mozilla.org/en-US/questions/1317872
user_pref("apz.allow_double_tap_zooming", false);

// Disable browser telemetry
//
// Read more:
// https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html
//
// Disable unified behavior. Allows disabling
// `toolkit.telemetry.enabled`.
user_pref("toolkit.telemetry.unified", false);
// Disable telemetry module
user_pref("toolkit.telemetry.enabled", false);
// Disable ping local archiving
user_pref("toolkit.telemetry.archive.enabled", false);

// Enable Enhanced Tracking Protection (TP)
//
// Read more:
// - https://support.mozilla.org/en-US/kb/enhanced-tracking-protection-firefox-desktop
// - https://developer.mozilla.org/en-US/docs/Web/Privacy/Tracking_Protection
// - https://wiki.mozilla.org/Security/Tracking_protection
user_pref("privacy.trackingprotection.enabled", true);
// Enable TP in Private Browsing mode
user_pref("privacy.trackingprotection.pbmode.enabled", true);
// Enable fingerprinting protection
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
// Enable cryptomining protection
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
// Enable social media tracking protection
user_pref("privacy.trackingprotection.socialtracking.enabled", true);

// Force all connections to websites to use https.
//
// Read more: https://support.mozilla.org/en-US/kb/https-only-prefs
user_pref("dom.security.https_only_mode", true);

// Enable DNS-over-HTTPS.
//
// Read more:
// - https://support.mozilla.org/en-US/kb/firefox-dns-over-https
// - https://wiki.mozilla.org/Trusted_Recursive_Resolver
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");

// Make SameSite=Lax as the default behavior for cookies that don't
// specify the SameSite attribute.
//
// Read more: https://web.dev/samesite-cookies-explained/
//
// Current status:
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite
user_pref("network.cookie.sameSite.laxByDefault", true);

// Disable sending DNT (Do Not Track) header on requests as it can be
// used for fingerprinting.
//
// Read more:
// - https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/DNT
// - https://kb.mozillazine.org/Privacy.donottrackheader.enabled
user_pref("privacy.donottrackheader.enabled", false);
