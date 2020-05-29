# pn2ps
Convert PokerNow.club logs into PokerStars hand history format

```
OVERVIEW: Convert PokerNow.club logs into PokerStars hand history format

USAGE: pn2ps <filename> <heroname> [--limit <limit>] [--emoji]

ARGUMENTS:
  <filename>              PokerNow log filename
  <heroname>              Your name in log

OPTIONS:
  -l, --limit <limit>     Limit amount of hands processed
  -e, --emoji             Cards are in emoji format
  -h, --help              Show help information.
```

### Helpful Commands

`swift build` Builds app to the `.build` folder

`./.build/debug/pn2ps` Runs app after building

`swift run pn2ps` Runs app directly

`swift package generate-xcodeproj` Generates an xcode project file

### Example

```
~/projects/pn2ps ] swift run pn2ps poker_now_log_UGuOwS47MCsTi83geNU0nRxxc.csv pj -e -l 1
PokerStars Hand #159062723498386: Hold'em No Limit ($0.25/$0.50 USD) - 2020/05/27 20:53:54 ET
Table 'DGen' 9-max Seat #2 is the button
Seat 1: pj
Seat 2: ohayon
Seat 3: drew
Seat 4: Luk-Drgn
Seat 5: Eli
Seat 6: undefined
drew: posts small blind $0.25
Luk-Drgn: posts big blind $0.50
*** HOLE CARDS ***
Dealt to pj [7h Ts]
Eli: calls $0.50
undefined: folds
pj: folds
ohayon: calls $0.50
drew: calls $0.25
Luk-Drgn: checks
*** FLOP *** [2c Kc 4h]
drew: checks
Luk-Drgn: checks
Eli: checks
ohayon: bets $0.50
drew: folds
Luk-Drgn: calls $0.50
Eli: folds
*** TURN *** [2c Kc 4h] [6s]
Luk-Drgn: checks
ohayon: bets $0.50
Luk-Drgn: folds
Uncalled bet ($0.50) returned to ohayon
ohayon collected $3.00 from pot
*** SUMMARY ***
Total pot: $3.00 | Rake 0
Board: [2c Kc 4h 6s]
Seat 1: pj folded before Flop (didn't bet)
Seat 2: ohayon (button) collected ($3.00)
Seat 3: drew (small blind) folded on the Flop
Seat 4: Luk-Drgn (big blind) folded on the Turn
Seat 5: Eli folded on the Flop
Seat 6: undefined folded before Flop (didn't bet)
```



