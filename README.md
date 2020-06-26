# pn2ps [![Donate](https://img.shields.io/badge/donate-bitcoin-blue.svg)](https://blockchair.com/bitcoin/address/1CDF8xDX33tdkEyUcHL22DBTDEmq4ukMPp) [![Donate](https://img.shields.io/badge/donate-ethereum-blue.svg)](https://blockchair.com/ethereum/address/0xde6458b369ebadba2b515ca0dd4a4d978ad2f93a)

Convert PokerNow.club logs into PokerStars hand history format

```
OVERVIEW: Convert PokerNow.club logs into PokerStars hand history format

USAGE: pn2ps <filename> <heroname> [--limit <limit>] [--multiplier <multiplier>] [--emoji]

ARGUMENTS:
  <filename>              PokerNow log filename
  <heroname>              Your name in log

OPTIONS:
  -l, --limit <limit>     Limit amount of hands processed
  -m, --multiplier <multiplier>
                          Multiply bet amounts by given value
  -e, --emoji             Cards are in emoji format
  -h, --help              Show help information.
```

### Notes

* Mac only
* Command line only

### How To Run

1. Download the latest [release](https://github.com/pj4533/pn2ps/releases)
2. Open a terminal window and find the folder you downloaded to
3. Command to make app executable:  `chmod +x pn2ps`
4. Command to run:  `./pn2ps <filename> <heroname> -m 0.01 > output_file.txt`

You might also need to give MacOS permission to run the app.

### Developer Commands

`swift build` Builds app to the `.build` folder

`swift build -c release` Build a release version

`./.build/debug/pn2ps` Runs app after building

`swift run pn2ps` Runs app directly

`swift package generate-xcodeproj` Generates an xcode project file

### Example Output

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



