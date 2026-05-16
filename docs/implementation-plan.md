# EarthNaru implementation plan

## Goal

Build an always-on iPhone SE display app that shows a pixel-art Earth mascot training. The mascot grows by level as the user types on a computer. When it levels up, it briefly lifts a new object that matches that level, then leaves that object beside it until the next level.

## Connectivity choice

A normal iOS app cannot directly read arbitrary keystrokes from a Mac/Windows/Linux computer through a Lightning or USB cable. For the MVP, use a small computer-side bridge that sends key-count events to the iPhone over WebSocket.

Recommended first version:

```text
Computer keyboard -> Node.js bridge -> WebSocket over local network -> iPhone SwiftUI app
```

This keeps the app simple, testable, and compatible with iPhone SE.

Possible later versions:

- macOS native menu-bar bridge with accessibility permission for global key capture.
- Windows native bridge using Raw Input or a signed native helper.
- BLE HID-style counter device, if hardware is introduced.
- Local-only web app shown on iPhone Safari, if App Store packaging is not needed.

## MVP behavior

### Leveling

The starter Swift model uses these thresholds:

| Level | Required key count | Lifted object |
| --- | ---: | --- |
| 1 | 0 | Feather |
| 2 | 50 | Pencil |
| 3 | 150 | Book |
| 4 | 350 | Dumbbell |
| 5 | 700 | Keyboard |
| 6 | 1,200 | Boulder |
| 7 | 2,000 | Small moon |
| 8 | 3,500 | Rocket |
| 9 | 5,500 | Mountain |
| 10 | 8,000 | Tiny sun |

These are deliberately small for testing. Increase them after the loop feels good.

### Animation states

- Idle/training loop: squat/curl-like motion using a timer-driven phase value.
- Level-up celebration: mascot raises the newly unlocked object overhead.
- Trophy display: the latest unlocked object sits beside the mascot until the next level.

### Persistence

The app stores total key count in `UserDefaults`. This makes the level survive app restarts.

## Files

- `ios/EarthNaru/EarthNaruApp.swift`: SwiftUI app entry point.
- `ios/EarthNaru/ContentView.swift`: connection UI and main screen.
- `ios/EarthNaru/MascotView.swift`: pixel-art Earth mascot and object rendering.
- `ios/EarthNaru/GameModel.swift`: key count, levels, persistence, celebration state.
- `ios/EarthNaru/KeyboardBridgeClient.swift`: WebSocket client.
- `ios/EarthNaru/Info.plist`: local network permission text.
- `pc-bridge/index.js`: Node WebSocket keyboard bridge.
- `pc-bridge/package.json`: Node package definition.

## Build order

1. Run the Node bridge locally and confirm it prints key counts.
2. Run the iOS app in the simulator and connect to `ws://localhost:8787`.
3. Run on the physical iPhone SE and connect to `ws://<computer-ip>:8787`.
4. Tune level thresholds and animation timing.
5. Replace the SwiftUI pixel mascot with a proper pixel-art asset sheet if desired.
6. Build OS-specific global key capture only after the basic loop is fun.

## What the user needs to do

- Install Xcode on a Mac to build the iPhone app.
- Install Node.js on the computer used for typing.
- Keep iPhone and computer on the same network, or set up a tethered network route.
- For real all-app key capture later, grant OS permissions to a native bridge app. The current MVP intentionally only counts keys typed into the bridge terminal.