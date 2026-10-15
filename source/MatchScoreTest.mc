import Toybox.Lang;
import Toybox.Test;

// Helpers are (:debug): every (:test) function is run as a test, and :debug code is left out of release builds.
// Run: build with --unit-test, then `monkeydo bin/<app>.prg <device> -t`

(:debug)
function newMatch(mode as MatchScore.GameMode) as MatchScore.Match {
    var config = new MatchScore.MatchConfig();
    config.gameMode = mode;
    return new MatchScore.Match(config, null);
}

(:debug)
function points(match as MatchScore.Match, team as Number, count as Number) as Void {
    for (var i = 0; i < count; i++) {
        match.addPoint(team);
    }
}

(:debug)
function toDeuce(match as MatchScore.Match) as Void {
    points(match, 0, 3);
    points(match, 1, 3);
}

// Alternating games until the score is n:n
(:debug)
function gamesEach(match as MatchScore.Match, n as Number) as Void {
    for (var i = 0; i < n; i++) {
        points(match, 0, 4);
        points(match, 1, 4);
    }
}

(:debug)
function expectPair(actual as Array<Number>, us as Number, them as Number, what as String) as Void {
    Test.assertEqualMessage(actual[0], us, what + " (us)");
    Test.assertEqualMessage(actual[1], them, what + " (them)");
}

(:test)
function advantageNeedsTwoPointLead(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    toDeuce(m);
    m.addPoint(0);
    Test.assertEqual(MatchScore.pointLabel(m.getConfig(), m.getState(), 0), "AD");
    Test.assertEqual(MatchScore.pointLabel(m.getConfig(), m.getState(), 1), "40");
    expectPair(m.getState().games, 0, 0, "games after advantage");

    m.addPoint(1);
    Test.assertEqual(MatchScore.pointLabel(m.getConfig(), m.getState(), 0), "40");
    m.addPoint(1);
    m.addPoint(1);
    expectPair(m.getState().games, 0, 1, "games");
    return true;
}

(:test)
function goldenPointDecidesAtDeuce(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    toDeuce(m);
    Test.assert(MatchScore.isDecidingPoint(m.getConfig(), m.getState()));
    m.addPoint(1);
    expectPair(m.getState().games, 0, 1, "games");
    return true;
}

(:test)
function starPointDecidesAtThirdDeuce(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_STAR_POINT);
    toDeuce(m);              // deuce 1
    m.addPoint(0);
    m.addPoint(1);           // deuce 2
    m.addPoint(0);
    m.addPoint(1);           // deuce 3
    expectPair(m.getState().games, 0, 0, "games before star point");
    Test.assert(MatchScore.isDecidingPoint(m.getConfig(), m.getState()));
    m.addPoint(1);
    expectPair(m.getState().games, 0, 1, "games");
    return true;
}

(:test)
function starPointAdvantageCanWinBeforeThirdDeuce(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_STAR_POINT);
    toDeuce(m);
    m.addPoint(0);
    m.addPoint(1);           // deuce 2
    m.addPoint(0);
    m.addPoint(0);
    expectPair(m.getState().games, 1, 0, "games");
    return true;
}

(:test)
function setGoesTo7_5(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    gamesEach(m, 5);
    points(m, 0, 4);
    expectPair(m.getState().sets, 0, 0, "sets at 6:5");
    points(m, 0, 4);
    expectPair(m.getState().sets, 1, 0, "sets");
    expectPair(m.getState().setScores[0], 7, 5, "set 1");
    return true;
}

(:test)
function tiebreakAt6_6NeedsTwoPointLead(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    gamesEach(m, 6);
    Test.assert(m.getState().inTiebreak);
    points(m, 0, 6);
    points(m, 1, 6);
    m.addPoint(0);
    Test.assertEqual(MatchScore.pointLabel(m.getConfig(), m.getState(), 0), "7");
    expectPair(m.getState().sets, 0, 0, "sets at 7:6 in tie-break");
    m.addPoint(0);
    expectPair(m.getState().sets, 1, 0, "sets");
    expectPair(m.getState().setScores[0], 7, 6, "set 1");
    Test.assert(!m.getState().inTiebreak);
    return true;
}

(:test)
function miniSetTiebreakAt4_4(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    m.getConfig().gamesPerSet = 4;
    gamesEach(m, 4);
    Test.assert(m.getState().inTiebreak);
    return true;
}

