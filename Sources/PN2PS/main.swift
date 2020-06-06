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

    @Option(name: .shortAndLong, default: nil, help: "Table Name")
    private var tableName: String?

	func run() {

        let game = Game(filename: self.filename)
        
        if let limit = self.limit {
            for hand in game.hands.prefix(limit) {
                hand.printPokerStarsDescription(heroName: self.heroname, multiplier: self.multiplier ?? 1.0, tableName: self.tableName ?? "DGen")
            }
        } else {
            for hand in game.hands {
                hand.printPokerStarsDescription(heroName: self.heroname, multiplier: self.multiplier ?? 1.0, tableName: self.tableName ?? "DGen")
            }
        }


    }
}

PN2PS.main()
