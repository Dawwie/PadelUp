import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Match settings (long UP). Selecting an item switches it to the next value; the sublabel shows the current one.
// Changes apply to the match in progress and are kept in storage for the next matches.
module Settings {

    const FORMATS = [MatchScore.FORMAT_CLASSIC, MatchScore.FORMAT_AMERICANO] as Array<Number>;
    const GAME_MODES = [MatchScore.GAME_ADVANTAGE, MatchScore.GAME_STAR_POINT, MatchScore.GAME_GOLDEN_POINT] as Array<Number>;
    const GAMES_PER_SET = [6, 4] as Array<Number>;
    const DECIDER_TIEBREAK = [7, 10, 0] as Array<Number>;
    const AMERICANO_TOTALS = [16, 21, 24, 32] as Array<Number>;

    // The value after current, or the first one when current is not in the list
    function nextValue(values as Array<Number>, current as Number) as Number {
        return values[(values.indexOf(current) + 1) % values.size()];
    }

    function open(match as MatchScore.Match, recorder as Recorder) as Void {
        var config = match.getConfig();
        var menu = new WatchUi.Menu2({:title => text(Rez.Strings.SettingsTitle)});
        var ids = [:format, :gameMode, :gamesPerSet, :decider, :americanoTotal];
        var titles = [Rez.Strings.SettingFormat, Rez.Strings.SettingGameMode, Rez.Strings.SettingGamesPerSet,
            Rez.Strings.SettingDecider, Rez.Strings.SettingAmericanoTotal];
        for (var i = 0; i < ids.size(); i++) {
            menu.addItem(new WatchUi.MenuItem(text(titles[i]), valueLabel(config, ids[i]), ids[i], null));
        }
        WatchUi.pushView(menu, new SettingsDelegate(match, recorder), WatchUi.SLIDE_UP);
    }

    function valueLabel(config as MatchScore.MatchConfig, id as Symbol) as String {
        if (id == :format) {
            return text(config.format == MatchScore.FORMAT_CLASSIC ? Rez.Strings.FormatClassic : Rez.Strings.FormatAmericano);
        }
        if (id == :gameMode) {
            var labels = [Rez.Strings.GameAdvantage, Rez.Strings.GameStarPoint, Rez.Strings.GameGoldenPoint];
            return text(labels[GAME_MODES.indexOf(config.gameMode)]);
        }
        if (id == :gamesPerSet) {
            return text(config.gamesPerSet == 6 ? Rez.Strings.Set6Games : Rez.Strings.Set4Games);
        }
        if (id == :decider) {
            return config.deciderTiebreakTo == 0 ? text(Rez.Strings.DeciderFullSet) : text(Rez.Strings.DeciderTiebreak) + " " + config.deciderTiebreakTo;
        }
        return config.americanoTotal.toString();
    }

    function text(id as ResourceId) as String {
        return WatchUi.loadResource(id) as String;
    }
}

class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    private var _match as MatchScore.Match;
    private var _recorder as Recorder;

    function initialize(match as MatchScore.Match, recorder as Recorder) {
        Menu2InputDelegate.initialize();
        _match = match;
        _recorder = recorder;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var config = _match.getConfig();
        var id = item.getId() as Symbol;
        if (id == :format) {
            config.format = Settings.nextValue(Settings.FORMATS, config.format) as MatchScore.Format;
        } else if (id == :gameMode) {
            config.gameMode = Settings.nextValue(Settings.GAME_MODES, config.gameMode) as MatchScore.GameMode;
        } else if (id == :gamesPerSet) {
            config.gamesPerSet = Settings.nextValue(Settings.GAMES_PER_SET, config.gamesPerSet);
        } else if (id == :decider) {
            config.deciderTiebreakTo = Settings.nextValue(Settings.DECIDER_TIEBREAK, config.deciderTiebreakTo);
        } else if (id == :americanoTotal) {
            config.americanoTotal = Settings.nextValue(Settings.AMERICANO_TOTALS, config.americanoTotal);
        }
        item.setSubLabel(Settings.valueLabel(config, id));
        _match.configChanged();
        Application.Storage.setValue(CONFIG_KEY, config.toDictionary());
        _recorder.update(_match);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }
}
