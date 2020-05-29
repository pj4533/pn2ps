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

	func run() {
		print("\(filename) \(heroname)")
    }
}

PN2PS.main()