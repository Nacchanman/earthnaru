# EarthNaruMac

A native macOS companion version of EarthNaru.

It shows a small always-on floating mascot window near the edge of the MacBook screen. The mascot trains and levels up based on the number of keys typed on the Mac.

## Current MVP

This folder contains a SwiftUI/AppKit starter implementation that can be copied into a new macOS App target in Xcode.

Features included:

- Borderless floating companion window.
- Menu bar controls for show/hide, pause/resume, reset, corner placement, and quit.
- Global key-down counting using a Core Graphics event tap.
- Accessibility permission request/check.
- Privacy-safe counter: it only increments a number and does not store typed characters.
- Persistent total key count using `UserDefaults`.
- SwiftUI pixel-style Earth mascot with level-up celebration.

## How to run in Xcode

1. Open Xcode.
2. Create a new **macOS App** project named `EarthNaruMac`.
3. Use SwiftUI and Swift.
4. Copy all `.swift` files in this folder into the app target.
5. Run the app.
6. When prompted, allow Accessibility permission:
   - System Settings -> Privacy & Security -> Accessibility -> EarthNaruMac
7. Restart the app after enabling permission.

## Important permission note

macOS will not let a normal app observe keyboard events from other apps unless Accessibility permission is enabled. Without permission, the floating mascot still appears, but global key counting will not work.

## Privacy note

The app never stores typed text. `KeyboardMonitor` only listens to `.keyDown` events and increments a counter.