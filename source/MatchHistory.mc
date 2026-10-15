import Toybox.Lang;

// Finished matches kept on the watch, newest first. Entries are plain dictionaries,
// so the list goes to Application.Storage as it is.
module MatchHistory {

    const MAX_MATCHES = 20;
    const ROMAN = ["I", "II", "III", "IV", "V"] as Array<String>;

    // date: epoch seconds, duration: match time in seconds
    // Returns the list with the match first, cut to the newest MAX_MATCHES. A match without points is not added.
    function add(list as Array<Dictionary>?, match as MatchScore.Match, date as Number, duration as Number) as Array<Dictionary> {
        if (list == null) {
            list = [] as Array<Dictionary>;
        }
        if (match.getHistory().size() == 0) {
            return list;
        }
        var entry = {
            "date" => date,
            "score" => score(match),
            "duration" => duration,
            "points" => MatchScore.pointsWon(match.getHistory()),
            "format" => match.getConfig().format as Number
        };
        list = [entry].addAll(list) as Array<Dictionary>;
        return list.size() > MAX_MATCHES ? list.slice(0, MAX_MATCHES) : list;
    }

    // finalScore, plus a started set that is still 0-0 in games: "0-0", or its points in a deciding tie-break
    function score(match as MatchScore.Match) as String {
        var config = match.getConfig();
        var state = match.getState();
        var text = ScoreText.finalScore(config, state);
        var started = state.points[0] > 0 || state.points[1] > 0;
        if (config.format == MatchScore.FORMAT_AMERICANO || state.winner != MatchScore.NO_WINNER
                || state.games[0] > 0 || state.games[1] > 0 || !started) {
            return text;
        }
        var current = state.inTiebreak ? state.points[0] + "-" + state.points[1] : "0-0";
        return text + (text.length() > 0 ? " " : "") + current;
    }

    // "6-4 3-6 7-6" -> ["6-4", "3-6", "7-6"]; an Americano score is one item
    function sets(score as String) as Array<String> {
        var result = [] as Array<String>;
        var space = score.find(" ");
        while (space != null) {
            result.add(score.substring(0, space) as String);
            score = score.substring(space + 1, score.length()) as String;
            space = score.find(" ");
        }
        result.add(score);
        return result;
    }

    // Set number above each set score, or "PKT" above an Americano score
    function setHeading(format as Number, index as Number) as String {
        return format == MatchScore.FORMAT_AMERICANO ? "PKT" : ROMAN[index];
    }

    // History list label: "I 6-0  II 2-1", or "PKT 21-15" in Americano
    function label(format as Number, score as String) as String {
        var s = sets(score);
        var text = "";
        for (var i = 0; i < s.size(); i++) {
            text += (i > 0 ? "  " : "") + setHeading(format, i) + " " + s[i];
        }
        return text;
    }
}
