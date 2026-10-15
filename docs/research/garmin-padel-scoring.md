# Aplikacja Garmin do liczenia punktów w padlu: research

Data: 2026-10-14
Pytanie: czy da się napisać aplikację na zegarek Garmin, która podczas treningu padla pozwala dodawać punkty meczu, i jak to zrobić?

> Źródła to wyłącznie materiały pierwotne: dokumentacja Connect IQ (developer.garmin.com), instrukcje Garmin, sklep Connect IQ (apps.garmin.com) oraz przepisy FIP (padelfip.com). Miejsca, których nie potwierdziłem w źródle pierwotnym, oznaczam **[NIEZWERYFIKOWANE]**.

## TL;DR: werdykt

**To jest wykonalne i robi się to w sprawdzony sposób.** Trzeba napisać **Device App (watch app)**, która **sama nagrywa aktywność** (`ActivityRecording.createSession` z `Activity.SPORT_RACKET` + `Activity.SUB_SPORT_PADEL`, od API 4.1.6). Punkty dodaje się przyciskami albo dotykiem przez `BehaviorDelegate`/`InputDelegate`, a wynik zapisuje się do pliku FIT przez `FitContributor` (pola na poziomie record, lap i session). Każdy set to osobny lap. W sklepie Connect IQ działa już kilka aplikacji zbudowanych dokładnie tak.

**Data field odpada**, bo według Garmina nie może przyjmować bezpośredniego inputu od użytkownika. Widget też odpada, bo nie może nagrywać aktywności.

---

## 1. Typy aplikacji Connect IQ i co każdy z nich potrafi

Connect IQ ma 5 typów aplikacji: Watch Face, Data Field, Widget (z Glance), Device App i Audio Content Provider ([App Types](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)).

