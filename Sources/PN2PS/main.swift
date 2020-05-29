import Foundation
import ArgumentParser

struct PN2PS: ParsableCommand {
    static let configuration = CommandConfiguration(
    	commandName: "pn2ps",
        abstract: "Convert PokerNow.club logs into PokerStars hand history format"
    )

    @Argument(help: "PokerNow log filename")
    var filename: String

    @Argument(help: "Your name in log")
    var heroname: String

	@Flag(name: .long, help: "Cards are in emoji format")
    private var emoji: Bool

	func run() {
        let game = Game(filename: self.filename, useEmoji: self.emoji)
    
        for hand in game.hands {
            hand.printPokerStarsDescription(heroName: self.heroname)
        }
    }
}

PN2PS.main()