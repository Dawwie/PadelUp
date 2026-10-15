import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

// One finished match (an entry of MatchHistory): date, score, match time and points.
class SummaryView extends WatchUi.View {
    private var _entry as Dictionary;

    function initialize(entry as Dictionary) {
        View.initialize();
        _entry = entry;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var center = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        var points = _entry["points"] as Array<Number>;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.17, Graphics.FONT_XTINY, SummaryText.date(_entry["date"] as Number), center);

        // One column per set: its number above the score
        var format = SummaryText.format(_entry);
        var sets = MatchHistory.sets(_entry["score"] as String);
        for (var i = 0; i < sets.size(); i++) {
            var x = w * (i + 1) / (sets.size() + 1);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, h * 0.30, Graphics.FONT_XTINY, MatchHistory.setHeading(format, i), center);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, h * 0.41, Graphics.FONT_MEDIUM, sets[i], center);
        }

        dc.drawText(w / 2, h * 0.63, Graphics.FONT_SMALL,
            WatchUi.loadResource(Rez.Strings.SummaryTime) + " " + ScoreText.durationText(_entry["duration"] as Number), center);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h * 0.77, Graphics.FONT_SMALL,
            WatchUi.loadResource(Rez.Strings.SummaryPoints) + " " + points[0] + " : " + points[1], center);
    }
}

// Any button: after Zapisz it closes the app, from the history it goes back to the list.
class SummaryDelegate extends WatchUi.InputDelegate {
    private var _exit as Boolean;

    function initialize(exit as Boolean) {
        InputDelegate.initialize();
        _exit = exit;
    }

    function onKey(event as WatchUi.KeyEvent) as Boolean {
        if (_exit) {
            System.exit();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

module SummaryText {
    // "15.10 14:05"
    function date(seconds as Number) as String {
        var info = Time.Gregorian.info(new Time.Moment(seconds), Time.FORMAT_SHORT);
        return info.day + "." + (info.month as Number).format("%02d") + " "
            + ScoreText.clockText(info.hour, info.min);
    }

    // Entries stored before the format was saved count as classic
    function format(entry as Dictionary) as Number {
        var format = entry["format"] as Number?;
        return format != null ? format : MatchScore.FORMAT_CLASSIC as Number;
    }
}

// Pause menu > Historia: finished matches, newest first; select opens the summary.
module HistoryMenu {
    function open() as Void {
        var list = Application.Storage.getValue(MATCHES_KEY) as Array<Dictionary>?;
        var menu = new WatchUi.Menu2({:title => WatchUi.loadResource(Rez.Strings.MenuHistory) as String});
        if (list == null || list.size() == 0) {
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.HistoryEmpty) as String, null, null, null));
            list = [] as Array<Dictionary>;
        }
        for (var i = 0; i < list.size(); i++) {
            var entry = list[i];
            menu.addItem(new WatchUi.MenuItem(MatchHistory.label(SummaryText.format(entry), entry["score"] as String),
                SummaryText.date(entry["date"] as Number) + "  " + ScoreText.durationText(entry["duration"] as Number), i, null));
        }
        WatchUi.pushView(menu, new HistoryMenuDelegate(list), WatchUi.SLIDE_LEFT);
    }
}

class HistoryMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var _list as Array<Dictionary>;

    function initialize(list as Array<Dictionary>) {
        Menu2InputDelegate.initialize();
        _list = list;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id instanceof Number) {
            WatchUi.pushView(new SummaryView(_list[id]), new SummaryDelegate(false), WatchUi.SLIDE_LEFT);
        }
    }
}