| Typ | (a) nagrywa sesję/aktywność | (b) input w trakcie aktywności | (c) działa w natywnej aktywności Padel |
|---|---|---|---|
| **Device App** | **Tak.** `Toybox.ActivityRecording` jest dostępne tylko dla typu App ([App Types, tabela modułów](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)) | **Tak**, pełny input: „watch-apps will have the most input capability” ([Input Handling](https://developer.garmin.com/connect-iq/core-topics/input-handling/)) | **Nie.** To samodzielna aplikacja, która nagrywa własną aktywność (szczegóły niżej) |
| **Data Field** | Nie tworzy sesji, ale może **dopisywać pola FIT** do natywnej aktywności (`FitContributor`) ([App Types](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)) | **Praktycznie nie** (szczegóły niżej) | **Tak.** „Data fields are plug-ins to the Garmin activity experience” ([App Types](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)) |
| **Widget / Glance** | **Nie**: „Widgets … are not allowed to record activities” ([App Types](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)) | Widget tak, z ograniczeniami. Glance: „do not accept any input” | Nie dotyczy |
| **Watch Face** | Nie | Wie tylko, że go naciśnięto ([Input Handling](https://developer.garmin.com/connect-iq/core-topics/input-handling/)) | Nie |
| **Audio Content Provider** | Nie | Nie dotyczy | Nie dotyczy |

### Czy data field może przyjmować input? Nie, i to przesądza sprawę

- Wytyczne UX Garmina mówią wprost: *„Handling direct user input is reserved for the activity experience itself. The inputs for your data field should come from the activity, sensors or the configuration.”* i *„Data fields are not allowed to take direct user input, but the user can configure them using mobile and on-device settings.”* ([UX Guidelines: Data Fields](https://developer.garmin.com/connect-iq/user-experience-guidelines/data-fields/)).
- Strona Input Handling zostawia wąski wyjątek: *„data fields can only know if they have been tapped”* ([Input Handling](https://developer.garmin.com/connect-iq/core-topics/input-handling/)). Klasa `WatchUi.DataField` nie ma jednak w API żadnych metod `onKey`/`onTap`/delegate ([DataField API](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/DataField.html)). Nie ustaliłem, jak ten „tap” działa i na których urządzeniach **[NIEZWERYFIKOWANE]**. Na pewno nie wystarczy do rozróżnienia „punkt dla nas” i „punkt dla nich” na zegarkach z przyciskami.
- Hack, który odradzam: data field dostaje callback `onTimerLap()` (API 1.3.0) ([DataField API](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/DataField.html)). Teoretycznie przycisk LAP mógłby więc oznaczać „punkt”. Daje to tylko jeden sygnał, bez rozróżnienia drużyn i bez cofania, a do tego każdy punkt tworzy lap w aktywności. To wniosek z API, nie rekomendacja Garmina.

### Czy device app może działać równolegle z natywną aktywnością Padel?

W dokumentacji nie ma mechanizmu, który pozwalałby device appowi dokładać input do **natywnej** aktywności. Wzorzec opisany przez Garmina wygląda tak, że device app **sam** nagrywa plik FIT: *„Monkey C allows for apps to start and stop recording of FIT files”* (kolejno `createSession` → `start` → `stop` → `save`/`discard`) ([Activity Recording](https://developer.garmin.com/connect-iq/core-topics/activity-recording/)). Jednocześnie może istnieć tylko jedna sesja: *„Only one Session object is allowed to exist at a time.”* ([ActivityRecording API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording.html)). Wątku równoległego działania natywnej aktywności i device appa nie znalazłem w dokumentacji opisanego wprost **[NIEZWERYFIKOWANE]**. Praktyka sklepu (sekcja 6) pokazuje jednak, że wszystkie aplikacje do liczenia wyniku zastępują natywną aktywność, zamiast działać obok niej.

### Typ sportu dla sesji: jest padel

W `Toybox.Activity` ([Activity API](https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity.html)):

| Stała | Wartość | Od API |
|---|---|---|
| `SPORT_TENNIS` | 8 | 3.2.0 |
| `SPORT_RACKET` | 64 | 4.1.6 |
| `SUB_SPORT_PADEL` | 85 | 4.1.6 |
| `SUB_SPORT_PICKLEBALL` | 84 | 4.1.6 |
| `SUB_SPORT_SQUASH` / `BADMINTON` / `RACQUETBALL` / `TABLE_TENNIS` | 94–97 | 4.1.6 |

`createSession` przyjmuje `:sport`, `:subSport` i wymagany `:name` (sugerowane maksimum to 15 znaków). Wymaga uprawnienia `Fit`. Garmin zastrzega: *„The SPORT_* defines the type of activity, but is not guaranteed to change device behavior.”* ([ActivityRecording API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording.html)). Enumy `Sport`/`SubSport` z modułu `ActivityRecording` są oznaczone jako deprecated, więc należy używać tych z `Toybox.Activity` (tamże).

Na urządzeniach z API < 4.1.6 trzeba mieć fallback, np. `SPORT_TENNIS` albo `SPORT_GENERIC`. To moja propozycja, nie zalecenie Garmina.

Czy aktywność `SPORT_RACKET/SUB_SPORT_PADEL` pokaże się w Garmin Connect jako „Padel” z właściwą ikoną/typem, czy jako „Other”? W źródłach pierwotnych tego nie potwierdziłem **[NIEZWERYFIKOWANE]**. Na forum Garmina użytkownicy zgłaszali, że natywny Padel ląduje w typie „Other” ([forum](https://forums.garmin.com/apps-software/mobile-apps-web/f/garmin-connect-web/324609/add-racket-sports-as-an-activity-in-garmin-connect), źródło niepierwotne).

## 2. Czy Garmin natywnie wspiera padla i ma wbudowane liczenie wyniku?

- **Profil aktywności Padel: tak.** Instrukcja fēnix 8 (© 2026) wymienia w kategorii „Racket Sports”: *Badminton, Padel, Pickleball, Platform Tennis, Racquetball, Squash, Table Tennis, Tennis* ([fēnix 8 Owner's Manual PDF](https://static.garmin.com/pumac/fenix8series_OM_EN-SG.pdf)). Instrukcja Forerunner 165 też ma na liście Padel, Pickleball i Tennis, z dopiskiem *„Make sure to update your watch software to get the latest activities”* ([FR165 manual: Activities List](https://www8.garmin.com/manuals/webhelp/GUID-607F08F6-33FC-40BF-9727-84E54043D82D/EN-US/GUID-36A7AEB4-9D57-4E23-8A80-B13F71C3650A.html)). Autor aplikacji „Padel” w sklepie CIQ pisze, że natywny Padel trafił na m.in. Fenix 6, Fenix 7, Venu 2, FR745 i FR945 ([store: Padel](https://apps.garmin.com/apps/e8a51031-06b0-4ab8-86dd-c5418afa1425)). To deklaracja dewelopera, nie Garmina, a pełnej listy urządzeń i firmware od Garmina nie znalazłem **[NIEZWERYFIKOWANE]**.
- **Wbudowane liczenie wyniku w padlu/tenisie: nie znalazłem.** W instrukcji fēnix 8 sekcja „Keeping Score” dotyczy wyłącznie golfa, a przy sportach rakietowych nie ma opisu liczenia wyniku ([fēnix 8 manual](https://static.garmin.com/pumac/fenix8series_OM_EN-SG.pdf)). Blog Garmina o pickleballu opisuje profil aktywności (czas, HR, kalorie), ale nie liczenie wyniku ([Garmin blog: Pickleball](https://www.garmin.com/en-US/blog/fitness/activating-the-pickleball-feature-on-your-garmin-watch/)). Nie mogę wykluczyć, że ta funkcja pojawi się w nowszym firmware konkretnego modelu **[NIEZWERYFIKOWANE]**. Warto sprawdzić release notes swojego zegarka.

## 3. Zapis wyniku w FIT i synchronizacja

### FitContributor

- Pola tworzy się przez `Session.createField(name, fieldId, type, {:mesgType, :units, :count, :nativeNum})` (API 1.3.0) ([Session API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html)).
- Typy wiadomości to `MESG_TYPE_RECORD` (20, wykres, zapis „never written faster than once per second”), `MESG_TYPE_LAP` (19) i `MESG_TYPE_SESSION` (18). Typy danych to `DATA_TYPE_SINT8 … DOUBLE` i `DATA_TYPE_STRING` ([FitContributor API](https://developer.garmin.com/connect-iq/api-docs/Toybox/FitContributor.html)).
- Limity: `DATA_TYPE_STRING` nie działa dla `MESG_TYPE_RECORD`. *„Apps are limited to 256 total bytes per message”*, a data fieldy mają 32 bajty na wiadomość ([Session API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html)). Data fieldy mogą zapisać do 16 metryk ([UX: Data Fields](https://developer.garmin.com/connect-iq/user-experience-guidelines/data-fields/)).
- Widoczność w Garmin Connect ustawia blok `<fitContributions>` w zasobach: `<fitField id=… displayInChart displayInActivityLaps displayInActivitySummary sortOrder precision chartTitle dataLabel unitLabel fillColor>`. *„Field id _must_ match the fitField id in resources or your data will not display!”* Wykresy obsługują tylko dane liczbowe ([Activity Recording](https://developer.garmin.com/connect-iq/core-topics/activity-recording/)).
- Podgląd przed publikacją umożliwia narzędzie **Monkey Graph** z SDK (wymaga pliku FIT + IQ) ([Activity Recording](https://developer.garmin.com/connect-iq/core-topics/activity-recording/)). Developer fields w prawdziwym Garmin Connect można przetestować przez **Beta App** ([Beta Apps](https://developer.garmin.com/connect-iq/core-topics/beta-apps/)).

### Proponowany model pól (mój projekt)

| Pole | mesgType | Typ | Uwagi |
|---|---|---|---|
| `point_diff` (różnica punktów, my − oni) | RECORD | SINT16 | wykres przebiegu meczu |
| `games_us`, `games_them` | LAP | UINT8 | jeden lap = jeden set |
| `sets_us`, `sets_them` | SESSION | UINT8 | podsumowanie |
| `points_us`, `points_them` | SESSION | UINT16 | podsumowanie |
| `final_score` (np. „6-4 3-6 7-6”) | SESSION | STRING (`:count` ~24) | string jest dozwolony poza RECORD |

- **Laps:** `Session.addLap()` (API 1.0.0) ([Session API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html)). Lap na set jest czytelny. Lap na gem daje dużo lapów, ale za to szczegółowe HR/czas per gem. W sklepie aplikacja „Tennis/Padel Activity with Score” robi lap per set ([store](https://apps.garmin.com/apps/4d4d0d60-bd66-4dc5-b165-c7be677a8f85)).
- **Tętno:** sensory trzeba włączyć przed nagrywaniem (`Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE])`) ([Activity Recording](https://developer.garmin.com/connect-iq/core-topics/activity-recording/), [Sensors](https://developer.garmin.com/connect-iq/core-topics/sensors/)).
- **Odporność na crash:** bieżący stan meczu warto trzymać w `Application.Storage` ([Persisting Data](https://developer.garmin.com/connect-iq/core-topics/persisting-data/)).

### Synchronizacja z telefonem/backendem

1. **Najprościej:** plik FIT sam synchronizuje się z Garmin Connect, a stamtąd można go pobierać przez **Garmin Connect Developer Program** po stronie serwera: *„The FIT file will sync with Garmin Connect. You can use the Garmin Connect Developer Program to process the FIT file from a web service.”* ([Activity Recording](https://developer.garmin.com/connect-iq/core-topics/activity-recording/)).
2. **Na żywo:** `Toybox.Communications` (uprawnienie `Communications`), czyli `transmit()` (API 1.0.0) do aplikacji-companion na telefonie (Connect IQ Mobile SDK iOS/Android) albo `makeWebRequest()` (API 1.3.0) przez telefon lub WiFi ([Communications API](https://developer.garmin.com/connect-iq/api-docs/Toybox/Communications.html), [Communicating with Mobile Apps](https://developer.garmin.com/connect-iq/core-topics/communicating-with-mobile-apps/)). Komunikacja działa jak skrzynka pocztowa (mailbox), nie jak socket (tamże). Tak działa RallyPoint, który ma live scoreboard w przeglądarce ([store: RallyPoint](https://apps.garmin.com/pl-PL/apps/ba8e2555-cf31-45fe-8876-68a4f3b2cbb6), uprawnienia m.in. `Communications`).

## 4. UX inputu

- **Behaviors zamiast konkretnych klawiszy:** `BehaviorDelegate.onSelect/onBack/onMenu/onNextPage/onPreviousPage` (API 1.0.0) mapują się na przyciski albo dotyk, zależnie od urządzenia. Do niskiego poziomu służą `InputDelegate.onKey/onKeyPressed/onKeyReleased/onTap/onSwipe/onHold` ([Input Handling](https://developer.garmin.com/connect-iq/core-topics/input-handling/)).
- **Układ 5 przycisków:** lewy środkowy = up/previous (przytrzymanie = menu), lewy dolny = down/next, prawy górny = select/start-stop, prawy dolny = back. **Touch + 2 przyciski:** swipe up/down = previous/next, tap = select, swipe w lewo = back ([Designing Workflows](https://developer.garmin.com/connect-iq/user-experience-guidelines/designing-workflows-and-interactions/)).
- Garmin zaleca minimum interakcji podczas wysiłku i niezmienianie zachowania back: *„If your app is intended to be used during physical activity, try to limit the number of interactions”*, *„The back behavior is one of the most common behaviors on Garmin devices. Avoid modifying this behavior in your app.”* Przyciski są lepsze niż dotyk, bo dotyk sprawia trudności przy mokrych dłoniach i w ruchu ([Designing Workflows](https://developer.garmin.com/connect-iq/user-experience-guidelines/designing-workflows-and-interactions/)).
- **Blokada ekranu/przycisków w trakcie aktywności:** w dokumentacji CIQ nie znalazłem opisu, jak systemowa blokada (lock) zachowuje się wobec device appa **[NIEZWERYFIKOWANE]**. Trzeba to przetestować na własnym zegarku.

**Rekomendowane mapowanie:**

| Akcja | Przyciski | Dotyk |
|---|---|---|
| Punkt dla nas | UP (`onPreviousPage`) | swipe up / tap górnej połowy |
| Punkt dla nich | DOWN (`onNextPage`) | swipe down / tap dolnej połowy |
| Cofnij | BACK (`onBack`), cofa ostatni punkt, a przy pustej historii pokazuje potwierdzenie wyjścia | swipe w lewo |
| Pauza / Stop / Zapisz | START (`onSelect`) → menu Save/Discard/Resume | przycisk start |
| Ustawienia (format gema, sety) | długie UP (`onMenu`) | |

To mapowanie jest zgodne z praktyką sklepu. RallyPoint: *„Button watches — UP/DOWN to score, BACK to undo, START for menu”*, a na dotyku *„swipe up for your point, swipe down for theirs, swipe left to undo”* ([store](https://apps.garmin.com/pl-PL/apps/ba8e2555-cf31-45fe-8876-68a4f3b2cbb6)). Garmin odradza zmianę zachowania back, więc **undo na BACK to świadomy kompromis**. Alternatywą zgodną z wytycznymi jest undo pod długim DOWN albo w menu. Do tego `Toybox.Attention` (wibracja) jako potwierdzenie każdego punktu oraz alert przy set/match point.

## 5. Zasady liczenia punktów w padlu (FIP, obowiązują od 01.01.2026)

Źródło: [FIP Rules of Padel, Review of application 01.01.2026 (PDF)](https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf), Rule 1 „Score in a game”, Tie-break, Alternative score methods, Rule 5.

**Gem, 3 warianty do wyboru (ustawienie aplikacji):**
1. **Advantage:** 15, 30, 40, gem. Przy 40:40 jest „deuce”, potem „advantage”. Gem wygrywa się dwoma punktami z rzędu i może trwać bez końca.
2. **Star Point** (nowość 2026): przy 40:40 jest „deuce 1” i „advantage 1”. Jeśli przewagę straci się, następuje „deuce 2” i „advantage 2”. Kolejna strata daje „deuce 3” i jeden decydujący **Star Point**. Para odbierająca wybiera stronę odbioru. Według [komunikatu FIP](https://www.padelfip.com/2025/12/between-innovation-and-tradition-introducing-the-star-point-the-scoring-system-that-appeals-to-everyone/) Star Point obowiązuje od 2026 w Premier Padel, CUPRA FIP Tour, FIP Promises i FIP Beyond.
3. **Golden Point (no advantage):** przy 40:40 rozgrywa się jeden decydujący punkt, a stronę odbioru wybiera para odbierająca.

**Set:** wygrywa para, która pierwsza zdobędzie 6 gemów z przewagą 2. Przy 5:5 gra się do 7:5, przy 6:6 rozgrywa się tie-break.
**Tie-break:** liczy się 0, 1, 2…, wygrywa para, która pierwsza zdobędzie 7 punktów z przewagą 2. Set kończy się wtedy wynikiem 7-6. Kolejność serwisu to 1 punkt, potem po 2 punkty na zmianę, a zmiana stron następuje co 6 punktów.
**Mecz:** do 2 wygranych setów. Opcjonalnie trzeci set można grać bez tie-breaka, czyli do przewagi 2 gemów.
**Formaty alternatywne:** mini-set do 4 gemów (tie-break przy 4:4), tie-break do 7 zamiast 3. seta, **super tie-break do 10** zamiast 3. seta.
**Zmiana stron:** po 1., 3. i każdym kolejnym nieparzystym gemie seta (Rule 5).

### 5a. Tryb Americano / Mexicano

Americano i Mexicano to formaty towarzyskie i turniejowe, nie część przepisów FIP. W przepisach FIP 2026 ich nie ma ([FIP Rules of Padel](https://www.padelfip.com/wp-content/uploads/2025/12/FIP_Rules-of-Padel.pdf)), a oficjalnej, wiążącej definicji nie znalazłem. Poniższy opis to powszechna praktyka klubowa **[NIEZWERYFIKOWANE]**:

- **Liczenie:** każda wymiana daje 1 punkt. Nie ma 15/30/40, gemów ani setów.
- **Koniec meczu:** mecz kończy się, gdy **suma** punktów obu par osiągnie ustaloną liczbę (np. 21 daje wyniki typu 12:9). Popularne limity to 16, 21, 24 i 32, więc limit powinien być ustawieniem. Przy parzystym limicie możliwy jest remis (np. 12:12 przy 24).
- **Americano a Mexicano:** liczenie jest identyczne. Różni się dobór par w kolejnych rundach: Americano rotuje partnerów według ustalonego harmonogramu, Mexicano dobiera pary według bieżącego rankingu.
- **Serwis:** liczba serwisów na gracza przed zmianą (np. 2 lub 4) różni się między klubami **[NIEZWERYFIKOWANE]**.

Implikacje dla aplikacji:
- Zegarek liczy **jeden mecz** (rundę). Tabela całego turnieju z rotacją partnerów i rankingiem to osobna funkcja, wygodniejsza w aplikacji na telefon (sekcja 3, synchronizacja).
- W pliku FIT wystarczą pola `points_us` i `points_them` (SESSION) oraz `point_diff` (RECORD). Jeśli na zegarku ma się nagrywać kilka rund pod rząd, każda runda może być osobnym lapem.
- Tryb Americano/Mexicano jest już w sklepie: robi to aplikacja [Padel Score](https://apps.garmin.com/en-US/apps/6e2a5efa-a802-4318-b204-e3b121e830c4) (sekcja 6).

Implikacje dla kodu: stan meczu (`points[2]`, `deuceCount`, `games[2]`, `sets[][]`, `inTiebreak`, `server`) najlepiej trzymać jako **czystą funkcję `apply(state, event) → state`** oraz **stos stanów do undo**. Dzięki temu cofanie jest trywialne, a logikę da się testować jednostkowo (Connect IQ ma `Toybox.Test`, [App Types: tabela modułów](https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/)). Konfigurowalne powinny być: tryb (klasyczny / Americano-Mexicano z limitem punktów), wariant gema (Advantage / Star / Golden), format seta (6 / 4 gemy) i decider (pełny set / TB7 / super TB10).

## 6. Istniejące aplikacje (dowód wykonalności)

Wszystkie poniższe mają w sklepie typ **Device App** (`typeId 2`) i uprawnienia `Fit` + `FitContributor`, co potwierdza architekturę „device app, który sam nagrywa”:

| Aplikacja | Co robi | Uprawnienia |
|---|---|---|
| [Tennis/Padel Activity with Score and more](https://apps.garmin.com/apps/4d4d0d60-bd66-4dc5-b165-c7be677a8f85) | Padel/tenis: Golden Point i Star Point, tie-break, undo, lap per set, pola CIQ z przebiegiem punktów widoczne na wykresach w Garmin Connect. Mapowanie: Start = punkt Home, Back/Lap = punkt Visitor, Down = undo | Fit, Positioning, FitContributor |
| [RallyPoint | Racket Sports Score Tracker](https://apps.garmin.com/pl-PL/apps/ba8e2555-cf31-45fe-8876-68a4f3b2cbb6) | Padel i 6 innych sportów, golden point/advantage, super-tiebreak, live scoreboard w przeglądarce, zapis do Garmin Connect | Fit, Communications, FitContributor, Sensor… |
| [Padel Score](https://apps.garmin.com/en-US/apps/6e2a5efa-a802-4318-b204-e3b121e830c4) | Americano/Mexicano: UP/DOWN = punkty, Back = undo, zapis do FIT | Fit, FitContributor |
| [Padel App](https://apps.garmin.com/en-US/apps/dcbc76d4-bc6c-4406-89b4-4c15c63d4fd8) | Scoreboard UP/DOWN lub tap lewej/prawej połowy, zapis gemów/setów do Garmin Connect (w wersji płatnej) | Fit, FitContributor, Sensor… |

(Dane pochodzą z metadanych stron sklepu Connect IQ, stan na 2026-10-14.)

## 7. Toolchain

- **SDK:** Connect IQ SDK Manager pobiera SDK i profile urządzeń. Logowanie odbywa się kontem Garmin ([Getting Started](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/)).
- **Język:** Monkey C. **IDE:** rozszerzenie „Monkey C” do VS Code (wymaga Java 11+ i SDK ≥ 4.0.6). Klucz deweloperski RSA 4096 trzeba trzymać bezpiecznie, bo bez niego nie zaktualizujesz aplikacji w sklepie (tamże).
- **Projekt:** komenda `Monkey C: New Project` z typem projektu Watch App. W `manifest.xml` ustawia się min. API i listę urządzeń (`Monkey C: Edit Products`) ([Your First App](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)). Dla `SUB_SPORT_PADEL` min. API to 4.1.6, chyba że przewidzisz fallback.
- **Symulator:** uruchamia się przez `Run Without Debugging`. Nagrywanie FIT testuje się przez menu Simulation (Start/Stop/Lap/Save) ([Activity Recording](https://developer.garmin.com/connect-iq/core-topics/activity-recording/)). Przykład referencyjny z SDK to **RecordSample** (tamże).
- **Sideload:** `Monkey C: Build for Device`, a potem skopiowanie `.prg` do `GARMIN/APPS` na zegarku podłączonym przez USB ([Your First App](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)).
- **Publikacja:** `Monkey C: Export Project` tworzy plik `.iq`, który wgrywa się w „Submit an App”. Review trwa zwykle do 72 h. Developer fields w Garmin Connect można przetestować wcześniej przez Beta App ([Publishing](https://developer.garmin.com/connect-iq/core-topics/publishing-to-the-store/), [Beta Apps](https://developer.garmin.com/connect-iq/core-topics/beta-apps/)).

## 8. Rekomendowana architektura

```
PadelApp (AppBase, typ: watch-app)
├── MatchModel      : czysta logika (state + apply(event) + undo stack), konfiguracja formatu
├── Recorder        : ActivityRecording session (SPORT_RACKET/SUB_SPORT_PADEL, fallback dla API<4.1.6),
│                     Sensor HR, FitContributor fields, addLap() na koniec seta, save/discard
├── ScoreView       : WatchUi.View, duży wynik (punkty / gemy / sety, serwujący, "STAR POINT"/"GOLDEN")
├── ScoreDelegate   : BehaviorDelegate, UP=nasz, DOWN=ich, BACK=undo, START=menu pauzy, długie UP=ustawienia
├── Persistence     : Application.Storage, snapshot stanu po każdym punkcie (odporność na crash)
└── (opcjonalnie) Sync : Communications.transmit / makeWebRequest → companion lub backend
```

Kroki z kryteriami weryfikacji:
1. `MatchModel` + testy (`Toybox.Test`): przypadki deuce/star/golden, 5:5→7:5, 6:6→TB, super TB10, undo przez granicę gema i seta, Americano do 21 (i remis przy parzystym limicie). **Weryfikacja:** testy zielone.
2. Widok + delegate w symulatorze, bez nagrywania. **Weryfikacja:** sekwencja klawiszy daje oczekiwany wynik.
3. Nagrywanie: sesja, HR, lap per set, pola FIT, `fitContributions`. **Weryfikacja:** FIT z symulatora otwarty w Monkey Graph pokazuje wykres i podsumowanie.
4. Sideload na własny zegarek i jeden prawdziwy mecz. **Weryfikacja:** aktywność w Garmin Connect ma typ padel (do sprawdzenia, sekcja 1) i pola wyniku. Sprawdzić też zachowanie blokady przycisków.
5. (Opcjonalnie) Beta App, potem publikacja.

**Werdykt:** wykonalne, z niskim ryzykiem technicznym. Pozostałe niewiadome sprawdzisz na sprzęcie: (1) jak Garmin Connect sklasyfikuje aktywność `RACKET/PADEL` z aplikacji CIQ, (2) jak zachowuje się systemowa blokada w trakcie aktywności na Twoim modelu, (3) jakie API level ma Twój zegarek, bo od tego zależy dostępność `SUB_SPORT_PADEL`.
