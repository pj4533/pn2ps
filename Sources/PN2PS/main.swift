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

	@Option(name: .shortAndLong, default: nil, help: "Limit amount of hands processed")
    private var limit: Int?

    @Option(name: .shortAndLong, default: nil, help: "Multiply bet amounts by given value")
    private var multiplier: Double?

	@Flag(name: .shortAndLong, help: "Cards are in emoji format")
    private var emoji: Bool

	func run() {
        let game = Game(filename: self.filename, useEmoji: self.emoji)
    	
    	if let limit = self.limit { 
	        for hand in game.hands.prefix(limit) {
	            hand.printPokerStarsDescription(heroName: self.heroname, multiplier: self.multiplier ?? 1.0)
	        }
    	} else {
	        for hand in game.hands {
	            hand.printPokerStarsDescription(heroName: self.heroname, multiplier: self.multiplier ?? 1.0)
	        }    		
    	}

    }
}

PN2PS.main()