//
//  Hand.swift
//  DGenHelper
//
//  Created by PJ Gray on 5/24/20.
//  Copyright © 2020 PJ Gray. All rights reserved.
//

import Foundation

class Hand {
    var date: Date?
    var hole: [Card]?
    var river: Card?
    var turn: Card?
    var flop: [Card]?
    var pot: Int = 0
    var uncalledBet: Int = 0
    var id: UInt64 = 0
    var dealer: Player?
    var missingSmallBlinds: [Player] = []
    var smallBlind: Player?
    var bigBlind: [Player] = []
    var players: [Player] = []
    var seats: [Seat] = []
    var lines: [String] = []
    var smallBlindSize: Int = 0
    var bigBlindSize: Int = 0

    var printedShowdown: Bool = false
    
    
    // requirements as set:
    //   - date
    //   - players
    //   - smallblind  size & id
    //   - bigblinds   size & id
    //   - lines
    //   - dealer
    //   - seats
    //   - hole
    //   - missingSmallBlinds
    //   - flop
    //   - turn
    //   - river
    func printPokerStarsDescription(heroName: String, multiplier: Double, tableName: String) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        var dateString = ""
        if let date = self.date {
            dateString = formatter.string(from: date)
        }
        
        var previousAction: [String:Double] = [:]
        for player in self.players {
            previousAction[player.id ?? "error"] = 0
        }
        
        previousAction[self.smallBlind?.id ?? "error"] = Double(self.smallBlindSize) * multiplier

        for player in self.bigBlind {
            previousAction[player.id ?? "error"] = Double(self.bigBlindSize) * multiplier
        }

