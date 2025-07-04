#!/usr/bin/env bash
#
# References:
#
# * `man 1 defaults`
# * https://macos-defaults.com/
# * https://www.real-world-systems.com/docs/defaults.1.html
#
# Originally adapted from Mathias Bynens' `.macos`, available at
# https://mths.be/macos . Thanks!

set -euo pipefail

PBUDDY=/usr/libexec/PlistBuddy
SOCKETFILTERFW=/usr/libexec/ApplicationFirewall/socketfilterfw

# -- Ask for sudo upfront before any changes ---------------------------------

echo "Asking sudo privileges upfront before any changes…"

sudo -v

# -- System ------------------------------------------------------------------

# Require password 1 min after entering sleep or showing screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 60

# Power management states cheat sheet:
#
# [active] -(idle timeout)-> [idle] -(sleep timeout)-> [sleep]
#                                                      or [hibernate] if hibernatemode == 25
#
#            ,-(standbydelay timeout)-> [hibernate]
#           / if standby == 1 and hibernatemode == 3
# [sleep] -+
#           \ if autopoweroff == 1
#            `-(autopoweroffdelay timeout)-> [hibernate]

# Power management: sleep timeouts for all power sources (in minutes)
sudo pmset -a displaysleep 10 disksleep 20 sleep 20

# Power management: sleep timeouts for battery (in minutes)
sudo pmset -b displaysleep 5 disksleep 5 sleep 5

# Power management: disable Power Nap to conserve power
sudo pmset -a powernap 0

# Power management: copy memory to disk, power memory during sleep,
# power off memory during hibernate
sudo pmset -a hibernatemode 3

# Power management: enable hibernate, enter hibernate after 1 h (in
# seconds, default 3 h)
sudo pmset -a standby 1
sudo pmset -a standbydelay 3600

# Power management: ensure autopoweroff is disabled
sudo pmset -a autopoweroff 0

# Power management: don't wake the machine when power source is changed
sudo pmset -a acwake 0

# Power management: don't wake the machine when the laptop lid is opened
sudo pmset -a lidwake 0

# Power management: prevent idle system sleep when any TTY (e.g. ssh) is
# 'active'
sudo pmset -a ttyskeepawake 1

# Application layer firewall: enable with logging, stealth mode, allow
# signed built-in apps (by default), disallow downloaded signed apps (by
# default)
sudo "$SOCKETFILTERFW" \
     --setglobalstate on \
     --setstealthmode on \
     --setallowsigned on \
     --setallowsignedapp off \
     >/dev/null

# Application layer firewall: restart
sudo pkill -HUP -xf "$SOCKETFILTERFW"

# Localization
defaults write NSGlobalDomain AppleLanguages -array "en-US" "fi-FI"
defaults write NSGlobalDomain AppleLocale -string "en_FI"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 "d.M.y" 2 "d MMM y"
defaults write NSGlobalDomain AppleICUTimeFormatStrings -dict 4 "HH' h 'mm' min 'ss' s 'zzzz"

# Set the timezone; see `sudo systemsetup -listtimezones` for other
# values
sudo systemsetup -settimezone "Europe/Helsinki" > /dev/null

# Dark interface style
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Display ASCII control characters using caret notation in standard text
# views.  Try: `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Automatically show scroll bars (options: WhenScrolling, Automatic,
# Always)
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

# Opening documents prefers windows, open tabs manually
defaults write NSGlobalDomain AppleWindowTabbingMode -string "manual"

# Menu Bar: keep it visible, but…
defaults write NSGlobalDomain _HIHideMenuBar -bool false

# Menu Bar: hide it in fullscreen mode
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool false

# Menu Bar: date format in menubar
defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM  H.mm"

# Window Manager: disable stage manager
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Window Manager: indicate that I've completed tutorial functions
defaults write com.apple.WindowManager GloballyEnabledEver -bool true
defaults write com.apple.WindowManager HasDisplayedShowDesktopEducation -bool true

# Window Manager: use click wallpaper to reveal desktop only in stage manager
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Window Manager: enable tiling by dragging windows to screen edges
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool true

