# Plan: historia meczów (#5) oraz tętno i czas na ekranie (#7)

Źródło pomysłów: `docs/research/feature-ideas.md`, sekcje 5 i 7.

## Decyzje

- **Czas meczu, nie sesji:** `Activity.getActivityInfo().timerTime` minus wartość zapamiętana na starcie meczu i przy „Nowy mecz”. `timerTime` nie liczy pauz. Po crashu start meczu się gubi i czas liczy się od odtworzenia. To trzeba dopisać do „Known limits” w CLAUDE.md.
- **Historia:** 20 ostatnich meczów w `Application.Storage`, klucz np. `matches`. Wpis powstaje przy „Nowy mecz” i przy „Zapisz”, nie przy „Odrzuć”. Mecz 0:0 nie trafia do historii.
- **Podsumowanie:** pokazywane tylko po „Zapisz”, nie automatycznie po wygranej. Zawiera wynik set po secie, czas i punkty my/oni. Dowolny przycisk zamyka aplikację.
- **Historia w menu pauzy:** pozycja „Historia” otwiera listę (`Menu2`: data i wynik). Wybór meczu otwiera ten sam ekran podsumowania.
- **Tętno i czas (#7), werdykt z prototypu:** jedna mała szara linia `142  23:41` (FONT_XTINY, LT_GRAY) nad linią statusu, na `h * 0.80`. Bez kolorów stref, bez łuku, bez uprawnienia `UserProfile`. Gdy nie ma tętna, pokazuje „--”. Prototyp leży na gałęzi `prototype/hr-time` (commit a8e3812). Odświeżanie co 1 s. Zachowanie przy wygaszonym ekranie sprawdzić na zegarku.

## Kroki

1. ~~Logika historii przez TDD~~: **zrobione**. `source/MatchHistory.mc` (`add(list, match, date, duration)`), `ScoreText.durationText(seconds)` i 4 testy w `MatchScoreTest.mc` (30/30 zielone). Jeszcze nie zacommitowane.
2. **Czas meczu w `Recorder`:** zapamiętanie `timerTime` na starcie i w `newMatch`. Metoda zwraca czas meczu w sekundach. Weryfikacja: symulator.
3. **Zapis do historii:** w `NewMatchConfirmDelegate` (przed `reset`) i przy `:save` w `PauseMenuDelegate`: `MatchHistory.add(Storage.getValue("matches"), match, Time.now().value(), czas)`, potem zapis do Storage. Weryfikacja: kilka meczów w symulatorze, potem restart i sprawdzenie, że historia przetrwała.
4. **Ekrany:** podsumowanie po „Zapisz” i „Historia” w menu pauzy (nowe stringi w `resources/strings/strings.xml`). Weryfikacja: użytkownik klika w symulatorze.
5. **Tętno i czas na ekranie** według werdyktu powyżej. `ScoreView` przechodzi z odświeżania co minutę na co 1 s. Sprawdzić, czy linia nie koliduje ze statusem („TIE-BREAK DO 10”) ani z Americano.
6. **Domknięcie:** CLAUDE.md (Behavior, Storage, Known limits), buildy release na oba zegarki, `/code-review`, test baterii w prawdziwym meczu.

Testy: `monkeyc ... --unit-test` i `monkeydo ... -t` (polecenia w CLAUDE.md). Symulator musi być uruchomiony.
