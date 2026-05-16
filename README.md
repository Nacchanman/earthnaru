# EarthNaru

EarthNaru is a small always-on iPhone SE companion app concept: a pixel-art Earth mascot trains on the iPhone screen and levels up as you type on a connected computer.

This repository currently contains a practical MVP design and starter implementation:

- `ios/EarthNaru/`: SwiftUI iOS app source.
- `pc-bridge/`: Node.js keyboard bridge that counts keystrokes on the computer and broadcasts them over WebSocket.
- `docs/implementation-plan.md`: implementation notes, limitations, and next steps.

## MVP architecture

Directly reading a computer keyboard from an iPhone over USB is not available to normal iOS apps. The MVP therefore uses a tiny bridge program on the computer:

1. Start the PC bridge on the computer.
2. The bridge opens a WebSocket server on port `8787`.
3. The iPhone app connects to `ws://<computer-ip>:8787`.
4. Each keypress increments the total key count.
5. The iPhone mascot trains continuously, levels up at defined thresholds, celebrates by lifting a level-specific object, and keeps the previous object beside it until the next level.

## Quick start

### 1. Run the computer bridge

```bash
cd pc-bridge
npm install
npm start
```

Keep the terminal focused and type. Each keypress will be counted and sent to connected iPhone clients.

The bridge prints your local IP addresses. Use one of them in the iPhone app.

### 2. Create the iOS app project

The Swift files are intentionally plain SwiftUI files so they can be dropped into a fresh Xcode iOS project.

1. Open Xcode.
2. Create a new **iOS App** project named `EarthNaru`.
3. Use SwiftUI and Swift.
4. Replace the generated app files with the files in `ios/EarthNaru/`.
5. Add `NSLocalNetworkUsageDescription` from `ios/EarthNaru/Info.plist` to your app target Info settings.
6. Run on your iPhone SE.
7. Enter the computer WebSocket URL, for example `ws://192.168.1.20:8787`, and tap Connect.

## Current limitations

- The included bridge counts keys only while its terminal window is focused. This is intentional for the first safe MVP because true global keyboard capture requires OS-specific accessibility permissions or native modules.
- iOS and the computer must be able to reach each other over the same network. USB tethering can work if it creates a reachable network route, but a normal Lightning/USB cable alone is not enough for a regular App Store-style iOS app.
- The mascot is drawn with SwiftUI pixel-style rectangles, not a bundled image asset yet.

## Next steps

See `docs/implementation-plan.md` for the recommended build order.