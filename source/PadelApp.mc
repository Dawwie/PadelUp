import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// The activity starts recording on launch, with the match settings stored last time (Settings.mc).
// An unfinished match (app crashed or was killed) is restored from storage; the recording starts anew.
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
        var recorder = new Recorder(match);
        return [new ScoreView(match, recorder), new ScoreDelegate(match, recorder)];
    }
}
