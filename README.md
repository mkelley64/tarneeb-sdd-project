# tarneeb-sdd-project
Experiment with Specification Driven Development

## Launch screen

Both system launch and the in-app intro display `طرنيب` (matching the table) in 52-point Geeza Pro and muted gold `#BBAA7E`, above a five-card fan on primary green `#1E5A3C`. The 80-point title area accommodates Arabic ascenders and descenders.

On a fresh process launch, a retained storyboard overlay holds for one second. The game then mounts without animation, gets a 100ms layout interval, and appears as the overlay fades away over 0.7 seconds with ease-in-out timing. Animation state belongs to `LaunchRootView`, not the App/Scene body. Interaction becomes available when the reveal completes. Reduce Motion disables the fade; returning from the background does not replay a completed intro. Game content and timers start only after the hold; gameplay timing tokens are unchanged.

The fan reuses existing xCards assets. Regenerate its PDF from the repository root with `swift tools/make-launch-fan.swift`; source images are capped to the needed 3× display resolution and the asset catalog rasterizes the PDF for launch. Do not replace the card artwork or modify runtime timing tokens.

`TarneebTests/testLaunchScreenLayout` verifies compiled-storyboard loading, Arabic text/font/color, artwork, non-overlap, bounds and unambiguous layout at 320×568, 393×852 and 430×932 points. The focused launch/resume UI test passed; a simulator recording verified progressive blending. The final signed Release build was installed in place on iPhone 15 Pro on September 20 and the user accepted the transition. No TestFlight upload has been performed. Original playing-card assets remain unchanged; exploratory avatar previews were abandoned.

## TestFlight signing

The app, unit-test and UI-test targets use automatic signing with team `3QM6PM3F9J` in Debug and Release. The production bundle identifier remains `com.mkelley.Tarneeb`; version/build remain `1.0` / `1`. The shared Tarneeb scheme archives with Release. No command-line team override is needed.

In Xcode, use Product → Archive with an iOS device destination, then distribute the archive through App Store Connect for TestFlight. Ensure the matching app record is in this team and use a new build number for subsequent uploads. Distribution signing and App Store Connect validation happen during distribution; a successful local development-signed archive is not upload acceptance. See [Apple's distribution guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases).

September 20 release scope: iPhone-focused, portrait-only. All app/test Debug and Release configurations use `TARGETED_DEVICE_FAMILY = 1`; the iPad-specific orientation setting is removed. Native iPad support is deferred rather than enabling untested landscape layouts or adding the deprecated full-screen compatibility setting.

Verification: signed Release archives succeeded using the saved settings, with bundle ID `com.mkelley.Tarneeb` and signing team `3QM6PM3F9J`; signature verification passed. The archived app has `UIDeviceFamily = [1]` and portrait orientation. The prior iPad orientation warning is absent. The latest build was installed on the phone; App Store Connect distribution validation/upload remains a separate step.
