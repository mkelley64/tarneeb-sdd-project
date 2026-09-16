# Tarneeb Rosette Card Back

Generated September 16, 2026 with the built-in image generation tool for this project. Source: `tarneeb-card-back-rosette.png`.

Design: burgundy field, muted gold eight-point geometric rosette and corner ornaments, ivory edge; no ranks, suit symbols, or lettering. Palette references are defined in specs/011-mvp/design-tokens.md, Contract and Card Identity. The source is retained at generated resolution; sips produces 64x90, 128x180, and 192x270 bundled variants in card_back.imageset. SwiftUI masks corners at display size.

Replaces the previous generic card-back artwork without changing the `card_back` asset name or hidden-card presentation metadata. Intended to read consistently from either orientation, without any mark encoding card identity.
