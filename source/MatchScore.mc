import Toybox.Lang;

// Pure padel scoring logic: no UI, no recording, no storage.
// A Match keeps the list of points (team indices) and the state derived from it.
// Undo = drop the last point and replay, so the history is also all we need to persist.
module MatchScore {

    enum Format {
        FORMAT_CLASSIC,   // FIP: 15/30/40, games, sets
        FORMAT_AMERICANO  // Americano / Mexicano: 1 point per rally, match ends at a total
    }

    enum GameMode {
        GAME_ADVANTAGE,
        GAME_STAR_POINT,   // FIP 2026: two advantages, then one deciding point at the 3rd deuce
        GAME_GOLDEN_POINT  // one deciding point at 40:40
    }

    const NO_WINNER = -1;
    const DRAW = 2;

    class MatchConfig {
        var format as Format = FORMAT_CLASSIC;
        var gameMode as GameMode = GAME_ADVANTAGE;
        var gamesPerSet as Number = 6;  // 6 = regular set, 4 = mini-set
        var setsToWin as Number = 2;
        // 0 = the deciding set is a regular set; 7 or 10 = it is replaced by a tie-break to that many points
        var deciderTiebreakTo as Number = 7;
        var americanoTotal as Number = 21;

        function initialize() {
        }

        // For Application.Storage
        function toDictionary() as Dictionary<String, Number> {
            return {
                "format" => format as Number,
                "gameMode" => gameMode as Number,
                "gamesPerSet" => gamesPerSet,
                "setsToWin" => setsToWin,
                "deciderTiebreakTo" => deciderTiebreakTo,
                "americanoTotal" => americanoTotal
            };
        }
    }

    // Missing keys (or no stored dictionary) keep the defaults
    function configFromDictionary(dict as Dictionary<String, Number>?) as MatchConfig {
        var config = new MatchConfig();
        if (dict == null) {
            return config;
        }
        if (dict["format"] != null) { config.format = dict["format"] as Format; }
        if (dict["gameMode"] != null) { config.gameMode = dict["gameMode"] as GameMode; }
        if (dict["gamesPerSet"] != null) { config.gamesPerSet = dict["gamesPerSet"] as Number; }
        if (dict["setsToWin"] != null) { config.setsToWin = dict["setsToWin"] as Number; }
        if (dict["deciderTiebreakTo"] != null) { config.deciderTiebreakTo = dict["deciderTiebreakTo"] as Number; }
        if (dict["americanoTotal"] != null) { config.americanoTotal = dict["americanoTotal"] as Number; }
        return config;
    }

    class MatchState {
        // Current game or tie-break; in Americano: the match points
        var points as Array<Number>;
        var games as Array<Number>;
        var sets as Array<Number>;
        // Finished sets as [us, them]; a deciding tie-break set is stored as its points
        var setScores as Array<Array<Number> >;
        var inTiebreak as Boolean = false;
        var tiebreakTo as Number = 7;
        var winner as Number = NO_WINNER;

        function initialize() {
            points = [0, 0] as Array<Number>;
            games = [0, 0] as Array<Number>;
            sets = [0, 0] as Array<Number>;
            setScores = [] as Array<Array<Number> >;
        }
    }

    class Match {
        private var _config as MatchConfig;
        private var _history as Array<Number>;
        private var _state as MatchState;

        // history: points restored from storage, or null for a new match
        function initialize(config as MatchConfig, history as Array<Number>?) {
            _config = config;
            _history = history != null ? history : [] as Array<Number>;
            _state = replay(_config, _history);
        }

        // team: 0 = us, 1 = them. Ignored once the match is over.
        function addPoint(team as Number) as Void {
            if (_state.winner != NO_WINNER) {
                return;
            }
            _history.add(team);
            applyPoint(_config, _state, team);
        }

        function undo() as Boolean {
            if (_history.size() == 0) {
                return false;
            }
            _history = _history.slice(0, _history.size() - 1);
            _state = replay(_config, _history);
            return true;
        }

        // Next match in the same session (e.g. an Americano tournament)
        function reset() as Void {
            _history = [] as Array<Number>;
            _state = new MatchState();
        }

        // Call after changing the config: the same points are replayed under the new rules
        function configChanged() as Void {
            _state = replay(_config, _history);
        }

        function getState() as MatchState {
            return _state;
        }

        function getConfig() as MatchConfig {
            return _config;
        }

        function getHistory() as Array<Number> {
            return _history;
        }
    }

    function replay(config as MatchConfig, history as Array<Number>) as MatchState {
        var state = new MatchState();
        for (var i = 0; i < history.size(); i++) {
            applyPoint(config, state, history[i]);
        }
        return state;
    }

