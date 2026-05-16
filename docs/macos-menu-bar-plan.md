# macOS corner companion plan

## Goal

Show EarthNaru as a small always-on companion window in the corner of a MacBook screen. The character changes and levels up based on the number of keys typed on that MacBook.

## Recommended implementation

For a Mac-only version, build a native macOS app instead of routing through an iPhone.

```text
Mac keyboard events -> macOS Accessibility event tap -> local game model -> floating SwiftUI window
```

## Why this is better for MacBook-only use

- No iPhone connection is needed.
- The mascot can stay in a small floating panel at the edge of the screen.
- The key count can update immediately.
- The same SwiftUI mascot/game model from the iOS prototype can be reused with small changes.

## Required macOS permission

To count keys typed in other apps, the app needs Accessibility permission.

The user must enable it in:

System Settings -> Privacy & Security -> Accessibility -> EarthNaru

Without this permission, the app can only reliably count keys typed while the EarthNaru window itself is focused.

## App shape

Use a SwiftUI macOS app with:

- `NSPanel` or a borderless floating `NSWindow`.
- `level = .floating` so it stays above normal windows.
- `collectionBehavior = [.canJoinAllSpaces, .stationary]` so it appears across desktops.
- A small draggable mascot view, for example 180 x 240 px.
- A menu bar icon for pause, reset, quit, and corner selection.

## Key capture

Use `CGEvent.tapCreate` with `.cgSessionEventTap` and listen for `.keyDown` events.

Important details:

- Count only key-down events, not key-up events.
- Ignore auto-repeat if desired via `event.getIntegerValueField(.keyboardEventAutorepeat)`.
- Do not record actual characters. Store only counts for privacy.
- Save counts locally with `UserDefaults` or a small JSON file.

## Suggested MVP milestones

1. Create a macOS SwiftUI target.
2. Reuse the existing level table and mascot view idea.
3. Display the mascot in a floating window in the bottom-right corner.
4. Add an Accessibility permission check.
5. Count global key-down events.
6. Persist total key count.
7. Add menu bar controls: pause, reset, quit.
8. Later, share progress with the iPhone app over local WebSocket if desired.

## Privacy stance

The app should never store the typed letters. It should only increment an integer counter. This makes the implementation safer and easier to explain to users.