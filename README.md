# pn2ps [![Donate](https://img.shields.io/badge/donate-bitcoin-blue.svg)](https://blockchair.com/bitcoin/address/1CDF8xDX33tdkEyUcHL22DBTDEmq4ukMPp) [![Donate](https://img.shields.io/badge/donate-ethereum-blue.svg)](https://blockchair.com/ethereum/address/0xde6458b369ebadba2b515ca0dd4a4d978ad2f93a)  <a href="https://www.buymeacoffee.com/pj4533" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

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
~/projects/pn2ps ] swift run pn2ps poker_now_log_yMoA21s-qav5m5WE368jLzwRd.csv pj -m 0.01 -l 1                                                                           (master)
PokerStars Hand #1009828817026511810: Hold'em No Limit ($0.25/$0.50 USD) - 2020/06/24 21:09:07 ET
Table 'DGen' 9-max Seat #1 is the button
Seat 1: pj ($50.00 in chips)
Seat 2: Luke ($50.00 in chips)
Seat 3: ohayon ($50.00 in chips)
Seat 4: T-Hu$tle ($42.00 in chips)
Luke: posts small blind $0.25
ohayon: posts big blind $0.50
*** HOLE CARDS ***
Dealt to pj [2s 2h]
T-Hu$tle: folds
pj: raises $1.00 to $1.50
Luke: folds
ohayon: calls $1.00
*** FLOP *** [3s Ac 5c]
ohayon: bets $3.25
pj: folds
Uncalled bet ($3.25) returned to ohayon
ohayon collected $3.25 from pot
*** SUMMARY ***
Total pot: $3.25 | Rake 0
Board: [3s Ac 5c]
Seat 1: pj (button) folded on the Flop
Seat 2: Luke (small blind) folded before Flop (didn't bet)
Seat 3: ohayon (big blind) collected ($3.25) [5h 5s]
Seat 4: T-Hu$tle folded before Flop (didn't bet)
```