    // Total rallies won by each team, [us, them]
    function pointsWon(history as Array<Number>) as Array<Number> {
        var won = [0, 0] as Array<Number>;
        for (var i = 0; i < history.size(); i++) {
            won[history[i]] += 1;
        }
        return won;
    }

    function applyPoint(config as MatchConfig, state as MatchState, team as Number) as Void {
        var other = 1 - team;
        state.points[team] = state.points[team] + 1;

        if (config.format == FORMAT_AMERICANO) {
            var p0 = state.points[0];
            var p1 = state.points[1];
            if (p0 + p1 >= config.americanoTotal) {
                state.winner = p0 > p1 ? 0 : (p1 > p0 ? 1 : DRAW);
            }
            return;
        }

        if (state.inTiebreak) {
            if (state.points[team] >= state.tiebreakTo && state.points[team] - state.points[other] >= 2) {
                winTiebreak(config, state, team);
            }
            return;
        }

        if (isGameWon(config.gameMode, state.points[team], state.points[other])) {
            winGame(config, state, team);
        }
    }

    // p, q: points won in the game by the scoring team and the other team (0, 1, 2, 3 = 0, 15, 30, 40)
    function isGameWon(mode as GameMode, p as Number, q as Number) as Boolean {
        if (p < 4) {
            return false;
        }
        if (p - q >= 2) {
            return true;
        }
        if (mode == GAME_GOLDEN_POINT) {
            return true;  // 4:3 = the point played at 40:40
        }
        if (mode == GAME_STAR_POINT) {
            return p >= 6;  // 6:5 = the star point played at the 3rd deuce (5:5)
        }
        return false;
    }

    function winGame(config as MatchConfig, state as MatchState, team as Number) as Void {
        var other = 1 - team;
        state.points = [0, 0] as Array<Number>;
        state.games[team] = state.games[team] + 1;

        if (state.games[team] >= config.gamesPerSet && state.games[team] - state.games[other] >= 2) {
            winSet(config, state, team, state.games);
        } else if (state.games[0] == config.gamesPerSet && state.games[1] == config.gamesPerSet) {
            state.inTiebreak = true;
            state.tiebreakTo = 7;
        }
    }

    function winTiebreak(config as MatchConfig, state as MatchState, team as Number) as Void {
        if (isDeciderTiebreak(config, state)) {
            winSet(config, state, team, state.points);
        } else {
            state.games[team] = state.games[team] + 1;
            winSet(config, state, team, state.games);
        }
    }

    function winSet(config as MatchConfig, state as MatchState, team as Number, score as Array<Number>) as Void {
        state.setScores.add([score[0], score[1]] as Array<Number>);
        state.sets[team] = state.sets[team] + 1;
        state.points = [0, 0] as Array<Number>;
        state.games = [0, 0] as Array<Number>;
        state.inTiebreak = false;

        if (state.sets[team] == config.setsToWin) {
            state.winner = team;
        } else if (isDeciderTiebreak(config, state)) {
            state.inTiebreak = true;
            state.tiebreakTo = config.deciderTiebreakTo;
        }
    }

    // True while the deciding set is played as a single tie-break (e.g. super tie-break to 10)
    function isDeciderTiebreak(config as MatchConfig, state as MatchState) as Boolean {
        var last = config.setsToWin - 1;
        return config.deciderTiebreakTo > 0 && state.sets[0] == last && state.sets[1] == last;
    }

    // Label for a team's points in the current game: "0", "15", "30", "40", "AD", or a plain number
    // in a tie-break and in Americano.
    function pointLabel(config as MatchConfig, state as MatchState, team as Number) as String {
        var p = state.points[team];
        if (config.format == FORMAT_AMERICANO || state.inTiebreak) {
            return p.toString();
        }
        var q = state.points[1 - team];
        if (p >= 3 && q >= 3) {
            return p > q ? "AD" : "40";
        }
        return (["0", "15", "30", "40"] as Array<String>)[p];
    }

    // True when the next point decides the game: golden point at 40:40, star point at the 3rd deuce
    function isDecidingPoint(config as MatchConfig, state as MatchState) as Boolean {
        if (config.format != FORMAT_CLASSIC || state.inTiebreak) {
            return false;
        }
        var p0 = state.points[0];
        var p1 = state.points[1];
        if (config.gameMode == GAME_GOLDEN_POINT) {
            return p0 == 3 && p1 == 3;
        }
        if (config.gameMode == GAME_STAR_POINT) {
            return p0 == 5 && p1 == 5;
        }
        return false;
    }
}