# Window Manager: enable Option shortcut to highlight window tiling area
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool true

# Window Manager: disable margins of tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Dock: only show when moving pointer to the screen edge
defaults write com.apple.dock autohide -bool true

# Dock: show indicator lights for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Dock: tile size and magnification off
defaults write com.apple.dock tilesize -int 32
defaults write com.apple.dock largesize -int 100
defaults write com.apple.dock magnification -bool false

# Dock: disable icon bouncing
defaults write com.apple.dock no-bouncing -bool true

# Dock: place dock on the right
defaults write com.apple.dock orientation -string "right"

# Dock: don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Dock: don't show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Dock: group windows by application in Mission Control
defaults write com.apple.dock expose-group-apps -bool true

# Dock: disable all Hot Corners
#
# wvous-C-corner: action associated with the corner; 0 for no-op
#
# wvous-C-modifier: modifier keys (as a bit mask) which need to be
# pressed for the hot corner to trigger; 0 for no modifier
#
# Where C signifies corner: bottom-left (bl), bottom-right (br),
# top-left (tl), and top-right (tr)
#
# See
# https://blog.jiayu.co/2018/12/quickly-configuring-hot-corners-on-macos/
disable_dock_hot_corners() {
    local corner
    local corners=(bl br tl tr)

    for corner in "${corners[@]}"; do
        defaults write com.apple.dock "wvous-$corner-corner" -int 0
        defaults write com.apple.dock "wvous-$corner-modifier" -int 0
    done
}

disable_dock_hot_corners

# Keyboard, text: disable automatic spelling correction
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Keyboard, text: disable automatic word capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Keyboard, text: disable adding period with double-space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Keyboard, text: don't use smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Keyboard: enable full keyboard access for all controls (e.g. enable
# Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Keyboard: set key repeat speed
defaults write NSGlobalDomain KeyRepeat -int 2

# Keyboard: set delay until key repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Keyboard: use F1, F2, etc. keys as standard function keys
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Keyboard: set the Globe key to Do Nothing; the Fn functionality of the
# key still works with the function keys (F1, F2, etc.)
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

# Trackpad: disable click with one finger tap gesture
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 0

