# Continued Play and Public-Information Tactics

Approved September 2026 continuation: last-trick recall, local match resume, natural opponent pacing and sound variation, and stronger public-information tactics.

## Acceptance Criteria

- CP-1: A compact history icon opens the last collected trick, showing all four cards, their owners, and the winner. It is unavailable before the first collection. The read-only sheet pauses automated play and resumes on dismissal; it also works from round results.
- CP-2: Save committed game state locally after every domain command. Relaunch restores hands, current turn/trick, bidding/trump, dealer, team scores, completed tricks, and round results. Interrupted animation resumes at its committed endpoint, not mid-flight. Unsubmitted bid/suit drafts and selected-card lift need not persist.
- CP-3: Use a versioned, atomically written save in Application Support. Validate decoded state before restoring. Missing saves start normally; corrupt/unsupported saves and write failures are reported without crashing. New Game replaces the old match. Resume cannot duplicate a play, collection, score, or result sound.
- CP-4: Simulated trick choices pause briefly: forced plays are fastest, discards/partner protection intermediate, and contested wins or leads slower. Delays remain cancellable and bounded; Reduce Motion changes movement, not game decisions. Bidding and opponent thinking delays are unchanged. Card movement uses the September 16 timing revision below.
- CP-5: Frequently repeated card sounds use bundled card-handling foley and cycle through three variants per action: a short slide/flick for selection, card placement for landing, and a gathered-card sweep for collection. Keep selection quieter than landing. Existing optional sound/haptic settings, silent mode, and ambient audio behavior remain intact. Result chimes do not change. Missing recordings fall back to the previous synthesized effect without interrupting play.
- CP-6: Use only own cards and public played cards to identify the highest remaining cards. Prefer a safe top non-trump lead, including promoted kings/queens; avoid a side suit when public history shows an opponent is void and unaccounted trump remains. On third seat, protect a partner's top remaining card, but strengthen a vulnerable partner winner with an unbeatable follow-suit card when available. Otherwise preserve the prior economical response policy. No hidden-hand access, search, or bidding changes.
- CP-7: Add focused model/persistence tests and actual recall/relaunch UI tests on compact and modern phones. Physical-device touch/audio/haptics and a human full-match playtest are explicitly separate checks, not established by simulator tests.

## Architecture and Edge Cases

LastTrickRecallButton captures an immutable CompletedTrick and reuses readable card faces in a sheet. Parent callbacks suspend/resume the existing turn scheduler. The current trick remains unchanged while reviewing.

MatchSnapshot stores a versioned Codable representation of authoritative domain state, scores, and once-only result-feedback bookkeeping. MatchStore performs atomic JSON replacement. TarneebPresentationState checkpoints at command boundaries, after scoring has completed. Restore validates canonical card conservation, trick sequence/legality, bidding coherence, round counts, and score consistency before accepting data. UI animation tasks and feedback players are never serialized. One local match is retained; cloud sync and match history are outside scope.

AutomatedCardSelector receives legal options, the player's own hand, the public trick, and completed tricks. Higher cards in the player's hand or public history are accounted for; unknown cards remain possible in any other hand. A publicly inferred void does not reveal which trump cards an opponent holds. Lead and third-seat policies are heuristics, not guaranteed future wins.

## Test Strategy

Test snapshot round trips for bidding, trump selection, live/pending/completed tricks, results, continuation, reset, and invalid versions/data. Test relaunch without test fixtures to prove actual disk restoration. Verify a pending final collection scores once. Tactical fixtures cover promotion, unknown higher cards, void/trump risk, partner protection, deterministic choices, and complete legal hands. Test pacing buckets and bounded sound variants. Check recall screenshots and pause/dismiss behavior on both phone sizes.

## Verification (September 15, 2026)

