#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
ai_build=$(mktemp -d /tmp/tarneeb-ai.XXXXXX)
swift_root=/Applications/Xcode.app/Contents/Developer
"$swift_root/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc" \
  -sdk "$swift_root/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" \
  -target arm64-apple-macosx15.0 -O -module-cache-path "$ai_build/cache" \
  Tarneeb/DomainModels.swift Tarneeb/DesignTokens.swift Tarneeb/MatchPersistence.swift Tarneeb/AISkill.swift Tarneeb/AIBidding.swift \
  tools/ai/FrozenStandard.swift tools/ai/FrozenAdvanced.swift tools/ai/Benchmark.swift tools/ai/Verification.swift tools/ai/BiddingVerification.swift tools/ai/BiddingBenchmark.swift tools/ai/AdvancedAblationPolicy.swift tools/ai/AdvancedAblation.swift tools/ai/PublicThreatPolicy.swift tools/ai/PublicThreatEvaluation.swift tools/ai/PublicThreatIntegration.swift tools/ai/TrialPublicThreatExpert.swift tools/ai/FullMatchBenchmark.swift tools/ai/MatchComponentEvaluation.swift tools/ai/LatencyDiagnostics.swift tools/ai/main.swift -o "$ai_build/verify"
"$ai_build/verify" "$@"