(:test)
function superTiebreakReplacesDecidingSet(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    m.getConfig().deciderTiebreakTo = 10;
    points(m, 0, 24);        // 6-0
    points(m, 1, 24);        // 0-6
    Test.assert(m.getState().inTiebreak);
    Test.assertEqual(m.getState().tiebreakTo, 10);
    points(m, 0, 9);
    points(m, 1, 8);
    Test.assertEqual(m.getState().winner, MatchScore.NO_WINNER);
    m.addPoint(0);
    Test.assertEqual(m.getState().winner, 0);
    expectPair(m.getState().setScores[2], 10, 8, "super tie-break");
    return true;
}

(:test)
function matchEndsAtTwoSetsAndIgnoresFurtherPoints(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    points(m, 1, 48);        // 0-6 0-6
    Test.assertEqual(m.getState().winner, 1);
    m.addPoint(0);
    Test.assertEqual(m.getHistory().size(), 48);
    expectPair(m.getState().points, 0, 0, "points after match end");
    return true;
}

(:test)
function undoCrossesGameBoundary(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    points(m, 0, 4);
    expectPair(m.getState().games, 1, 0, "games");
    Test.assert(m.undo());
    expectPair(m.getState().games, 0, 0, "games after undo");
    expectPair(m.getState().points, 3, 0, "points after undo");
    return true;
}

(:test)
function undoReopensFinishedMatch(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    points(m, 1, 48);
    m.undo();
    Test.assertEqual(m.getState().winner, MatchScore.NO_WINNER);
    expectPair(m.getState().sets, 0, 1, "sets after undo");
    expectPair(m.getState().games, 0, 5, "games after undo");
    return true;
}

(:test)
function undoOnEmptyMatchDoesNothing(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    Test.assert(!m.undo());
    return true;
}

(:test)
function restoredHistoryGivesSameScore(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    points(m, 0, 5);
    points(m, 1, 2);
    var restored = new MatchScore.Match(m.getConfig(), m.getHistory());
    expectPair(restored.getState().games, 1, 0, "games");
    expectPair(restored.getState().points, 1, 2, "points");
    return true;
}

(:test)
function americanoEndsAtTotalPoints(logger as Logger) as Boolean {
    var config = new MatchScore.MatchConfig();
    config.format = MatchScore.FORMAT_AMERICANO;
    var m = new MatchScore.Match(config, null);
    points(m, 0, 12);
    points(m, 1, 8);
    Test.assertEqual(m.getState().winner, MatchScore.NO_WINNER);
    Test.assertEqual(MatchScore.pointLabel(config, m.getState(), 0), "12");
    m.addPoint(1);
    Test.assertEqual(m.getState().winner, 0);
    expectPair(m.getState().points, 12, 9, "points");
    m.addPoint(1);
    expectPair(m.getState().points, 12, 9, "points after match end");
    expectPair(m.getState().games, 0, 0, "americano has no games");
    return true;
}

(:test)
function americanoEvenTotalCanDraw(logger as Logger) as Boolean {
    var config = new MatchScore.MatchConfig();
    config.format = MatchScore.FORMAT_AMERICANO;
    config.americanoTotal = 24;
    var m = new MatchScore.Match(config, null);
    points(m, 0, 12);
    points(m, 1, 12);
    Test.assertEqual(m.getState().winner, MatchScore.DRAW);
    return true;
}

(:test)
function setsTextListsFinishedSets(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    Test.assertEqual(ScoreText.setsText(m.getState()), "");
    points(m, 0, 24);
    gamesEach(m, 3);
    points(m, 1, 12);
    Test.assertEqual(ScoreText.setsText(m.getState()), "6-0  3-6");
    return true;
}

(:test)
function clockTextFollows12And24HourSetting(logger as Logger) as Boolean {
    Test.assertEqual(ScoreText.clockText(14, 5, true), "14:05");
    Test.assertEqual(ScoreText.clockText(0, 30, true), "0:30");
    Test.assertEqual(ScoreText.clockText(14, 5, false), "2:05");
    Test.assertEqual(ScoreText.clockText(0, 30, false), "12:30");
    Test.assertEqual(ScoreText.clockText(12, 0, false), "12:00");
    return true;
}

