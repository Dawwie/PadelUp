import Toybox.Lang;

// Finished matches kept on the watch, newest first. Entries are plain dictionaries,
// so the list goes to Application.Storage as it is.
module MatchHistory {

    const MAX_MATCHES = 20;

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
            "score" => ScoreText.finalScore(match.getConfig(), match.getState()),
            "duration" => duration,
            "points" => MatchScore.pointsWon(match.getHistory())
        };
        list = [entry].addAll(list) as Array<Dictionary>;
        return list.size() > MAX_MATCHES ? list.slice(0, MAX_MATCHES) : list;
    }
}
