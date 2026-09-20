#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
audit_build=$(mktemp -d /tmp/tarneeb-ablation-tactics.XXXXXX)
swift_root=/Applications/Xcode.app/Contents/Developer
"$swift_root/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc" \
  -sdk "$swift_root/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" \
  -target arm64-apple-macosx15.0 -O -module-cache-path "$audit_build/cache" \
  Tarneeb/DomainModels.swift Tarneeb/DesignTokens.swift Tarneeb/MatchPersistence.swift Tarneeb/AISkill.swift Tarneeb/AIBidding.swift \
  tools/ai/FrozenAdvanced.swift tools/ai/AdvancedAblationPolicy.swift tools/ai/AdvancedTacticAudit.swift -o "$audit_build/audit"
"$audit_build/audit" "$@"
