import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

// Us on the top half (UP button), them on the bottom half (DOWN button), the clock above the sets.
class ScoreView extends WatchUi.View {
    private var _match as MatchScore.Match;
    private var _timer as Timer.Timer?;

    function initialize(match as MatchScore.Match) {
        View.initialize();
        _match = match;
    }

    function onShow() as Void {
        _timer = new Timer.Timer();
        scheduleTick();
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    // Redraw at the start of each minute, so the clock changes on time
    function onTick() as Void {
        WatchUi.requestUpdate();
        scheduleTick();
    }

    private function scheduleTick() as Void {
        if (_timer != null) {
            _timer.start(method(:onTick), (60 - System.getClockTime().sec) * 1000, false);
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var config = _match.getConfig();
        var state = _match.getState();
        var w = dc.getWidth();
        var h = dc.getHeight();
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawTeam(dc, 0, "MY", h * 0.33);
        drawTeam(dc, 1, "ONI", h * 0.67);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(w * 0.1, h / 2, w * 0.9, h / 2);

        var clock = System.getClockTime();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.10, Graphics.FONT_XTINY,
            ScoreText.clockText(clock.hour, clock.min, System.getDeviceSettings().is24Hour), center);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.19, Graphics.FONT_XTINY, ScoreText.setsText(state), center);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.88, Graphics.FONT_XTINY, ScoreText.statusText(config, state), center);
    }

    private function drawTeam(dc as Graphics.Dc, team as Number, label as String, y as Float) as Void {
        var config = _match.getConfig();
        var state = _match.getState();
        var w = dc.getWidth();
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var points = MatchScore.pointLabel(config, state, team);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w * 0.2, y, Graphics.FONT_SMALL, label, center);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (config.format == MatchScore.FORMAT_AMERICANO) {
            dc.drawText(w * 0.6, y, Graphics.FONT_NUMBER_MEDIUM, points, center);
            return;
        }
        dc.drawText(w * 0.45, y, Graphics.FONT_MEDIUM, state.games[team].toString(), center);
        // FONT_LARGE, not a number font: the label can be "AD"
        dc.drawText(w * 0.72, y, Graphics.FONT_LARGE, points, center);
    }
}

module ScoreText {

    // "14:05", or "2:05" on a 12-hour watch
    function clockText(hour as Number, min as Number, is24Hour as Boolean) as String {
        if (!is24Hour) {
            hour = hour % 12 == 0 ? 12 : hour % 12;
        }
        return hour + ":" + min.format("%02d");
    }

    // Match time: "47:05", or "1:12:30" from an hour on
    function durationText(seconds as Number) as String {
        var text = (seconds % 60).format("%02d");
        if (seconds < 3600) {
            return seconds / 60 + ":" + text;
        }
        return seconds / 3600 + ":" + (seconds / 60 % 60).format("%02d") + ":" + text;
    }

    // Finished sets, e.g. "6-4  3-6"
    function setsText(state as MatchScore.MatchState) as String {
        var text = "";
        for (var i = 0; i < state.setScores.size(); i++) {
            var set = state.setScores[i];
            text += (i > 0 ? "  " : "") + set[0] + "-" + set[1];
        }
        return text;
    }

    // Session summary for FIT, e.g. "6-4 3-6 2-1" (unfinished set included) or "21-15" in Americano
    function finalScore(config as MatchScore.MatchConfig, state as MatchScore.MatchState) as String {
        if (config.format == MatchScore.FORMAT_AMERICANO) {
            return state.points[0] + "-" + state.points[1];
        }
        var text = "";
        for (var i = 0; i < state.setScores.size(); i++) {
            var set = state.setScores[i];
            text += (i > 0 ? " " : "") + set[0] + "-" + set[1];
        }
        if (state.winner == MatchScore.NO_WINNER && (state.games[0] > 0 || state.games[1] > 0)) {
            text += (text.length() > 0 ? " " : "") + state.games[0] + "-" + state.games[1];
        }
        return text;
    }

    function statusText(config as MatchScore.MatchConfig, state as MatchScore.MatchState) as String {
        if (state.winner == MatchScore.DRAW) {
            return "REMIS";
        }
        if (state.winner != MatchScore.NO_WINNER) {
            return "WYGRANA: " + (state.winner == 0 ? "MY" : "ONI");
        }
        if (state.inTiebreak) {
            return "TIE-BREAK DO " + state.tiebreakTo;
        }
        if (MatchScore.isDecidingPoint(config, state)) {
            return config.gameMode == MatchScore.GAME_GOLDEN_POINT ? "GOLDEN POINT" : "STAR POINT";
        }
        return "";
    }
}