- CP-1: Recall UI tests cover the disabled initial state, all four owners/cards, winner emphasis, closing and continuing play, background/resume while open, and recall from results. Screenshots were inspected on iPhone 17 Pro (iOS 26.2) and iPhone SE 3 (iOS 18.6).
- CP-2/CP-3: Disk round trips cover every play and collection in a hand, pending final collection, once-only scoring/feedback bookkeeping, next-round score/dealer preservation, and New Game. Relaunch UI tests remove fixture overrides and restore actual files during bidding, trump selection, live play, and match results. Corrupt data, unsupported versions, invalid score/turn/contract state, and write failures are tested. Unit-test hosts skip the normal match store; persistence UI tests use isolated save IDs.
- CP-4/CP-5: Unit tests verify forced/discard/decision pause ordering and bounds. Generated WAV tests prove all three paper variants contain distinct non-silent PCM samples of the expected duration, while result chimes remain identical across variants.
- CP-6: Tests cover promoted winners, unknown higher cards, known voids with and without unknown trump, third-seat partner protection, hidden-hand independence, and 16 complete legal hands across every declarer/trump combination.
- Modern regression: 169 unit tests and all 22 current live/opening/result/continued-play UI tests passed. Final compact run: 169 unit tests and all four continued-play UI tests passed, including the last storage-validation safeguards. No failures or skips in these final runs. The superseded historical layout UI suite was not included.
- Initial recall runs exposed a blank-sheet presentation bug and inherited accessibility identifiers. Item-bound presentation and an explicit accessibility container fixed these; the affected cases passed in the final runs.

## Physical-Device Follow-Up

On September 16, the app was installed on the iPhone 15 Pro. Initial user feedback: the app looks good on device, but synthesized card sounds need a more realistic card-flipping character. The September 15 automated results above predate this audio revision. Remaining checks:

- Play a full match using thumb selection, double-tap, and drag; inspect recall without mis-taps.
- Tune sound volume and repetition, and feel selection, landing, collection, and result haptics.
- Verify independent feedback toggles, silent mode, and music from another app.
- Lock/unlock and close/reopen during play, then verify the restored hand and score.
- Complete VoiceOver, large-text, and frame-time checks before claiming full accessibility/performance validation.

## Card Foley Revision (September 16, 2026)

Replace the three synthetic paper-event families with CC0 Kenney Casino Audio samples bundled in CardSounds. Source/license and conversion details live beside the assets. Use mono PCM WAV for offline playback, trim leading silence, fade edges, and normalize peaks; per-event gain remains in design tokens. The existing cached AVAudioPlayer lifecycle, event triggers, variant cycle, ambient session, preferences, haptics, and result chimes remain unchanged. Audio assets never enter saved match state.

Tests must decode all nine bundled samples, verify distinct variants, bounded duration, non-silence, unclipped peaks and faded edges, confirm sample playback data takes precedence over synthesis, and verify fallback/result-chime behavior. These checks do not establish subjective realism: the updated sounds require a listening check on the iPhone.

Verification: all 171 unit tests passed on iPhone 17 Pro (iOS 26.2 simulator), including both new recording/fallback tests. No failures or skips. UI tests were not rerun for this audio-only revision.

## Quicker Feedback Revision (September 16, 2026)

Physical-device feedback requests slightly quicker movement and card sounds. Shorten live card flights to 0.40 seconds, landing pauses to 0.10 seconds, winner recognition to 0.85 seconds, and collection to 0.44 seconds. Deal packets take 0.30 seconds with 0.14-second station expansion and a 0.05-second lead-in; the staggered hand reveal takes 1.23 seconds. Play card audio at 1.2x with unchanged volume, recordings, event triggers, and variants. Result-chime playback, opponent thinking time, haptics, and Reduce Motion remain unchanged.

Verify actual AVAudioPlayer rate/volume configuration for every event and variant, effective sound duration, readable winner hold, unchanged reduced-motion timing, and reveal timing consistency. Run live/dealing UI regressions as well as the unit suite; perceived pacing still needs an on-device check.

Verification: 173 unit tests and all 14 current live-table/opening-table UI tests passed on iPhone 17 Pro (iOS 26.2 simulator), with no failures or skips. Signed device build succeeded and was installed on the iPhone 15 Pro. Remote launch was blocked because the phone was locked; subjective pacing remains for the user to check.
