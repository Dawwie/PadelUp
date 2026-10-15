# PadelUp: Connect IQ watch app

Watch app (Monkey C) that records a padel activity and keeps the match score, entered with the watch buttons.
Background research and the original plan: `docs/research/garmin-padel-scoring.md`.
Communicate with the user in Polish.

## Build and test

Targets (`manifest.xml` products, build each with `-d <id>`):
- `epix2pro47mm`: epix Pro (Gen 2) 47mm, API 5.2, the user's watch
- `fenix9pro51mm`: fēnix 9 Pro 51mm, API 6.0, 466x466, a beta tester's watch

`minApiLevel` 4.1.6 (needed for `SPORT_RACKET` / `SUB_SPORT_PADEL`). SDK 9.2.0. `developer_key.der` is the signing key: never commit, share or regenerate it.

```sh
SDK="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.2.0-2026-06-09-92a1605b2"
# unit tests (simulator must be running: "$SDK/bin/connectiq" &)
"$SDK/bin/monkeyc" -f monkey.jungle -d epix2pro47mm -y developer_key.der -o bin/padel-test.prg --unit-test -l 2
"$SDK/bin/monkeydo" bin/padel-test.prg epix2pro47mm -t
# app in the simulator
"$SDK/bin/monkeyc" -f monkey.jungle -d epix2pro47mm -y developer_key.der -o bin/padel.prg -l 2
"$SDK/bin/monkeydo" bin/padel.prg epix2pro47mm
# release builds: copy over USB (MTP, e.g. Android File Transfer) to GARMIN/APPS
"$SDK/bin/monkeyc" -f monkey.jungle -d epix2pro47mm -y developer_key.der -o bin/PadelUp.prg -r
"$SDK/bin/monkeyc" -f monkey.jungle -d fenix9pro51mm -y developer_key.der -o bin/PadelUp-fenix9pro51mm.prg -r
```

A new device needs its definition downloaded in the SDK Manager (Devices) first. Only send `.prg` files to testers: `*.debug.xml` contains local paths.

The agent cannot screenshot or click the simulator; the user checks the UI by clicking the buttons on the watch bezel.

## Code

- `source/MatchScore.mc`: pure scoring logic. Classic FIP (advantage / star point / golden point, sets to 6 or 4 games, tie-break, deciding set as a full set or a tie-break to 7/10) and Americano/Mexicano to a point total. `Match(config, history)` keeps the list of points; undo, config changes and restore all replay that list.
- `source/MatchScoreTest.mc`: unit tests (`Toybox.Test`) for the scoring, `ScoreText` (incl. clock and match time format), match history, config storage and `Settings.nextValue`.
- `source/ScoreView.mc`: score screen (24-hour clock at the top, us on top, them on the bottom, heart rate and match time above the status line; redrawn every second) and `ScoreText` (clock, match time, sets, status line, `finalScore` for FIT).
- `source/ScoreDelegate.mc`: buttons, pause menu, confirmations, vibration; `storeMatch` adds the match to the history.
- `source/MatchHistory.mc`: pure history logic: `add` (newest first, last 20, no 0:0 matches), splitting the score into sets, list labels.
- `source/SummaryView.mc`: match summary screen and the Historia list.
- `source/Settings.mc`: settings menu; each select cycles the item to its next value.
- `source/Recorder.mc`: activity session (RACKET / PADEL, heart rate), FIT developer fields and the match time (`matchDuration`, timer time since the match started, without pauses). Field ids must match `resources/fit/fit_contributions.xml`.
- `source/PadelApp.mc`: restores config and history from storage, creates the match, recorder and view.

## Behavior

- UP = point for us, DOWN = point for them, BACK = undo, long UP = settings, START = pause menu.
- BACK with nothing to undo also opens the pause menu, so the app never exits without asking.
- Pause menu: Wznów / Nowy mecz / Zapisz / Odrzuć / Historia. The menu pauses the timer; BACK in it resumes. Nowy mecz and Odrzuć ask for confirmation.
- Zapisz shows the match summary (date, set scores numbered I / II / III or "PKT" in Americano, match time, points); any button closes the app. A match without points closes the app at once.
- Historia: the last 20 finished matches (set scores, date, match time); select opens the same summary, any button goes back to the list.
- Nowy mecz: score back to zero in the same session (for Americano tournaments), the finished match stays in the laps and the session summary.
- Recording starts when the app opens.
- Vibration: short per point, long when the point ends a set or the match.
- Settings: format (Klasyczny / Americano), game (Przewaga / Star point / Golden point), set (6 / 4 games), deciding set (full set by default / tie-break to 7 / tie-break to 10), Americano total (16 / 21 / 24 / 32, default 21). Sets to win is fixed at 2. Changes apply to the match in progress and are kept for the next matches.

## Storage and FIT

- `Application.Storage`: `history` (points of the current match, saved after every change, cleared on Zapisz / Odrzuć), `config` (settings dictionary, kept) and `matches` (finished matches, newest first, at most 20: `date`, `score`, `duration`, `points`, `format`; added on Nowy mecz and Zapisz, not on Odrzuć).
- Laps: one per set, plus one per match when Nowy mecz is used.
- RECORD: `point_diff` (chart). LAP: `games_us`, `games_them`, `lap_points_us`, `lap_points_them`. SESSION: `sets_*` and `points_*` summed over all matches of the session, `final_score` like "6-4 3-6 7-6" or "21-15 / 18-24" (cut to 63 chars).
- Garmin Connect shows developer fields only for store apps (Beta App); for sideloaded builds, check the FIT in Monkey Graph.

## Known limits

- Undo across a set boundary cannot remove the lap already added; a settings change mid-match can do the same.
- After a crash only the current match is restored, and recording starts anew (earlier matches of the session are lost). The match time then counts from the restore.
- A new default setting applies only on a watch without a stored `config`: the whole config is stored on any settings change.
- Touch is not handled explicitly; the system maps swipes to UP/DOWN (swipe direction on the watch not verified).
- Not yet tested on a real watch: button lock during the activity, vibration, the activity type in Garmin Connect, the per-second redraw (battery, dimmed screen).