(:test)
function statusTextShowsDecidingPointTiebreakAndWinner(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_STAR_POINT);
    toDeuce(m);
    m.addPoint(0);
    m.addPoint(1);
    m.addPoint(0);
    m.addPoint(1);
    Test.assertEqual(ScoreText.statusText(m.getConfig(), m.getState()), "STAR POINT");

    m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    m.getConfig().deciderTiebreakTo = 10;
    points(m, 0, 24);
    points(m, 1, 24);
    Test.assertEqual(ScoreText.statusText(m.getConfig(), m.getState()), "TIE-BREAK DO 10");
    points(m, 1, 10);
    Test.assertEqual(ScoreText.statusText(m.getConfig(), m.getState()), "WYGRANA: ONI");
    return true;
}

(:test)
function pointsWonCountsRalliesPerTeam(logger as Logger) as Boolean {
    Test.assertEqual(MatchScore.pointsWon([0, 1, 1, 0, 1] as Array<Number>).toString(), "[2, 3]");
    return true;
}

(:test)
function finalScoreIncludesUnfinishedSet(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    Test.assertEqual(ScoreText.finalScore(m.getConfig(), m.getState()), "");
    points(m, 0, 24);
    points(m, 1, 8);
    Test.assertEqual(ScoreText.finalScore(m.getConfig(), m.getState()), "6-0 0-2");
    points(m, 1, 16);
    Test.assertEqual(ScoreText.finalScore(m.getConfig(), m.getState()), "6-0 0-6");
    return true;
}

(:test)
function finalScoreInAmericanoIsTheTotal(logger as Logger) as Boolean {
    var config = new MatchScore.MatchConfig();
    config.format = MatchScore.FORMAT_AMERICANO;
    var m = new MatchScore.Match(config, null);
    points(m, 0, 5);
    points(m, 1, 3);
    Test.assertEqual(ScoreText.finalScore(config, m.getState()), "5-3");
    return true;
}

(:test)
function configSurvivesDictionaryRoundTrip(logger as Logger) as Boolean {
    var config = new MatchScore.MatchConfig();
    config.format = MatchScore.FORMAT_AMERICANO;
    config.gameMode = MatchScore.GAME_STAR_POINT;
    config.gamesPerSet = 4;
    config.deciderTiebreakTo = 10;
    config.americanoTotal = 32;
    var copy = MatchScore.configFromDictionary(config.toDictionary());
    Test.assertEqual(copy.format, MatchScore.FORMAT_AMERICANO);
    Test.assertEqual(copy.gameMode, MatchScore.GAME_STAR_POINT);
    Test.assertEqual(copy.gamesPerSet, 4);
    Test.assertEqual(copy.deciderTiebreakTo, 10);
    Test.assertEqual(copy.americanoTotal, 32);
    Test.assertEqual(MatchScore.configFromDictionary(null).gamesPerSet, 6);
    return true;
}

(:test)
function configChangeReplaysHistory(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_ADVANTAGE);
    toDeuce(m);
    m.addPoint(0);
    Test.assertEqual(m.getState().games[0], 0);
    m.getConfig().gameMode = MatchScore.GAME_GOLDEN_POINT;
    m.configChanged();
    Test.assertEqual(m.getState().games[0], 1);
    return true;
}

(:test)
function nextValueCyclesAndFallsBackToFirst(logger as Logger) as Boolean {
    Test.assertEqual(Settings.nextValue([6, 4] as Array<Number>, 6), 4);
    Test.assertEqual(Settings.nextValue([6, 4] as Array<Number>, 4), 6);
    Test.assertEqual(Settings.nextValue([16, 21, 24] as Array<Number>, 99), 16);
    return true;
}

(:test)
function deciderDefaultsToTiebreakTo7(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_GOLDEN_POINT);
    points(m, 0, 24);
    points(m, 1, 24);
    Test.assertEqual(m.getState().inTiebreak, true);
    Test.assertEqual(m.getState().tiebreakTo, 7);
    return true;
}

(:test)
function resetStartsANewMatchWithTheSameConfig(logger as Logger) as Boolean {
    var m = newMatch(MatchScore.GAME_STAR_POINT);
    points(m, 0, 30);
    m.reset();
    Test.assertEqual(m.getHistory().size(), 0);
    Test.assertEqual(m.getState().sets[0], 0);
    Test.assertEqual(m.getState().games[0], 0);
    Test.assertEqual(m.getConfig().gameMode, MatchScore.GAME_STAR_POINT);
    return true;
}
