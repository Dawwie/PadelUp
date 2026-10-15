import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// UP = point for us, DOWN = point for them, BACK = undo, START = pause menu, long UP = settings.
// BACK with nothing to undo also opens the pause menu, so the app never exits without asking.
// The point history is stored after every change and cleared when the activity is saved or discarded.
class ScoreDelegate extends WatchUi.BehaviorDelegate {
    private var _match as MatchScore.Match;
    private var _recorder as Recorder;

    function initialize(match as MatchScore.Match, recorder as Recorder) {
        BehaviorDelegate.initialize();
        _match = match;
        _recorder = recorder;
    }

    function onPreviousPage() as Boolean {
        addPoint(0);
        return true;
    }

    function onNextPage() as Boolean {
        addPoint(1);
        return true;
    }

    function onBack() as Boolean {
        if (_match.undo()) {
            changed();
        } else {
            openPauseMenu();
        }
        return true;
    }

    function onMenu() as Boolean {
        Settings.open(_match, _recorder);
        return true;
    }

    function onSelect() as Boolean {
        openPauseMenu();
        return true;
    }

    // Short buzz per point, a long one when the point ends a set or the match
    private function addPoint(team as Number) as Void {
        var state = _match.getState();
        if (state.winner != MatchScore.NO_WINNER) {
            return;
        }
        var setsBefore = state.setScores.size();
        _match.addPoint(team);
        state = _match.getState();
        var long = state.setScores.size() > setsBefore || state.winner != MatchScore.NO_WINNER;
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(100, long ? 600 : 80)]);
        }
        changed();
    }

    private function changed() as Void {
        Application.Storage.setValue(HISTORY_KEY, _match.getHistory());
        _recorder.update(_match);
        WatchUi.requestUpdate();
    }

    private function openPauseMenu() as Void {
        _recorder.pause();
        var menu = new WatchUi.Menu2({:title => WatchUi.loadResource(Rez.Strings.MenuTitle) as String});
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.MenuResume) as String, null, :resume, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.MenuNewMatch) as String, null, :newMatch, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.MenuSave) as String, null, :save, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.MenuDiscard) as String, null, :discard, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.MenuHistory) as String, null, :history, null));
        WatchUi.pushView(menu, new PauseMenuDelegate(_match, _recorder), WatchUi.SLIDE_UP);
    }
}

// BACK in the menu = resume, like the native activity pause menu.
class PauseMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _match as MatchScore.Match;
    private var _recorder as Recorder;

    function initialize(match as MatchScore.Match, recorder as Recorder) {
        Menu2InputDelegate.initialize();
        _match = match;
        _recorder = recorder;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :resume) {
            onBack();
        } else if (id == :newMatch) {
            var confirm = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.ConfirmNewMatch) as String);
            WatchUi.pushView(confirm, new NewMatchConfirmDelegate(_match, _recorder), WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :save) {
            var entry = storeMatch(_match, _recorder);
            _recorder.save();
            Application.Storage.deleteValue(HISTORY_KEY);
            if (entry == null) {
                System.exit();
            }
            WatchUi.switchToView(new SummaryView(entry), new SummaryDelegate(true), WatchUi.SLIDE_UP);
        } else if (id == :discard) {
            var confirm = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.ConfirmDiscard) as String);
            WatchUi.pushView(confirm, new DiscardConfirmDelegate(_recorder), WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :history) {
            HistoryMenu.open();
        }
    }

    function onBack() as Void {
        _recorder.resume();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DiscardConfirmDelegate extends WatchUi.ConfirmationDelegate {
    private var _recorder as Recorder;

    function initialize(recorder as Recorder) {
        ConfirmationDelegate.initialize();
        _recorder = recorder;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _recorder.discard();
            Application.Storage.deleteValue(HISTORY_KEY);
            System.exit();
        }
        return true;
    }
}

// Same session, score back to zero; the finished match stays in the laps and the session summary.
class NewMatchConfirmDelegate extends WatchUi.ConfirmationDelegate {
    private var _match as MatchScore.Match;
    private var _recorder as Recorder;

    function initialize(match as MatchScore.Match, recorder as Recorder) {
        ConfirmationDelegate.initialize();
        _match = match;
        _recorder = recorder;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            storeMatch(_match, _recorder);
            _recorder.newMatch(_match);
            _match.reset();
            Application.Storage.setValue(HISTORY_KEY, _match.getHistory());
            _recorder.update(_match);
            _recorder.resume();
            // The confirmation closes itself; this closes the pause menu under it
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        return true;
    }
}

// Adds the match to the finished matches in storage. Call before recorder.newMatch(), which restarts the match time.
// Returns the new entry, or null for a match without points (not stored).
function storeMatch(match as MatchScore.Match, recorder as Recorder) as Dictionary? {
    var list = Application.Storage.getValue(MATCHES_KEY) as Array<Dictionary>?;
    list = MatchHistory.add(list, match, Time.now().value(), recorder.matchDuration());
    Application.Storage.setValue(MATCHES_KEY, list);
    return match.getHistory().size() > 0 ? list[0] : null;
}
