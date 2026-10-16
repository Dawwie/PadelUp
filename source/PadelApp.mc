import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// The app opens on the start screen (StartMenu.mc); recording starts with Start, with the match settings stored last time (Settings.mc).
// An unfinished match (app crashed or was killed) is restored from storage straight to the score screen; the recording starts anew.
const HISTORY_KEY = "history";
const CONFIG_KEY = "config";
// Finished matches, see MatchHistory.mc
const MATCHES_KEY = "matches";

class PadelApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var history = Application.Storage.getValue(HISTORY_KEY) as Array<Number>?;
        var match = new MatchScore.Match(MatchScore.configFromDictionary(Application.Storage.getValue(CONFIG_KEY) as Dictionary<String, Number>?), history);
        if (history == null || history.size() == 0) {
            return [new StartMenu(match), new StartMenuDelegate(match)];
        }
        var recorder = new Recorder(match);
        return [new ScoreView(match), new ScoreDelegate(match, recorder)];
    }
}
