import Foundation
import ArgumentParser
import SwiftCSV
import PokerNowKit

struct PN2PS: ParsableCommand {
    static let configuration = CommandConfiguration(
    	commandName: "pn2ps",
        abstract: "Convert PokerNow.club logs into PokerStars hand history format"
    )

    @Argument(help: "Your name in log")
    var heroname: String

    @Option(help: "PokerNow Table ID to download")
    var tableId: String?
    
    @Option(help: "PokerNow log filename")
    var filename: String?

	@Option(name: .shortAndLong, default: nil, help: "Limit amount of hands processed")
    private var limit: Int?

    @Option(name: .shortAndLong, default: nil, help: "Multiply bet amounts by given value")
    private var multiplier: Double?

    @Option(name: .shortAndLong, default: nil, help: "Table Name")
    private var tableName: String?

    func processCSV(_ csvFile: CSV) {
        let game = Game(rows: csvFile.namedRows)
                
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
    
	func run() {
        do {
            if let filename = self.filename {
                let csvFile = try CSV(url: URL(fileURLWithPath: filename))
                self.processCSV(csvFile)
            } else if let tableId = self.tableId {
                if let skipToken = ProcessInfo.processInfo.environment["SKIP_TOKEN"] {
                    let semaphore = DispatchSemaphore(value: 1)
                    semaphore.wait()
                    DispatchQueue.global().async {
                        do {
                            if let url = URL(string: "https://www.pokernow.club/games/\(tableId)/poker_now_log_\(tableId).csv?skip_captcha_token=\(skipToken)") {
                                let csvText = try String(contentsOf: url)
                                let csvFile = try CSV(string: csvText)
                                self.processCSV(csvFile)
                                semaphore.signal()
                                
                            }
                        } catch let error {
                            print(error.localizedDescription)
                            semaphore.signal()
                        }
                    }
                    semaphore.wait()
                } else {
                    print("Error: No captcha token found.")
                }
            }
            
        } catch let parseError as CSVParseError {
            print(parseError)
        } catch {
            print("Error loading file")
        }

    }
}

PN2PS.main()