        var foundHoleCards = false
        var isFirstAction = false
        var currentBet = Double(self.bigBlindSize) * multiplier
        var totalPotSize = 0.0
        var streetDescription = "before Flop"
        for line in self.lines {
            if line.contains("starting hand") {
                self.uncalledBet = 0
                print("PokerStars Hand #\(self.id): Hold'em No Limit (\(String(format: "$%.02f", Double(self.smallBlindSize) * multiplier))/\(String(format: "$%.02f", Double(self.bigBlindSize) * multiplier )) USD) - \(dateString) ET")
                
                var smallBlindSeat = 0
                for seat in self.seats {
                    if self.smallBlind?.id == seat.player?.id {
                        smallBlindSeat = seat.number
                    }
                }
                
                var dealerSeat = (smallBlindSeat - 1) > 0 ? (smallBlindSeat - 1) : 10
                for seat in self.seats {
                    if self.dealer?.id == seat.player?.id {
                        dealerSeat = seat.number
                    }
                }
                
                print("Table '\(tableName)' 10-max Seat #\(dealerSeat) is the button")
            }
                        
            if line.contains("Player stacks:") {
                let playersWithStacks = line.replacingOccurrences(of: "Player stacks: ", with: "").components(separatedBy: " | ")
                for playerWithStack in playersWithStacks {
                    var seatNumber = playerWithStack.components(separatedBy: " ").first
                    let playerWithStackNoSeat = playerWithStack.replacingOccurrences(of: "\(seatNumber ?? "") ", with: "")
                    seatNumber = seatNumber?.replacingOccurrences(of: "#", with: "")
                    let seatNumberInt = (Int(seatNumber ?? "0") ?? 0)
                    
                    let nameIdArray = playerWithStackNoSeat.components(separatedBy: "\" ").first?.replacingOccurrences(of: "\"", with: "").components(separatedBy: " @ ")
                    let stackSize = playerWithStack.components(separatedBy: "\" (").last?.replacingOccurrences(of: ")", with: "")
                    let stackSizeFormatted = "\(String(format: "$%.02f", (Double(stackSize ?? "0") ?? 0.0) * multiplier))"

                    print("Seat \(seatNumberInt): \(nameIdArray?.first ?? "error") (\(stackSizeFormatted) in chips)")
                }
                                
                print("\(self.smallBlind?.name ?? "Unknown"): posts small blind \(String(format: "$%.02f", Double(self.smallBlindSize) * multiplier))")
                
                for bigBlind in self.bigBlind {
                    print("\(bigBlind.name ?? "Unknown"): posts big blind \(String(format: "$%.02f", Double(self.bigBlindSize) * multiplier ))")
                }
            }
            
            if line.contains("Your hand") {
                print("*** HOLE CARDS ***")
                print("Dealt to \(heroName) [\(self.hole?.map({$0.rawValue}).joined(separator: " ") ?? "error")]")
                foundHoleCards = true
            }

            if line.starts(with: "\"") {
                if line.contains("bets") || line.contains("shows") || line.contains("calls") || line.contains("raises") || line.contains("checks") || line.contains("folds") || line.contains("wins") || line.contains("gained") || line.contains("collected") {
                    if !foundHoleCards {
                        print("*** HOLE CARDS ***")
                        foundHoleCards = true
                    }
                    let nameIdArray = line.components(separatedBy: "\" ").first?.components(separatedBy: " @ ")
                    if let player = self.players.filter({$0.id == nameIdArray?.last}).first {
                        if line.contains("bets") {
                            if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                self.seats[index].preFlopBet = true
                            }

                            let betSize = (Double(line.replacingOccurrences(of: " and go all in", with: "").components(separatedBy: " ").last ?? "0") ?? 0) * multiplier
                            print("\(player.name ?? "unknown"): bets \(String(format: "$%.02f", betSize))")
                            currentBet = betSize
                            isFirstAction = false

                            previousAction[player.id ?? "error"] = betSize
                        }
                        
                        if line.contains("raises") {
                            
                            if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                self.seats[index].preFlopBet = true
                            }

                            let raiseSize = (Double(line.replacingOccurrences(of: " and go all in", with: "").components(separatedBy: "to ").last ?? "0") ?? 0) * multiplier
                            if isFirstAction {
                                print("\(player.name ?? "unknown"): bets \(String(format: "$%.02f", raiseSize))")
                                currentBet = raiseSize
                                isFirstAction = false
                            } else {
                                print("\(player.name ?? "unknown"): raises \(String(format: "$%.02f", raiseSize - currentBet)) to \(String(format: "$%.02f", raiseSize))")
                                currentBet = raiseSize
                            }
                            previousAction[player.id ?? "error"] = raiseSize
                        }

                        if line.contains("calls") {
                            if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                self.seats[index].preFlopBet = true
                            }

                            let callAmount = line.replacingOccurrences(of: " and go all in", with: "").components(separatedBy: "calls ").last ?? "0"
                            let callSize = (Double(callAmount) ?? 0) * multiplier
                            if isFirstAction {
                                print("\(player.name ?? "unknown"): bets \(String(format: "$%.02f", callSize))")
                                currentBet = callSize
                                isFirstAction = false
                            } else {
                                let uncalledPortionOfBet = callSize - (previousAction[player.id ?? "error"] ?? 0.0)
                                print("\(player.name ?? "unknown"): calls \(String(format: "$%.02f", uncalledPortionOfBet))")
                            }
                            previousAction[player.id ?? "error"] = callSize
                        }

                        if line.contains("checks") {
                            print("\(player.name ?? "unknown"): checks")
                        }

                        if line.contains("folds") {
                            print("\(player.name ?? "unknown"): folds")
                            if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                
                                if (streetDescription == "before Flop") && !self.seats[index].preFlopBet {
                                    self.seats[index].summary = "\(player.name ?? "Unknown") folded \(streetDescription) (didn't bet)"
                                } else {
                                    self.seats[index].summary = "\(player.name ?? "Unknown") folded \(streetDescription)"
                                }
                                
                            }
                        }
                        
