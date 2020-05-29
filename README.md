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

