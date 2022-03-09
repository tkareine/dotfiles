// Thunderbird user preferences
//
// In order to test validity of preferences, run in terminal:
//
// /Applications/Thunderbird.app/Contents/MacOS/thunderbird
//
// Semicolons ending JavaScript statements are mandatory.

// Date formats for messages. Time is always included. Ignores locale
// for some reason.
//
// Read more: https://kb.mozillazine.org/Date_display_format
//
// 0 - No date
// 1 - Long date (system format)
// 2 - Short date (system format)
// 3 - month/year (slash separated)
// 4 - Abbreviated day name
user_pref("mail.ui.display.dateformat.today", 0);
user_pref("mail.ui.display.dateformat.thisweek", 2);
user_pref("mail.ui.display.dateformat.default", 2);

// Collect outgoing email addresses automatically.
user_pref("mail.collect_email_address_outgoing", true);

// Disable sending DNT (Do Not Track) header on requests as it can be
// used for fingerprinting.
user_pref("privacy.donottrackheader.enabled", false);

// Don't allow loading remote content in messages.
user_pref("mailnews.message_display.disable_remote_image", true);

user_pref("mail.chat.play_sound", false);

user_pref("mail.chat.enabled", false);