                        if line.contains("shows") {
                            let handComponents = line.components(separatedBy: "shows a ").last?.replacingOccurrences(of: ".", with: "").components(separatedBy: ", ")
                            if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                self.seats[index].showedHand = handComponents?.map({ (EmojiCard(rawValue: $0)?.emojiFlip.rawValue ?? "error") }).joined(separator: " ") ?? "error"
                            }
                        }
                        
                        if line.contains("collected ") {
                            // has showdown
                            if line.contains(" from pot with ") {
                                var winPotSize = (Double(line.components(separatedBy: " collected ").last?.components(separatedBy: " from pot with ").first ?? "0") ?? 0.0) * multiplier

                                // remove missing smalls -- poker stars doesnt do this?
                                winPotSize = winPotSize - (Double(self.smallBlindSize * self.missingSmallBlinds.count) * multiplier)

                                let winDescription = line.components(separatedBy: " from pot with ").last?.components(separatedBy: " (").first ?? "error"
                                let winningHandComponents = line.components(separatedBy: "hand: ").last?.replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                                totalPotSize = winPotSize
                                if !self.printedShowdown {
                                    print("*** SHOW DOWN ***")
                                    self.printedShowdown = true
                                }
                                print("\(player.name ?? "Unknown"): shows [\(winningHandComponents?.map({ (EmojiCard(rawValue: $0)?.emojiFlip.rawValue ?? "error") }).joined(separator: " ") ?? "error")] (\(winDescription))")
                                print("\(player.name ?? "Unknown") collected \(String(format: "$%.02f", winPotSize)) from pot")
                                
                                if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                    self.seats[index].summary = "\(player.name ?? "Unknown") showed [\(winningHandComponents?.map({ (EmojiCard(rawValue: $0)?.emojiFlip.rawValue ?? "error") }).joined(separator: " ") ?? "error")] and won (\(String(format: "$%.02f", winPotSize))) with \(winDescription)"
                                }

                            } else {
                                // no showdown
                                var gainedPotSize = (Double(line.components(separatedBy: " collected ").last?.components(separatedBy: " from pot").first ?? "0") ?? 0.0) * multiplier

                                // remove missing smalls -- poker stars doesnt do this?
                                gainedPotSize = gainedPotSize - (Double(self.smallBlindSize * self.missingSmallBlinds.count) * multiplier)

                                if self.uncalledBet > 0 {
                                    print("Uncalled bet (\(String(format: "$%.02f", Double(self.uncalledBet) * multiplier))) returned to \(player.name ?? "Unknown")")
                                }
                                
                                if self.flop == nil {
                                    var preFlopAction = 0.0
                                    
                                    for player in self.players {
                                        preFlopAction = preFlopAction + (previousAction[player.id ?? "error"] ?? 0.0)
                                    }
                                    
                                    // catching edge case of folding around preflop
                                    if preFlopAction == (Double(self.bigBlindSize + self.smallBlindSize) * multiplier) {
                                        gainedPotSize = Double(self.smallBlindSize) * multiplier
                                    }
                                }

                                totalPotSize = gainedPotSize
                                print("\(player.name ?? "Unknown") collected \(String(format: "$%.02f", gainedPotSize)) from pot")
                                if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                                    self.seats[index].summary = "\(player.name ?? "Unknown") collected (\(String(format: "$%.02f", gainedPotSize)))"
                                }

                            }
                            
                        }
                        
                    }
                }
            }
            
            if line.starts(with: "Uncalled bet") {
                let uncalledString = line.components(separatedBy: " returned to").first?.replacingOccurrences(of: "Uncalled bet of ", with: "")
                self.uncalledBet = Int(uncalledString ?? "0") ?? 0
            }
            
            if line.starts(with: "flop:") {
                print("*** FLOP *** [\(self.flop?.map({$0.rawValue}).joined(separator: " ") ?? "error")]")
                isFirstAction = true
                currentBet = 0
                for player in self.players {
                    previousAction[player.id ?? "error"] = 0
                }
                streetDescription = "on the Flop"
            }

            if line.starts(with: "turn:") {
                print("*** TURN *** [\(self.flop?.map({$0.rawValue}).joined(separator: " ") ?? "error")] [\(self.turn?.rawValue ?? "error")]")
                isFirstAction = true
                currentBet = 0
                for player in self.players {
                    previousAction[player.id ?? "error"] = 0
                }
                streetDescription = "on the Turn"
            }

            if line.starts(with: "river:") {
                print("*** RIVER *** [\(self.flop?.map({$0.rawValue}).joined(separator: " ") ?? "error") \(self.turn?.rawValue ?? "error")] [\(self.river?.rawValue ?? "error")]")
                isFirstAction = true
                currentBet = 0
                for player in self.players {
                    previousAction[player.id ?? "error"] = 0
                }
                streetDescription = "on the River"
            }
            
            if self.lines.last == line {
                print("*** SUMMARY ***")
                print("Total pot: \(String(format: "$%.02f", totalPotSize)) | Rake 0")
                var board: [Card] = []
                board.append(contentsOf: self.flop ?? [])
                if let turn = self.turn { board.append(turn) }
                if let river = self.river { board.append(river) }
                
                if board.count > 0 {
                    print("Board: [\(board.map({$0.rawValue}).joined(separator: " "))]")
                }
                for seat in self.seats {
                    var summary = seat.summary
                    if self.dealer?.id == seat.player?.id {
                        summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (button)")
                    }

                    if self.smallBlind?.id == seat.player?.id {
                        summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (small blind)")
                    }

//                    for smallBlind in self.missingSmallBlinds {
//                        if smallBlind.id == seat.player?.id {
//                            summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (missing small blind)")
//                        }
//                    }
                    for bigBlind in self.bigBlind {
                        if bigBlind.id == seat.player?.id {
                            summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (big blind)")
                        }
                    }
                    if seat.showedHand != nil {
                        print("Seat \(seat.number): \(summary) [\(seat.showedHand ?? "error")]")
                    } else {
                        print("Seat \(seat.number): \(summary)")
                    }
                }
                print("")
            }
        }

        
    }
}