# Trackpad: enable secondary click with two fingers
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Trackpad: enable three fingers gestures (required for App Expose and
# Mission Control gestures below)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerVertSwipeGesture -int 2

# Trackpad: enable Look up & data detectors with three fingers tap
# gesture
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerTapGesture -int 2
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false

# Trackpad: enable Smart zoom with two fingers tap gesture
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.twoFingerDoubleTapGesture -int 1

# Trackpad: enable App Expose with swipe down with three fingers gesture
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Trackpad: enable Mission Control with swipe up with three fingers
# gesture
defaults write com.apple.dock showMissionControlGestureEnabled -bool true

# Trackpad: set clicking sound to minimum
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0

# Trackpad: disable clicking sound
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

# Sound: don't play sound on startup
sudo nvram StartupMute=%01

# Sound: don't play UI sound effects
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

# Sound: don't play feedback when changing volume
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 0

# Universal access: disable transparency in the menu bar and elsewhere
defaults write com.apple.universalaccess reduceTransparency -bool true

# Universal access: use scroll gesture with the Ctrl (^) modifier key to
# zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Screen capture: save to the downloads directory
defaults write com.apple.screencapture location -string "$HOME/Downloads"

# Screen capture: save in PNG format (options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Screen capture: disable shadow
defaults write com.apple.screencapture disable-shadow -bool true

# Spotlight: disable suggestions in look up
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Finder: display full POSIX path as window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: hide icons for hard drives on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

# Finder: hide icons for mounted servers on desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# Finder: show icons for removable media on desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: when performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Finder: enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Finder: avoid creating .DS_Store files on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Finder: use list view in all Finder windows by default Four-letter
# codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: show ~/Library
chflags nohidden ~/Library

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Time Machine: prevent from prompting to use new hard drives as backup
# volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable selected Services keyboard shortcuts
disable_selected_services_keyboard_shortcuts() {
    local shortcuts=(
        'com.apple.Terminal - Open man Page in Terminal - openManPage'
        'com.apple.Terminal - Search man Page Index in Terminal - searchManPages'
    )

    local plist_path=~/Library/Preferences/pbs.plist

    for key in "${shortcuts[@]}"; do
        "$PBUDDY" -c "Add :NSServicesStatus:'$key' dict" "$plist_path" 2>/dev/null || true
        "$PBUDDY" -c "Add :NSServicesStatus:'$key':enabled_context_menu bool" "$plist_path" 2>/dev/null || true
        "$PBUDDY" -c "Set :NSServicesStatus:'$key':enabled_context_menu false" "$plist_path"
        "$PBUDDY" -c "Add :NSServicesStatus:'$key':enabled_services_menu bool" "$plist_path" 2>/dev/null || true
        "$PBUDDY" -c "Set :NSServicesStatus:'$key':enabled_services_menu false" "$plist_path"
        "$PBUDDY" -c "Add :NSServicesStatus:'$key':presentation_modes dict" "$plist_path" 2>/dev/null || true
        "$PBUDDY" -c "Add :NSServicesStatus:'$key':presentation_modes:ContextMenu bool" "$plist_path" 2>/dev/null || true
        "$PBUDDY" -c "Set :NSServicesStatus:'$key':presentation_modes:ContextMenu false" "$plist_path"
        "$PBUDDY" -c "Add :NSServicesStatus:'$key':presentation_modes:ServicesMenu bool" "$plist_path" 2>/dev/null || true
        "$PBUDDY" -c "Set :NSServicesStatus:'$key':presentation_modes:ServicesMenu false" "$plist_path"
    done
}

disable_selected_services_keyboard_shortcuts

# -- Applications ------------------------------------------------------------

# Safari: Prevent opening "safe" files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Safari: enable Develop menu and Web Inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Safari: add a context menu item for showing Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Safari: use cmd+1 to cmd+9 to switch tabs
defaults write com.apple.Safari Command1Through9SwitchesTabs -bool true

# Safari: disable activating new tab when opening it
defaults write com.apple.Safari OpenNewTabsInFront -bool false

# Safari: warn about fraudulent web sites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Safari: block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Safari: ask websites not to track me
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Mail: disable new mail sound
defaults write com.apple.mail MailSound -string ""
defaults write com.apple.mail PlayMailSounds -bool false

# Mail: prefer plain format
defaults write com.apple.mail SendFormat -string "Plain"

# iCal: show week numbers
defaults write com.apple.iCal 'Show Week Numbers' -bool true

# Notes: set additional keyboard shortcuts; see
# `Library/KeyBindings/DefaultKeyBinding.dict` for a summary of key
# modifiers
defaults write com.apple.Notes NSUserKeyEquivalents -dict \
         'Remove Style' '@~c' \
         'Bulleted List' '@~b' \
         'Dashed List' '@~v' \
         'Numbered List' '@~n'

# TextEdit: use plain text mode for new documents
defaults write com.apple.TextEdit RichText -int 0

# TextEdit: open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Google Chrome: disable swipe navigation, because it has bad
# implementation
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# Mozilla Firefox: set additional keyboard shortcuts
# shellcheck disable=SC2016
defaults write org.mozilla.firefox NSUserKeyEquivalents -dict 'Firefox View' '@$0'

# KeePassXC: set additional keyboard shortcuts; see
# `Library/KeyBindings/DefaultKeyBinding.dict` for a summary of key
# modifiers
defaults write org.keepassxc.keepassxc NSUserKeyEquivalents -dict 'Password Generator' '@g'

# -- Apply changes -----------------------------------------------------------

sudo pkill -x cfprefsd

for app in \
        "Google Chrome Canary" \
        "Google Chrome" \
        Calendar \
        Dock \
        Finder \
        Mail \
        Notes \
        Safari \
        SystemUIServer \
        TextEdit \
        firefox \
    ; do
    pkill -x "${app}" || true
done

echo "Applied. Some of the changes might require logout/restart to take effect."
