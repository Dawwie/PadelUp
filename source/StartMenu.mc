import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Start screen: Start / Historia / Ustawienia. Nothing is recorded until Start;
// BACK closes the app. The sublabels show the current format and the last match.
class StartMenu extends WatchUi.Menu2 {
    private var _match as MatchScore.Match;

    function initialize(match as MatchScore.Match) {
        Menu2.initialize({:title => WatchUi.loadResource(Rez.Strings.AppName) as String});
        _match = match;
        addItem(new WatchUi.MenuItem(Settings.text(Rez.Strings.MenuStart), null, :start, null));
        addItem(new WatchUi.MenuItem(Settings.text(Rez.Strings.MenuHistory), null, :history, null));
        addItem(new WatchUi.MenuItem(Settings.text(Rez.Strings.SettingsTitle), null, :settings, null));
    }

    // Also after coming back from the settings
    function onShow() as Void {
        Menu2.onShow();
        (getItem(0) as WatchUi.MenuItem).setSubLabel(Settings.summary(_match.getConfig()));
        var list = Application.Storage.getValue(MATCHES_KEY) as Array<Dictionary>?;
        var last = Settings.text(Rez.Strings.HistoryEmpty);
        if (list != null && list.size() > 0) {
            last = Settings.text(Rez.Strings.StartLastMatch) + " "
                + MatchHistory.label(SummaryText.format(list[0]), list[0]["score"] as String);
        }
        (getItem(1) as WatchUi.MenuItem).setSubLabel(last);
    }
}

class StartMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _match as MatchScore.Match;

    function initialize(match as MatchScore.Match) {
        Menu2InputDelegate.initialize();
        _match = match;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :start) {
            var recorder = new Recorder(_match);
            WatchUi.switchToView(new ScoreView(_match), new ScoreDelegate(_match, recorder), WatchUi.SLIDE_UP);
        } else if (id == :history) {
            HistoryMenu.open();
        } else if (id == :settings) {
            Settings.open(_match, null);
        }
    }
}
