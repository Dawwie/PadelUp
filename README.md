# PadelUp

A Garmin Connect IQ watch app that keeps the score of a padel match with the watch buttons and records the match as a padel activity with heart rate.

The app's interface is in Polish. A full user guide (in Polish) is online at [dawwie.github.io/PadelUp](https://dawwie.github.io/PadelUp/) (source: [`docs/instrukcja.html`](docs/instrukcja.html)).

## Features

- **Classic FIP scoring**: advantage, star point or golden point; sets to 6 or 4 games with a tie-break; deciding set as a full set or a tie-break to 7 or 10.
- **Americano / Mexicano**: points to a total of 16, 21, 24 or 32.
- **Unlimited undo**: every point is stored, and undo replays the match.
- **Score screen**: clock, set scores, games and points.
- **Several matches per session** (for Americano tournaments) with **New match**. Each match gets its own lap.
- **Match summary and history**: set scores, date and match time of the last 20 matches.
- **Vibration**: short for every point, long when a set or the match ends.
- **FIT data**: recorded as a padel activity (`SPORT_RACKET` / `SUB_SPORT_PADEL`) with developer fields:
  - point difference over time (chart)
  - games and points per lap
  - sets and points per session
  - the final score as text, e.g. `6-4 3-6 7-6`
- **Crash recovery**: the current match is restored after a crash.

## Controls

| Button | Action |
|---|---|
| UP | Point for us |
| DOWN | Point for them |
| BACK | Undo the last point (opens the pause menu when there is nothing to undo) |
| START | Pause menu: resume, new match, save, discard, history |
| Hold UP | Settings |

## Supported devices

- epix Pro (Gen 2) 47mm
- fēnix 9 Pro 51mm

The app needs Connect IQ API 4.1.6 or newer. Adding another device means adding it to `manifest.xml` and checking the layout on its screen.

## Building

You need the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (built with 9.2.0) and a developer key. To make a key, see [Getting Started](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/). The build commands below use `developer_key.der`. Never commit your key.

```sh
# app in the simulator (start the simulator first: connectiq &)
monkeyc -f monkey.jungle -d epix2pro47mm -y developer_key.der -o bin/padel.prg
monkeydo bin/padel.prg epix2pro47mm

# unit tests
monkeyc -f monkey.jungle -d epix2pro47mm -y developer_key.der -o bin/padel-test.prg --unit-test
monkeydo bin/padel-test.prg epix2pro47mm -t

# release build
monkeyc -f monkey.jungle -d epix2pro47mm -y developer_key.der -o bin/PadelUp.prg -r
```

To install a release build, copy the `.prg` file to `GARMIN/APPS` on the watch over USB. On macOS this needs an MTP tool such as Android File Transfer.

Garmin Connect shows developer fields only for apps installed from the Connect IQ Store. For a sideloaded build, open the FIT file in Monkey Graph (part of the SDK) to see them.

## Project layout

| Path | Contents |
|---|---|
| `source/MatchScore.mc` | Scoring logic (no UI), replayed from the list of points |
| `source/ScoreView.mc`, `ScoreDelegate.mc` | Score screen, buttons and the pause menu |
| `source/MatchHistory.mc`, `SummaryView.mc` | Match history and summary |
| `source/Settings.mc` | Settings menu |
| `source/Recorder.mc` | Activity recording and FIT fields |
| `source/MatchScoreTest.mc` | Unit tests |
| `resources/fit/fit_contributions.xml` | FIT developer field definitions |

## License

[MIT](LICENSE)
