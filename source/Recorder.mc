import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.Sensor;

// Padel activity session with the match score written to FIT developer fields.
// One lap = one set, and a new match in the same session also starts a lap.
// Session fields sum up all matches of the session; final_score lists them, e.g. "21-15 / 18-24".
// Field ids must match resources/fit/fit_contributions.xml.
class Recorder {
    private var _session as ActivityRecording.Session;
    private var _pointDiff as FitContributor.Field;
    private var _lapGamesUs as FitContributor.Field;
    private var _lapGamesThem as FitContributor.Field;
    private var _setsUs as FitContributor.Field;
    private var _setsThem as FitContributor.Field;
    private var _pointsUs as FitContributor.Field;
    private var _pointsThem as FitContributor.Field;
    private var _finalScore as FitContributor.Field;
    private var _lapPointsUs as FitContributor.Field;
    private var _lapPointsThem as FitContributor.Field;
    private var _setsFinished as Number = 0;
    private var _lapStartPoints as Array<Number> = [0, 0] as Array<Number>;
    // Earlier matches of this session
    private var _previousScores as String = "";
    private var _previousSets as Array<Number> = [0, 0] as Array<Number>;
    private var _previousPoints as Array<Number> = [0, 0] as Array<Number>;
    // Timer time (ms) when the current match started; after a crash it is the restore time
    private var _matchStart as Number = 0;

    // match: the restored match, so its finished sets do not add laps to this session
    function initialize(match as MatchScore.Match) {
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        _session = ActivityRecording.createSession({
            :name => "Padel",
            :sport => Activity.SPORT_RACKET,
            :subSport => Activity.SUB_SPORT_PADEL
        });
        _pointDiff = _session.createField("point_diff", 0, FitContributor.DATA_TYPE_SINT16, {:mesgType => FitContributor.MESG_TYPE_RECORD});
        _lapGamesUs = _session.createField("games_us", 1, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_LAP});
        _lapGamesThem = _session.createField("games_them", 2, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_LAP});
        _setsUs = _session.createField("sets_us", 3, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION});
        _setsThem = _session.createField("sets_them", 4, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION});
        _pointsUs = _session.createField("points_us", 5, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_SESSION});
        _pointsThem = _session.createField("points_them", 6, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_SESSION});
        _finalScore = _session.createField("final_score", 7, FitContributor.DATA_TYPE_STRING, {:mesgType => FitContributor.MESG_TYPE_SESSION, :count => 64});
        _lapPointsUs = _session.createField("lap_points_us", 8, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_LAP});
        _lapPointsThem = _session.createField("lap_points_them", 9, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_LAP});
        _setsFinished = match.getState().setScores.size();
        _lapStartPoints = MatchScore.pointsWon(match.getHistory());
        update(match);
        _session.start();
        _matchStart = timerTime();
    }

    function isRecording() as Boolean {
        return _session.isRecording();
    }

    function pause() as Void {
        _session.stop();
    }

    function resume() as Void {
        _session.start();
    }

    // Call after every point and undo. A finished set closes the lap (one lap = one set);
    // the last set's lap is closed by save(). Undo cannot remove a lap that was already added.
    function update(match as MatchScore.Match) as Void {
        var state = match.getState();
        var points = MatchScore.pointsWon(match.getHistory());
        var finished = state.setScores.size();

        _pointDiff.setData(points[0] - points[1]);
        _setsUs.setData(_previousSets[0] + state.sets[0]);
        _setsThem.setData(_previousSets[1] + state.sets[1]);
        _pointsUs.setData(_previousPoints[0] + points[0]);
        _pointsThem.setData(_previousPoints[1] + points[1]);
        var scores = _previousScores + ScoreText.finalScore(match.getConfig(), state);
        // The field holds 64 bytes, including the terminator
        _finalScore.setData(scores.length() > 63 ? scores.substring(0, 63) : scores);
        // Clamped: undo across a set boundary leaves the lap start after the current points
        _lapPointsUs.setData(max(points[0] - _lapStartPoints[0], 0));
        _lapPointsThem.setData(max(points[1] - _lapStartPoints[1], 0));

        if (finished > _setsFinished) {
            var last = state.setScores[finished - 1];
            _lapGamesUs.setData(last[0]);
            _lapGamesThem.setData(last[1]);
            if (state.winner == MatchScore.NO_WINNER) {
                _session.addLap();
                _lapStartPoints = points;
            }
        }
        if (state.winner == MatchScore.NO_WINNER) {
            _lapGamesUs.setData(state.games[0]);
            _lapGamesThem.setData(state.games[1]);
        }
        _setsFinished = finished;
    }

    // Call before match.reset(): closes the current match's lap and adds it to the session totals
    function newMatch(match as MatchScore.Match) as Void {
        _matchStart = timerTime();
        var state = match.getState();
        var points = MatchScore.pointsWon(match.getHistory());
        if (match.getHistory().size() == 0) {
            return;
        }
        _session.addLap();
        _previousScores += ScoreText.finalScore(match.getConfig(), state) + " / ";
        _previousSets = [_previousSets[0] + state.sets[0], _previousSets[1] + state.sets[1]] as Array<Number>;
        _previousPoints = [_previousPoints[0] + points[0], _previousPoints[1] + points[1]] as Array<Number>;
        _setsFinished = 0;
        _lapStartPoints = [0, 0] as Array<Number>;
    }

    // Time of the current match in seconds, without pauses
    function matchDuration() as Number {
        return (timerTime() - _matchStart) / 1000;
    }

    // Activity timer in ms; it does not count pauses
    private function timerTime() as Number {
        var info = Activity.getActivityInfo();
        if (info == null || info.timerTime == null) {
            return 0;
        }
        return info.timerTime as Number;
    }

    private function max(a as Number, b as Number) as Number {
        return a > b ? a : b;
    }

    function save() as Void {
        _session.stop();
        _session.save();
    }

    function discard() as Void {
        _session.stop();
        _session.discard();
    }
}
