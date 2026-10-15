# Pomysły na nowe funkcje: co mają inne aplikacje i o co proszą użytkownicy

Data: 2026-10-15
Pytanie: jakie funkcje mają inne aplikacje do liczenia wyniku w padlu i tenisie na zegarki (Connect IQ, Apple Watch, Wear OS, natywny Garmin), czego najczęściej brakuje użytkownikom i co z tego warto i da się dodać do PadelUp?

> Źródła to materiały pierwotne: strony sklepów (apps.garmin.com, App Store, Google Play) i recenzje na nich, wątki na forum Garmina (forums.garmin.com), dokumentacja Connect IQ (developer.garmin.com) i definicje urządzeń z lokalnego SDK. Opisy i recenzje ze sklepu Connect IQ pobrałem z jego publicznego API JSON (`apps.garmin.com/api/appsLibraryExternalServices/api/asw/apps/<id>` oraz `.../<id>/reviews`), z którego korzysta strona sklepu. Stan na 2026-10-15. Recenzje cytuję w skrócie, z datą. Miejsca, których nie potwierdziłem, oznaczam **[NIEZWERYFIKOWANE]**.
>
> **Reddit (r/padel, r/Garmin) był niedostępny** (WebSearch blokuje domenę, a `reddit.com/.../search.json` zwraca 403). Głosy użytkowników pochodzą więc wyłącznie z recenzji w sklepach i z forum Garmina. Wątki z Reddita trzeba przejrzeć ręcznie **[NIEZWERYFIKOWANE]**.

## Podsumowanie

