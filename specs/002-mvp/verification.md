# Tarneeb iOS MVP 002 Verification Notes

## Setup Verification

- Date: 2026-05-26
- Project: `Tarneeb.xcodeproj`
- Scheme: `Tarneeb`
- App target: `Tarneeb`
- Unit test target: `TarneebTests`
- UI test target: `TarneebUITests`

## Small-Screen Simulator Choice

For MVP 002 layout verification, use `iPhone SE (3rd generation)` as the
small-screen simulator unless product specifies a stricter target.

Selected destination from `xcodebuild -project Tarneeb.xcodeproj -scheme Tarneeb -showdestinations`:

- Platform: iOS Simulator
- Architecture: arm64
- OS: 18.6
- Name: `iPhone SE (3rd generation)`
- ID: `F81F73CC-A51C-4D3E-A51C-4C5BA7327280`

This destination is the smallest iPhone simulator currently available to the
project and satisfies the MVP 002 requirement to identify a small-screen
simulator for layout verification.