- **Natywny Padel Garmina nie liczy wyniku.** Rejestruje czas, tętno i kalorie. To samo mówią użytkownicy i deweloperzy na forum ([app-ideas: Padel](https://forums.garmin.com/developer/connect-iq/f/app-ideas/274544/padel)). Na fēnix 8 Garmin usunął też dystans z profilu Padel, bo był niedokładny ([forum fēnix 8](https://forums.garmin.com/outdoor-recreation/outdoor-recreation/f/fenix-8-series/398275/padel-activity)). Nisza aplikacji do liczenia wyniku jest więc realna. W sklepie CIQ jest już kilkanaście aplikacji, z czego część została wydana w 2026.
- **Standard rynku, którego PadelUp nie ma:** wskaźnik serwującego i strony serwisu, Silver Point, tętno i czas na ekranie, podsumowanie i historia meczów na zegarku, własne formaty (np. set do 9, best of 5, dowolny limit Americano).
- **Najczęstsze skargi w recenzjach:** (1) wyniku nie widać w Garmin Connect, (2) zbyt małe cyfry, (3) brakujący wariant liczenia (Silver Point, set do 9, super tie-break, Americano), (4) przypadkowe dotknięcia i blokada ekranu dotykowego, (5) odwrotne przypisanie przycisków / brak trybu leworęcznego, (6) nieznany serwujący, (7) zużycie baterii.
- **Najlepsze kandydatury dla PadelUp** (tanie i mocno udokumentowane): Silver Point, zamiana przycisków, większe cyfry, wskaźnik serwującego ze zmianą stron, tętno i czas meczu na ekranie, podsumowanie meczu na zegarku i własne formaty. Droższe wyróżniki: live scoreboard i zapowiedź głosowa przez telefon.

---

## 1. Konkurencja i jej funkcje

### 1a. Connect IQ (Garmin)

Wszystkie poniższe to Device App (`typeId 2`). Oceny i liczby pobrań pochodzą ze sklepu (stan na 2026-10-15).

| Aplikacja | Ocena / recenzje / pobrania | Najważniejsze funkcje | Źródło |
|---|---|---|---|
| **Padel Go** | 4,8 / 53 / 1000+, płatna (24 h trial) | Advantage, Golden, **Silver**, Star Point. Formaty: 1 set, best of 3, TB w 3. secie, sam TB do 7/10, **własny format** (sety, gemy, w tym do 9). Singiel/debel, **schemat kortu z pozycją gracza i serwującym**, alerty GAME/SET/deuce, undo, **historia 20 meczów**, statystyki w GC i wykres różnicy punktów, GPS na zewnątrz, motywy kortu, wibracja opcjonalna, wyłączenie dotyku | [store](https://apps.garmin.com/apps/3f718124-ae33-4086-a695-06ed70efd676) |
| **Padel Smash** | 4,9 / 21 / 100+, płatna (~9,99 €) | Unlimited deuce / Star / Silver / Golden (zmiana w trakcie meczu), set standard lub **Pro Set do 9**, „New Set”. Americano/Mexicano: limit 16–40, **„first to limit” lub suma**, **rotacja serwisu 2/4/6**. **Mini-kort z serwującym i stroną**, zmiana serwującego (przytrzymanie UP), **historia 10 meczów**, undo 15 pkt, **wyłączenie dotyku**, **pasek tętna ze strefami**, **live broadcast z odczytem głosowym** na padelsmash.app (PIN), % wygranych na serwisie/returnie w GC, lap na set | [store](https://apps.garmin.com/apps/c9449f59-dbe3-4059-b567-a9e873f34daf), [forum](https://forums.garmin.com/developer/connect-iq/f/showcase/444848/app-padel-smash-padel-scoring-on-your-wrist-with-star-point-and-mexicano) |
| **Padelix** | 4,7 / 17 / 10 000+, darmowa | Golden/advantage, 4 tryby (w tym formaty FFT: 4 gemy, 9 gemów), **własne zapisane formaty**, **stoper meczu**, serwujący i strona, **kolejność serwisu w TB**, undo 30 pkt, przerwanie meczu, „New match” w tej samej aktywności, podsumowanie gem po gemie, **zamiana przycisków**, **rozmiar tekstu**, kolory, GPS opcjonalny | [store](https://apps.garmin.com/apps/f30bc7b8-a12b-4a46-8694-7d4c7de7859a) |
| **Padel Point** | 5,0 / 4 / 1000+, darmowa | Advantage/Golden/Star, opcjonalny super TB, **mecz na czas (60/90 min) z alertami 10/5 min**, **rotacja serwisu P1/P2**, **wibracja przy set i match point**, **przypomnienie o zmianie stron**, undo 32 kroki, statystyki (serwis/return, breaki, max prowadzenie, gemy z deuce), odtworzenie po zamknięciu | [store](https://apps.garmin.com/apps/ad745f6e-5dd8-481b-8eea-3dc59e47d82d) |
| **Padel Score** (jsokol) | 4,1 / 22 / 1000+, darmowa | 7 trybów gema (w tym Silver, Receiver's Advantage, „First to 11”), 1/2/3 sety lub **Endless**, gemy w secie 4/5/6/custom 1–15, konfigurowalny super TB, **znacznik serwującego**, **statystyki serwis/return per set w FIT**, wibracja i dotyk do wyłączenia, auto-start nagrywania | [store](https://apps.garmin.com/apps/990f30c5-14da-4935-9c53-3b6be84cbef3) |
| **Padel IQ** | 4,2 / 12 / 1000+, darmowa | Normal + Americano (**dowolny limit punktów**), golden point, ustawienia w trakcie meczu, **interwał zmiany serwisu**, opcjonalne statystyki 4 graczy (dotyk w ćwiartki: punkt, błąd siatka/ściana), **historia meczów na zegarku z rozbiciem na gemy**, lapy per gem | [store](https://apps.garmin.com/apps/88b2093c-db1f-476d-a790-20575b3a0d17) |
| **RallyPoint** | 3,8 / 13 / 100+ | 7 sportów, golden/advantage, super TB, **live scoreboard www z PIN i głosem w 5 językach**, wibracja przy game/set/match point, 5 języków | [store](https://apps.garmin.com/apps/ba8e2555-cf31-45fe-8876-68a4f3b2cbb6) |
| **Tennis/Padel Activity with Score** | 5,0 / 1 / 100+ | Golden/Star z alertami, **winnery/błędy** (dwuklik), break pointy, **serwujący i strona**, undo wszystkich akcji, wykresy CIQ w GC, do 5 setów | [store](https://apps.garmin.com/apps/4d4d0d60-bd66-4dc5-b165-c7be677a8f85) |
| **PadelSpeak** | brak ocen / 100+ | 9 formatów FFT, tryb własny dla trenerów, **transmisja live (QR + kod)**, **zapowiedź głosowa przez telefon / głośnik BT**, tętno na ekranie | [store](https://apps.garmin.com/apps/09034736-f847-478b-bb4b-d369dea72886) |
| **Padel - Score** | 3,4 / 5 / 100+ | Rotacja serwującego **i odbierającego**, **zmiana stron**, tryb punktowy, **4 zapisane „ulubione” konfiguracje** | [store](https://apps.garmin.com/apps/cef1de70-e71c-42f9-948b-7ecd1cb0b93c) |
| **Padel ScoreBoard** | 3,6 / 7 / 1000+ | Wymaga aplikacji na Androida (duża tablica wyników z dźwiękiem na telefonie), 19 języków (w tym polski) | [store](https://apps.garmin.com/apps/167e9066-9e76-4564-9a1c-0694c50c8a77) |
| **Padel Tempo** | 5,0 / 2 / 100+ | Konfiguracja meczu na telefonie, zegarek jako pilot, zapowiedzi na telefonie | [store](https://apps.garmin.com/apps/ed28a8f7-58b0-4647-96d0-c96558ce17e8) |
| **Padel AI** | 4,5 / 59 / 10 000+, 10 € | **Rozpoznawanie uderzeń z akcelerometru** (typ, siła), od v4 także liczenie wyniku | [store](https://apps.garmin.com/apps/d8596455-fcf5-4d6a-a2f3-94a746eaf8a0) |
| **Padel Score** (Americano) | 3,0 / 2 / 1000+ | Americano/Mexicano: **kto serwuje i 1./2. serwis**, opcjonalnie kto zdobył/stracił punkt (siatka/ściana) | [store](https://apps.garmin.com/apps/6e2a5efa-a802-4318-b204-e3b121e830c4) |
| **Tennis Studio** (tenis, używany też do padla) | 4,8 / 80 / 1000+ | Serwujący, **kiedy zmienić strony i ile trwa przerwa (odliczanie)**, czas gema, liczba deuce, alerty break/set/match point, **wstrzymanie meczu i dokończenie później**, statystyki 1./2. serwisu | [store](https://apps.garmin.com/apps/2777129e-8a5b-4974-92ed-8e38d57bf0cf) |
| **Tennis Go** (ten sam autor co Padel Go) | 5,0 / 33 / 1000+ | **Tryb rozgrzewki** liczony osobno, Free Play, wiele meczów w jednej aktywności, łuk tętna ze strefami | [store](https://apps.garmin.com/apps/c4e0d92b-5e7b-4dde-940d-0f54ebd69922) |

Przegląd nie jest pełny. Wyszukiwarka sklepu dla „padel” zwraca kilkadziesiąt aplikacji, ale większość ma po kilka pobrań i żadnych recenzji.

### 1b. Apple Watch i Wear OS (dla porównania)

| Aplikacja | Platforma | Funkcje istotne dla nas | Źródło |
|---|---|---|---|
| PadelPro | Apple Watch | Tap, serwujący z rotacją, **wskaźnik strony deuce/advantage**, Americano, statystyki break/set/match point, archiwum meczów | [App Store](https://apps.apple.com/us/app/padel-score-tracker-padelpro/id6758962753) |
| PadelTick | Apple Watch | Wynik, Apple Health (HR, kalorie), **udostępnianie wyniku na żywo** | [App Store](https://apps.apple.com/us/app/padel-tracker-padeltick/id6744892176) |
| Padelio | Apple Watch | Rozpoznawanie uderzeń (bandeja, vibora), wynik na żywo, także wieloosobowy | [App Store](https://apps.apple.com/us/app/pickleball-tracker-padelio/id6502829514) |
| Tennis Scorecard | Apple Watch | **Wskazówki o zmianie serwisu i stron**, Apple Health, **zapowiedź wyniku przez głośnik BT z zegarka** | [App Store](https://apps.apple.com/us/app/tennis-scorecard-app/id6451323049) |
| SwingVision | iPhone + Apple Watch | Analiza wideo z AI, automatyczny wynik z kamery, challenge linii z zegarka | [App Store](https://apps.apple.com/us/app/swingvision-tennis-pickleball/id989461317) |
| Smashpoint | iPhone + Apple Watch | 5 poziomów szczegółowości (od samych gemów po typy uderzeń), transmisja live, link do meczu | [App Store](https://apps.apple.com/us/app/smashpoint-tennis-tracker/id1098174650) |
| PADEL'EM | Wear OS + Apple Watch | Uderzenia i błędy, Americano, **zapowiedź wyniku przez głośnik zegarka lub BT**, trener AI | [Google Play](https://play.google.com/store/apps/details?id=com.padelem.padelem) |
| Racket Score | Wear OS | Golden/advantage, **edycja kolejności serwisu**, best of 3/5, historia na zegarku, Health Connect | [Google Play](https://play.google.com/store/apps/details?id=com.padel.score) |
| Padel Scoreboard - Match Stats | Wear OS + telefon | Golden, TB, super TB, **Pro Set**, tryby własne, link do udostępnienia wyniku | [Google Play](https://play.google.com/store/apps/details?id=xyz.zeliuk.apppadel) |

Na Apple Watch i Wear OS powtarzają się te same funkcje co w CIQ, a do tego **synchronizacja z telefonem (historia, udostępnianie)** i **głos**. Playtomic, popularna aplikacja do rezerwacji kortów, nie ma według opisu w App Store aplikacji na zegarek ([App Store](https://apps.apple.com/us/app/playtomic-padel-pickleball/id1242321076): wyszukiwanie iTunes nie zwraca wsparcia dla Watch). Użytkownicy przepisują wyniki z zegarka do Playtomic ręcznie (sekcja 2).

### 1c. Natywny Garmin

- Profil **Padel** jest w kategorii Racket Sports na nowszych zegarkach (np. Venu 4, Instinct 3, vívoactive 6) ([Venu 4 OM](https://www8.garmin.com/manuals/webhelp/GUID-2CF5620C-E585-4E0A-9CC3-9565533EEE4D/EN-US/Venu_4_OM_EN-US.pdf), [Instinct 3 AMOLED OM](https://www8.garmin.com/manuals/webhelp/GUID-2DA54DF8-8084-40ED-954F-EDA09C13B47F/EN-US/Instinct_3_AMOLED_OM_EN-US.pdf)). W instrukcjach nie znalazłem liczenia wyniku dla padla ani tenisa. To samo stwierdzał poprzedni research (`docs/research/garmin-padel-scoring.md`, sekcja 2).
- Forum: *„most current Garmins now have Garmin's own Padel activity, but it records time and heart rate, not the score.”* ([app-ideas: Padel](https://forums.garmin.com/developer/connect-iq/f/app-ideas/274544/padel)). Autor Padel Point nazwał swój wątek „What the native Garmin Padel activity app should have been” ([forum](https://forums.garmin.com/developer/connect-iq/f/showcase/442869/padel-point-what-the-native-garmin-padel-activity-app-should-have-been)).
- Pracownik Garmina o dystansie w profilu Padel: *„because the measurement will not be accurate, this was removed from the Fenix 8 series”* ([forum fēnix 8](https://forums.garmin.com/outdoor-recreation/outdoor-recreation/f/fenix-8-series/398275/padel-activity)).
- Nie sprawdziłem release notes fēnix 9 Pro pod kątem nowych funkcji dla sportów rakietowych **[NIEZWERYFIKOWANE]**.

---

## 2. Powtarzające się prośby i skargi użytkowników

Liczby w nawiasach oznaczają, ile niezależnych recenzji lub postów z powyższych źródeł zgłasza dany problem (licząc wszystkie aplikacje, w tym tenisowe).

| # | Prośba / skarga | Przykłady (data, aplikacja) |
|---|---|---|
| 1 | **Nie widać wyniku w Garmin Connect** po zapisaniu (8+) | „DOES NOT show you any score info in the Garmin Connect app” (2026-06-18, [Padelix](https://apps.garmin.com/apps/f30bc7b8-a12b-4a46-8694-7d4c7de7859a)); „I just dont find the Score in the garmin Connect App” (2026-05-27, Padelix); „Missing Match Result After the Match in the garmin app” (2026-03-17, [Padel IQ](https://apps.garmin.com/apps/88b2093c-db1f-476d-a790-20575b3a0d17)); „doesn’t save the full results” (2026-05-04, [Padel - Score](https://apps.garmin.com/apps/cef1de70-e71c-42f9-948b-7ecd1cb0b93c)); „Why is the score info not shown now on the activity report” (2024-06-12, [Tennis App](https://apps.garmin.com/apps/ce20a74b-818d-4bc8-8a8f-cf932c2cc910)) |
| 2 | **Wynik set po secie po meczu, żeby przepisać go do Playtomic** (3) | „see the score of each set… easier to … enter it to Playtomic” (2026-03-05, Padel IQ); „te indique los marcadores… para luego ingresar… en Playtomic” (2026-04-18, Padel - Score); „Would be good if you can see scores for games after the match” (2026-05-15, [Padel Score](https://apps.garmin.com/apps/990f30c5-14da-4935-9c53-3b6be84cbef3)) |
| 3 | **Brakujący wariant liczenia: Silver Point** (1 deuce, potem decydujący punkt) (4) | „Support for silver point pls” (2026-06-12, [Padel Smash](https://apps.garmin.com/apps/c9449f59-dbe3-4059-b567-a9e873f34daf)); „one deuce after 40-40… we play with one deuce” (2026-03-29, Padel Smash); „40-40 > advantage > deciding point” (2026-09-10, [Padel Go](https://apps.garmin.com/apps/3f718124-ae33-4086-a695-06ed70efd676)); „silver point option in tennis mode” (2026-10-13, Padel IQ) |
| 4 | **Własny format: set do 9, best of 5, liczba gemów, super TB** (10+) | „play… to 9-9 for TB” (2026-09-14, Padel Go); „how do I select best of 5?” (2026-09-27, Padel Go); „créer notre propre format” (2026-09-13, Padel Go); „At interclub we play till 9” (2026-02-27, Padel Score); „customize the number of games” (2026-01-29, Padel Smash); „match tie break to 10” (2026-05-22, Padel Score); kilka podobnych dla tenisa ([Tennis Smash](https://apps.garmin.com/apps/7d673782-5db4-4115-bb30-20248596b21b), [Tennis Studio](https://apps.garmin.com/apps/2777129e-8a5b-4974-92ed-8e38d57bf0cf)) |
| 5 | **Americano: inne limity, „first to”, 2 serwisy na stronę** (4) | „the only one… that allows changes to the Americano points to anything” (2026-10-13, Padel IQ); „best of 16-21-24… two serves per side” (2026-03-17, Padel - Score); „Americano… 32 points or 24 points” (2026-09-29, [Padel AI](https://apps.garmin.com/apps/d8596455-fcf5-4d6a-a2f3-94a746eaf8a0)) |
| 6 | **Za małe cyfry** (4) | „the size of te numbers should be 2times bigger. Cant read it” (2026-10-08, Padelix); „writing to small… need reading glasses” (2026-05-01, Padelix); „De punten zouden wel groter kunnen” (2026-10-06, Padel Smash); „characters are too large and not readable” (2020-06-17, [Tennis scoreboard](https://apps.garmin.com/apps/c93e8228-860b-4b73-8f36-9fde80349602)) |
| 7 | **Kto serwuje / zmiana serwującego / strona** (6) | „does not keep track of specific server, only which team” (2026-06-15, Padel Score); „cannot change the server after the match has started” (2026-10-13, Padel IQ); „change which team serves first in each… set” (2025-12-12, Padel IQ); „Pena não deixar escolher o serviço a cada início de cada set” (2023-02-06, [Padel App](https://apps.garmin.com/apps/dcbc76d4-bc6c-4406-89b4-4c15c63d4fd8)); Pickleball Score Keeper zaczyna opis od „Which side am I on? … Who is serving?” ([store](https://apps.garmin.com/apps/391f717d-aacc-4c93-a5ec-c46544b29da7)) |
| 8 | **Odwrotne przypisanie przycisków, tryb leworęczny** (4) | „up button, it gives the point to me, press down it gives them the point, a bit backwards… I keep giving the points the wrong way” (2026-08-23, [RallyPoint](https://apps.garmin.com/apps/ba8e2555-cf31-45fe-8876-68a4f3b2cbb6)); „left-handed mode to have a button swap option” (2026-08-18, Padel Score); „ajustar los botones de a quien da el punto el Up y el Down” (2026-05-08, Padelix); „invert the point assignment gesture” (2026-08-20, Padel Smash) |
| 9 | **Przypadkowy dotyk / blokada dotyku między punktami** (7) | „option to disable touch screen, this app closed often with accident touch” (2026-06-18, RallyPoint); „Touchscreen always locks. Very annoying” (2026-07-03, RallyPoint); „no option to disable screen lock between points” (2026-06-15, Padel Score); „you have to unlock the touchscreen between every point” (2025-09-23, Padel AI, vívoactive 6); „Fenix7 and Epix2… Disable touchscreen while into activities… ignoring it” (2022-02-02, Tennis App); „Please, make a tap instead of the swipe” (2026-08-28, Padel Smash) |
| 10 | **Typ aktywności „Tennis”/„Other” zamiast „Padel”** (5) | „Quando salvo… está como tênis e não Padel” (2023-11-18, [Padel](https://apps.garmin.com/apps/837340a6-a7ee-4f17-9131-0786bb33e3ad)); „it says tennis, but it should say padel” (2025-11-22, Padel IQ); „en vez de Otros” (2026-05-08, Padelix). Na nowych zegarkach rozwiązuje to `SUB_SPORT_PADEL` (Padel IQ i Padel Point potwierdzają, że starsze modele zapisują Tennis) |
| 11 | **Bateria** (6) | „drains about 30-40% battery per hour” (2022, Padel App); „90% of the battery… in 40min” (2026-09-19, Tennis Smash, autor twierdzi, że to błąd firmware); „can't turn off the GPS tracking… deep battery drain” (2025-12-12, Tennis Studio) |
| 12 | **Tętno, kalorie, czas widoczne w trakcie** (4) | „keep visible… calories” (2026-05-23, Tennis Smash); „you should be able to see the time while using the application” (2022-01-10, Padel App); dwie prośby o zegar w Pickleball Score Keeper (2023, [store](https://apps.garmin.com/apps/391f717d-aacc-4c93-a5ec-c46544b29da7)) |
| 13 | **GPS / dystans** (6, głównie tenis na zewnątrz) | „ability to track real-time GPS” (2025-06-25, Tennis Studio); „only tracked around 450m” (2026-04-15, Tennis Smash). Dla padla Garmin sam usunął dystans (sekcja 1c) |
| 14 | **Zmiana stron i przerwy: wskazówki i odliczanie** (3) | „change ends screen stayed on for longer” (2026-08-09, Tennis Studio); „cronómetro cuenta atrás… en los cambios de lado y descanso” (2026-05-26, [Tennis AI](https://apps.garmin.com/apps/0073ddf4-3ec7-436d-a598-d88cfd0d583a)) |
| 15 | **Tryb treningu / rozgrzewki bez wyniku** (4, tenis) | „A practice mode could be useful just to track step/distance/fc” (2021-07-16, [Tennis Tracker](https://apps.garmin.com/apps/6aa4f2e0-1892-47a6-9078-40e23ccaf56f)); „I wish there was a free play option” (2021-07-16, Tennis Tracker); „training mode” (2020-06-27, Tennis App) |
| 16 | **Undo** (wiele, w starszych aplikacjach) | „You cannot delete the point once you have assigned it” (2025-12-28, Padel App); „sans possibilité de revenir en arrière… ça ne sert pas à grand chose” (2020-10-18, Tennis App). **PadelUp to już ma** (nielimitowane undo przez replay historii) |
| 17 | **Eksport statystyk, analiza punkt po punkcie** (3) | „export statistics… json” (2025-06-24, Tennis Studio); „score progression within each game” (2026-10-06, Tennis AI) |

Wzorzec w odpowiedziach deweloperów: najlepiej oceniane aplikacje (Padel Go, Padel Smash, Padel Score/jsokol) zdobywają 5 gwiazdek tym, że **w kilka dni dodają brakujący wariant formatu**. Sam zakres formatów jest głównym polem konkurencji.

---

## 3. Kandydaci na nowe funkcje (ranking)

Ranking wynika z mojej oceny: (siła dowodu z sekcji 2) × (wartość na korcie) / (koszt w Connect IQ). Kontekst techniczny: cele `epix2pro47mm` (API 5.2, AMOLED 416×416, dotyk) i `fenix9pro51mm` (API 6.0, AMOLED 466×466, dotyk), `minApiLevel` 4.1.6, limit pamięci watch-app 768 KB na obu (lokalne `compiler.json` z SDK). `MatchScore` opiera się na replayu listy punktów, więc wszystko, co jest funkcją historii (serwis, statystyki, podsumowanie), da się wyliczyć bez nowego stanu do zapisu.

### 1. Silver Point
- **Co:** czwarty wariant gema: przy pierwszym 40:40 gra się na przewagi, a przy drugim deuce rozgrywa się punkt decydujący.
- **Dlaczego:** 4 niezależne prośby w 2026 (sekcja 2, #3). Silver Point mają Padel Go, Padel Smash i Padel Score. Padel Smash dodał go po recenzji.
- **Wykonalność:** czysta logika w `MatchScore` (Star Point z limitem 1 zamiast 2), nowa wartość w `Settings` i `ScoreText.statusText`, testy w `MatchScoreTest`. Koszt: bardzo niski. Ryzyko: brak. Silver Point nie jest częścią przepisów FIP 2026 (tam są Advantage, Star Point i Golden Point; `garmin-padel-scoring.md` sekcja 5), więc to wariant klubowy.
- **W aplikacji:** brak (są Przewaga, Star point, Golden point).

### 2. Zamiana przycisków (UP = oni, DOWN = my)
- **Co:** ustawienie „Przyciski: UP my / UP oni”. Dobrze byłoby też mieć układ ekranu, w którym rząd „my” jest zawsze po stronie przycisku, który daje nam punkt.
- **Dlaczego:** 4 skargi (sekcja 2, #8). Recenzja RallyPoint dała 2 gwiazdki wyłącznie z tego powodu. Padelix ma „button swap”. Mapowanie jest kwestią intuicji: jedni myślą „mój przycisk”, inni „przycisk bliżej mnie”.
- **Wykonalność:** zamiana w `ScoreDelegate.onPreviousPage/onNextPage` plus pozycja w `Settings`. Koszt: bardzo niski.
- **W aplikacji:** brak (UP = my na sztywno).

### 3. Większe, czytelniejsze cyfry
- **Co:** opcja „Duże cyfry”: punkty bieżącego gema największym fontem (`FONT_NUMBER_HOT`/`THAI_HOT` albo custom font), a gemy i sety mniejsze. Ewentualnie tryb wysokiego kontrastu.
- **Dlaczego:** 4 skargi (sekcja 2, #6). Padelix ma „text size”. Na korcie patrzy się na zegarek w biegu, a na AMOLED przy słońcu odczyt jest trudniejszy.
- **Wykonalność:** zmiana w `ScoreView.onUpdate`. Na 416 px (epix) i 466 px (fēnix 9) jest miejsce. Koszt: niski. Ryzyko: sprawdzić w symulatorze oba ekrany i długie stany („AD”, Americano 2-cyfrowe). Agent nie może zrobić zrzutu symulatora, więc wygląd sprawdza użytkownik.
- **W aplikacji:** częściowo: punkty używają `FONT_NUMBER_MEDIUM`, bez opcji powiększenia.

### 4. Serwujący, strona serwisu i zmiana stron
- **Co:** przy starcie meczu wybór, kto serwuje (my/oni). Na ekranie znacznik serwującej pary i strony (prawa przy parzystej liczbie punktów w gemie, lewa przy nieparzystej). W debel opcjonalnie rotacja 4 graczy (A1, B1, A2, B2). Poprawna kolejność w tie-breaku (1 punkt, potem po 2). Akcja „zmień serwującego” w menu pauzy. Przypomnienie (wibracja i napis) o zmianie stron po 1., 3., 5. gemie seta i co 6 punktów w TB (FIP Rule 5, `garmin-padel-scoring.md` sekcja 5). W Americano rotacja serwisu co 2 lub 4 punkty (ustawienie).
- **Dlaczego:** to najczęściej reklamowana funkcja konkurencji („Visual Server Guide” w Padel Smash jest w „most loved features”; schemat kortu w Padel Go; Padel Point, Padelix, Padel - Score, PadelPro). Skargi #7 i #14 z sekcji 2. W padlu kłótnie o to, kto serwuje i z której strony, są równie częste jak o wynik.
- **Wykonalność:** serwujący to deterministyczna funkcja historii i pierwszego serwującego, więc `Match(config, history)` potrzebuje tylko jednej nowej wartości w konfiguracji meczu (pierwszy serwujący). Ręczna zmiana serwującego może być specjalnym wpisem w historii, żeby undo dalej działało. Rysowanie: kropka lub mini-kort w `ScoreView`. Koszt: średni (logika TB i super TB, testy). Ryzyko: poprawność kolejności przy przejściach set → TB → kolejny set. Testy jednostkowe to pokryją.
- **W aplikacji:** brak.

### 5. Podsumowanie meczu i historia na zegarku
- **Co:** (a) po wygranej lub przy „Zapisz” ekran z wynikiem set po secie, czasem meczu, punktami my/oni i (jeśli będzie #4) punktami na serwisie i returnie. (b) Lista ostatnich np. 10–20 meczów (data, wynik, czas) dostępna z menu.
- **Dlaczego:** skargi #1 i #2. Użytkownicy chcą przepisać wynik do Playtomic. Historia jest w Padel Go (20), Padel Smash (10) i Padel IQ. Dla buildów sideload Garmin Connect nie pokazuje pól deweloperskich (CLAUDE.md, „Storage and FIT”), więc **dziś użytkownik widzi wynik tylko na zegarku do momentu zapisu**.
- **Wykonalność:** `Application.Storage`, gdzie klucz i wartość mają do 8 KB, a łącznie jest 128 KB ([Persisting Data](https://developer.garmin.com/connect-iq/core-topics/persisting-data/)). Mecz jako string `final_score` (≤63 znaki) z datą i czasem to około 100 B, więc 20 meczów zmieści się z zapasem. Widok: `WatchUi.Menu2` albo własny `View`. Koszt: niski do średniego. Ryzyko: brak.
- **W aplikacji:** częściowo. `final_score` trafia do FIT, a sety są na ekranie w trakcie meczu, ale nie ma ekranu podsumowania ani historii.

### 6. Własne formaty
- **Co:** gemy w secie 4, 5, 6, 9 (Pro Set z TB przy 8:8) albo dowolna liczba. Liczba setów 1, best of 3, best of 5. Mecz jako sam tie-break do 7 lub 10. Americano z dowolnym limitem (picker 10–60) i trybem „first to N” obok „suma = N”.
- **Dlaczego:** skargi #4 i #5 to największa grupa próśb w recenzjach. Padel Go, Padel Score/jsokol i Padelix mają formaty własne. CLAUDE.md mówi, że „Sets to win is fixed at 2”.
- **Wykonalność:** logika w `MatchScore` jest sparametryzowana (sety do 6 lub 4, TB do 7 lub 10), więc trzeba uogólnić parametry i dodać testy. Wybór liczby: `WatchUi.Picker` (API 1.2.0, [Picker](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/Picker.html)) albo cykl wartości jak obecnie w `Settings.nextValue`. Koszt: niski do średniego. Ryzyko: rośnie macierz testów, a `final_score` przy best of 5 może przekroczyć 63 znaki w Americano z wieloma meczami (dziś jest ucinanie).
- **W aplikacji:** częściowo (6 lub 4 gemy, decider pełny set / TB7 / TB10, Americano 16/21/24/32).

### 7. Tętno i czas meczu na ekranie
- **Co:** mała linia z bieżącym tętnem (kolor wg strefy) i czasem trwania meczu lub sesji, obok zegara.
- **Dlaczego:** standard konkurencji (pasek HR w Padel Smash i Tennis Smash, łuk HR w Padel Go i Tennis Go, stoper w Padelix). Skarga #12. Padel to trening, a użytkownik zegarka Garmin patrzy na tętno.
- **Wykonalność:** `Activity.getActivityInfo().currentHeartRate` i `.timerTime`/`.elapsedTime` (API 1.0.0, [Activity.Info](https://developer.garmin.com/connect-iq/api-docs/Toybox/Activity/Info.html)). Strefy: `UserProfile.getHeartRateZones()` (wymaga uprawnienia `UserProfile`, [UserProfile](https://developer.garmin.com/connect-iq/api-docs/Toybox/UserProfile.html)). Dziś widok odświeża się co minutę (zegar), więc dla HR potrzebny byłby `Timer` co 1 s. Ryzyko: bateria na AMOLED. Garmin zaleca ograniczać czas pracy ekranu, więc odświeżanie warto uzależnić od tego, czy ekran jest włączony (`onEnterSleep`/`onExitSleep` istnieją tylko dla watch face, więc dla device appa trzeba to sprawdzić **[NIEZWERYFIKOWANE]**). Koszt: niski.
- **W aplikacji:** brak (jest zegar; HR jest tylko nagrywane do FIT).

### 8. Alerty set point i match point
- **Co:** napis „PIŁKA SETOWA” / „PIŁKA MECZOWA” w linii statusu i inny wzór wibracji, gdy następny punkt może zakończyć set lub mecz (dla nas lub dla nich).
- **Dlaczego:** RallyPoint („Vibrates at game point, set point and match point”), Padel Point („haptic alerts for SET POINT and MATCH POINT”), Tennis Studio i Padel Go („alerts… for GAME, SET, deuce, advantage and deciding points”).
- **Wykonalność:** „czy następny punkt dla X kończy set” to symulacja jednego punktu w `MatchScore` (replay z dopisanym punktem). Wzór wibracji przez `Attention.vibrate` z `VibeProfile` (API 1.0.0, [Attention](https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html)). Koszt: niski.
- **W aplikacji:** częściowo (długa wibracja po zakończeniu seta lub meczu, napis GOLDEN/STAR POINT).

### 9. Wynik widoczny w Garmin Connect: publikacja jako Beta App lub w sklepie
- **Co:** nie nowa funkcja w kodzie, tylko krok dystrybucji. Pola FIT (`final_score`, gemy w lapach, wykres `point_diff`) już są, ale dla sideloadu Garmin Connect ich nie pokazuje.
- **Dlaczego:** skarga #1 jest najczęstsza w całym zestawie recenzji.
- **Wykonalność:** Beta App ([Beta Apps](https://developer.garmin.com/connect-iq/core-topics/beta-apps/)). Do publikacji w sklepie przydałaby się wersja angielska (#14) i unikalna nazwa: w sklepie są już co najmniej trzy aplikacje „Padel Score” ([1](https://apps.garmin.com/apps/990f30c5-14da-4935-9c53-3b6be84cbef3), [2](https://apps.garmin.com/apps/6e2a5efa-a802-4318-b204-e3b121e830c4), [3](https://apps.garmin.com/apps/d7f30936-c610-48cc-8434-183612236e46)). Koszt: niski (proces). Ryzyko: review Garmina do 72 h. Nazwy aktywności nie da się zmienić po starcie sesji, bo `Session` nie ma metody zmiany nazwy, jest tylko `:name` w `createSession` ([Session API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html)), więc wyniku nie da się wpisać w tytuł aktywności.
- **W aplikacji:** pola są, brak widoczności przy sideloadzie.

### 10. Obsługa dotyku: tap w połowę ekranu i wyłącznik dotyku
- **Co:** tap w górną połowę = punkt „my”, w dolną = „oni” (zgodnie z układem ekranu), swipe w lewo = undo. Ustawienie „Dotyk: wł./wył.”, żeby pot i rakieta nie dodawały punktów.
- **Dlaczego:** skarga #9 (7 recenzji). Padel Go, Padel Smash, Padel Score (jsokol) i RallyPoint dodały wyłącznik dotyku po skargach. Oba cele mają dotyk (`isTouchable: true` w `simulator.json` z SDK). CLAUDE.md: „Touch is not handled explicitly; the system maps swipes to UP/DOWN (swipe direction on the watch not verified)”.
- **Wykonalność:** `BehaviorDelegate.onTap(ClickEvent)` / `onSwipe` ([Input Handling](https://developer.garmin.com/connect-iq/core-topics/input-handling/)). Wyłączenie polega na zwracaniu `true` bez akcji. Ryzyko: systemowa blokada dotyku w trakcie aktywności jest poza kontrolą aplikacji. Deweloperzy RallyPoint i Padel IQ odsyłają do ustawień zegarka ([RallyPoint](https://apps.garmin.com/apps/ba8e2555-cf31-45fe-8876-68a4f3b2cbb6), [Padel IQ](https://apps.garmin.com/apps/88b2093c-db1f-476d-a790-20575b3a0d17)). Na sprzęcie trzeba sprawdzić, czy swipe nie podwaja punktu (system mapuje swipe na next/previous page). Koszt: niski do średniego.
- **W aplikacji:** brak jawnej obsługi.

### 11. Mecz na czas (rezerwacja kortu) i „zakończ set”
- **Co:** opcjonalny limit czasu (60 / 90 / 120 min) z wibracją 10 i 5 minut przed końcem oraz na koniec. Akcja „Zakończ set” / „Następny set” w menu, gdy czas się kończy przy niedokończonym secie.
- **Dlaczego:** Padel Point („Perfect for court bookings (60/90 mins)… alerts you at 10m, 5m, and finish”), Padel Smash i Padel IQ (wcześniejsze zamknięcie seta), Tennis AI (prośba o odliczanie). Amatorski padel gra się na rezerwacje 60–90 min.
- **Wykonalność:** `Timer.Timer` i `Attention.vibrate`. „Zakończ set” to specjalny wpis w historii, rozumiany przez replay. Koszt: niski do średniego. Ryzyko: interakcja z laps (jeden lap na set).
- **W aplikacji:** brak (jest zegar; Nowy mecz kończy cały mecz).

### 12. Statystyki serwis / return i break pointy (wymaga #4)
- **Co:** punkty wygrane przy własnym serwisie i przy returnie, break pointy wygrane i obronione, najdłuższa seria. Na ekranie podsumowania i jako pola SESSION/LAP w FIT.
- **Dlaczego:** Padel Smash i Padel Score/jsokol zapisują % serwis/return do FIT, Padel Point pokazuje breaki i max prowadzenie. Prośba w recenzji Tennis Go: „stats… like points won when serving” (2026-10-13, [Tennis Go](https://apps.garmin.com/apps/c4e0d92b-5e7b-4dde-940d-0f54ebd69922)).
- **Wykonalność:** wyliczane z historii i serwującego, bez dodatkowego inputu. FIT: limit 256 B na wiadomość dla aplikacji ([Session API](https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html)), kilka pól UINT8/UINT16 się zmieści. Każde nowe pole wymaga wpisu w `resources/fit/fit_contributions.xml`. Koszt: niski (po #4).
- **W aplikacji:** brak.

### 13. Ustawienia z telefonu (Garmin Connect)
- **Co:** te same ustawienia meczu edytowalne w aplikacji Garmin Connect / Connect IQ na telefonie, np. przed wyjściem na kort.
- **Dlaczego:** słabszy dowód. Recenzje mówią raczej o trudnym menu na zegarku (np. „Picking the options at the begining is not that easy with my Fenix 6”, 2023-02-12, [Tennis scoreboard](https://apps.garmin.com/apps/c93e8228-860b-4b73-8f36-9fde80349602)). Padel Tempo idzie dalej i konfiguruje mecz wyłącznie w telefonie.
- **Wykonalność:** `resources/settings` + `properties`, `Properties.getValue` (API 2.4.0), callback `AppBase.onSettingsChanged()` przy zmianie w trakcie działania ([Properties and App Settings](https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/)). Konflikt z obecnym `config` w `Application.Storage`: trzeba wybrać jedno źródło prawdy (np. przenieść config do Properties). Działa dla sideloadu? Strona ustawień w GCM jest powiązana z aplikacją ze sklepu **[NIEZWERYFIKOWANE]**, więc dla sideloadu pewnie dopiero po Beta App. Koszt: średni.
- **W aplikacji:** brak (ustawienia tylko na zegarku).

### 14. Wersja angielska
- **Co:** `resources-eng/strings/strings.xml` (Connect IQ wybiera język z ustawień zegarka).
- **Dlaczego:** warunek sensownej publikacji w sklepie (#9). Recenzja: „lack of support for the English language” (2026-03-23, [Padel ScoreBoard](https://apps.garmin.com/apps/167e9066-9e76-4564-9a1c-0694c50c8a77)). RallyPoint ma 5 języków. Teksty w `ScoreText` („WYGRANA”, „REMIS”) są dziś wpisane w kod i trzeba je przenieść do zasobów.
- **Wykonalność:** koszt niski. Ryzyko: brak.
- **W aplikacji:** tylko polski (`<iq:language>pol</iq:language>`).

### 15. Live scoreboard / zapowiedź głosowa przez telefon
- **Co:** wynik wysyłany na stronę WWW (PIN lub QR), którą widzowie otwierają w telefonie lub na TV, opcjonalnie czytaną głosem przez głośnik BT.
- **Dlaczego:** główny wyróżnik nowych aplikacji 2026 (RallyPoint, Padel Smash, PadelSpeak, Tennis Smash). Na Apple Watch i Wear OS ten sam trend (Tennis Scorecard, PADEL'EM). Recenzje chwalą głos („Love that you can connect a Bluetooth speaker…”, 2026-04-17, [Tennis Scorecard](https://apps.apple.com/us/app/tennis-scorecard-app/id6451323049)). Bezpośrednich próśb o tę funkcję w recenzjach CIQ jest jednak mało.
- **Wykonalność:** `Communications.makeWebRequest()` przez telefon (API 1.3.0, uprawnienie `Communications`, [JSON REST Requests](https://developer.garmin.com/connect-iq/core-topics/https/)) do własnego backendu i strony WWW z syntezą mowy w przeglądarce. Alternatywa to `Communications.transmit()` do własnej aplikacji na telefon (Mobile SDK iOS/Android, [Communicating with Mobile Apps](https://developer.garmin.com/connect-iq/core-topics/communicating-with-mobile-apps/)). Na zegarku nie ma publicznego API syntezy mowy dla device appa. `ActivityPrompts` (API 5.2.0) dotyczy tylko data fieldów i zewnętrznego silnika TTS ([Activity Prompts](https://developer.garmin.com/connect-iq/core-topics/activity-prompts/)). Koszt: wysoki (backend, hosting, prywatność, telefon musi być w zasięgu BT, co zauważa [the5krunner](https://the5krunner.com/2026/10/06/padel-smash-garmin/), źródło wtórne). Ryzyko: utrzymanie serwera, opóźnienia BLE.
- **W aplikacji:** brak.

### 16. Glance i komplikacja z ostatnim wynikiem
- **Co:** w liście glance'ów „Padel: 6-4 3-6 7-6 (wczoraj)” i/lub komplikacja dla tarczy (np. bilans W/L).
- **Dlaczego:** brak dowodu popytu. Żadna recenzja o to nie prosi, a konkurencja tego nie reklamuje. Ładny dodatek, który pozwala też uruchomić aplikację z tarczy.
- **Wykonalność:** od API 4.0.0 aplikacja musi mieć własny glance view, żeby pojawić się na liście glance'ów (*„In API level 4.0.0 and above, apps and widgets must implement a glance view to appear in the glance list”*, limit pamięci glance 64 KB na obu celach wg `compiler.json`; [Glances](https://developer.garmin.com/connect-iq/core-topics/glances/)). Komplikacje: device app może opublikować do 4 (API 4.2.0, uprawnienie `ComplicationPublisher`, `Complications.updateComplication()`; [Complications](https://developer.garmin.com/connect-iq/core-topics/complications/)). Oba cele mają API ≥ 4.2, ale `minApiLevel` 4.1.6 wymaga sprawdzenia `has :Complications`. Koszt: niski do średniego.
- **W aplikacji:** brak.

### 17. Tryb rozgrzewki / treningu bez wyniku
- **Co:** rozgrzewka nagrywana jako osobny lap przed pierwszym punktem, albo tryb „trening” bez liczenia wyniku.
- **Dlaczego:** Tennis Go ma tryb rozgrzewki, a recenzje Tennis Tracker i Tennis App proszą o tryb treningu (2020–2021, tenis). Dla padla dowód jest słaby.
- **Wykonalność:** `Session.addLap()` przy pierwszym punkcie. Koszt: niski. Ryzyko: kolejny lap komplikuje znaczenie „lap = set”.
- **W aplikacji:** częściowo: nagrywanie startuje od otwarcia aplikacji, więc rozgrzewka już się zalicza do czasu, ale nie jest wydzielona.

### Odradzane lub poza zakresem
- **GPS i dystans:** prośby dotyczą głównie tenisa na zewnątrz. Garmin sam usunął dystans z profilu Padel, bo był niedokładny ([forum fēnix 8](https://forums.garmin.com/outdoor-recreation/outdoor-recreation/f/fenix-8-series/398275/padel-activity)), a GPS jest najczęstszym źródłem skarg na baterię (sekcja 2, #11). Padel Point świadomie go nie ma.
- **Winnery i błędy per punkt** (Tennis/Padel Activity, Padel IQ, Tennis Tracker): wymaga dodatkowego inputu po każdym punkcie, wbrew zaleceniu Garmina ograniczania interakcji w trakcie wysiłku (`garmin-padel-scoring.md`, sekcja 4). Recenzje Tennis Tracker mówią o krzywej uczenia i rozpraszaniu w meczu.
- **Rozpoznawanie uderzeń z akcelerometru** (Padel AI, Padelio): osobny produkt, wymaga modelu ML i danych treningowych. Recenzje wskazują na niedokładność (np. „Me contó 16 golpes en todo el partido”, 2026-10-02, [Padel AI](https://apps.garmin.com/apps/07e78372-69b4-4354-931f-d7c4a7a3a602)).
- **Tabela turnieju Americano/Mexicano z rotacją partnerów:** to domena aplikacji na telefon (np. [Padel Americano - PadelMix](https://apps.apple.com/us/app/padel-americano-padelmix/id6505054587)). Na zegarku wystarczy „Nowy mecz”, który już jest.

---

## 4. Co PadelUp już ma (dla porządku)

Te funkcje są w aplikacji i nie są kandydatami. Konkurencja i recenzje potwierdzają, że są oczekiwane:
- Przewaga / Star point / Golden point, sety do 6 lub 4, TB, decydujący set jako TB7, TB10 lub pełny set; Americano z limitem.
- Nielimitowane undo (konkurencja ma 15–32 kroki), w tym przez granicę seta (z ograniczeniem lapów opisanym w CLAUDE.md).
- „Nowy mecz” w tej samej aktywności (Padel Go, Tennis Go, Padelix mają odpowiednik), odtworzenie meczu po crashu (Padel Point to reklamuje), menu pauzy z potwierdzeniami.
- Zapis jako `SPORT_RACKET` / `SUB_SPORT_PADEL` (rozwiązuje skargę #10 na obu celach), lap na set, pola FIT z wykresem i wynikiem.
- Wibracja na punkt i dłuższa na koniec seta lub meczu, zegar na ekranie (prośby w Pickleball Score Keeper i Padel App).

## 5. Sugerowana kolejność

1. Szybkie poprawki (każda to mała zmiana z testem): **Silver Point (#1)**, **zamiana przycisków (#2)**, **duże cyfry (#3)**, **alerty set/match point (#8)**. Weryfikacja: testy `MatchScoreTest` zielone, użytkownik sprawdza wygląd w symulatorze na obu celach.
2. **Serwujący, strona i zmiana stron (#4)**, potem **statystyki serwis/return (#12)**. Weryfikacja: testy kolejności serwisu w gemie, TB i super TB, test undo zmiany serwującego.
3. **Podsumowanie i historia (#5)** oraz **tętno i czas (#7)**. Weryfikacja: Storage po 20+ meczach w symulatorze, pomiar baterii w jednym prawdziwym meczu.
4. **Własne formaty (#6)** i **mecz na czas (#11)**.
5. **Wersja angielska (#14)** → **Beta App (#9)** → ewentualnie **ustawienia z telefonu (#13)**, **glance (#16)** i **live scoreboard (#15)**.

Do sprawdzenia na sprzęcie (poza zakresem tego researchu): czy epix Pro (Gen 2) i fēnix 9 Pro mają głośnik obsługiwany przez `Attention.playTone` (dokumentacja zaleca sprawdzenie `has`) **[NIEZWERYFIKOWANE]**; zachowanie systemowej blokady dotyku w device appie (CLAUDE.md, „Known limits”).
