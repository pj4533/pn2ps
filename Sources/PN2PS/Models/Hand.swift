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
    var useEmoji: Bool = false
    var hole: [Card]?
    var river: Card?
    var turn: Card?
    var flop: [Card]?
    var pot: Int = 0
    var uncalledBet: Int = 0
    var id: Int = 0
    var dealer: Player?
    var missingSmallBlinds: [Player] = []
    var smallBlind: Player?
    var bigBlind: [Player] = []
    var players: [Player] = []
    var seats: [Seat] = []
    var lines: [String] = []
    var smallBlindSize: Int = 0
    var bigBlindSize: Int = 0

    
    func printPokerStarsDescription(heroName: String, multiplier: Double) {

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
        var uncalledBet = Double(self.bigBlindSize) * multiplier
        var currentBet = Double(self.bigBlindSize) * multiplier
        var totalPotSize = 0.0
        var streetDescription = "before Flop"
        for line in self.lines {
            if line.contains("starting hand") {
                print("PokerStars Hand #\(self.id): Hold'em No Limit (\(String(format: "$%.02f", Double(self.smallBlindSize) * multiplier))/\(String(format: "$%.02f", Double(self.bigBlindSize) * multiplier )) USD) - \(dateString) ET")
                
                var dealerIndex = 1
                var currentIndex = self.seats.firstIndex(where: {$0.player?.name == heroName}) ?? 1
                for seatIndex in 1...(self.seats.count) {
                    let seat = self.seats[currentIndex]
                    if self.dealer?.id == seat.player?.id {
                        dealerIndex = seatIndex
                    }
                    currentIndex = currentIndex + 1
                    if currentIndex == self.seats.count {
                        currentIndex = 0
                    }
                }
                
                print("Table 'DGen' 9-max Seat #\(dealerIndex) is the button")
                
                currentIndex = self.seats.firstIndex(where: {$0.player?.name == heroName}) ?? 1
                for seatIndex in 1...(self.seats.count) {
                    print("Seat \(seatIndex): \(self.seats[currentIndex].player?.name ?? "error")")
                    currentIndex = currentIndex + 1
                    if currentIndex == self.seats.count {
                        currentIndex = 0
                    }
                }
                
                print("\(self.smallBlind?.name ?? "Unknown"): posts small blind \(String(format: "$%.02f", Double(self.smallBlindSize) * multiplier))")
                
                for smallBlind in self.missingSmallBlinds {
                    print("\(smallBlind.name ?? "Unknown"): posts missing small blind \(String(format: "$%.02f", Double(self.smallBlindSize) * multiplier))")
                }
                for bigBlind in self.bigBlind {
                    print("\(bigBlind.name ?? "Unknown"): posts big blind \(String(format: "$%.02f", Double(self.bigBlindSize) * multiplier ))")
                }
            }
                        
            
            if line.contains("Your hand") {
                print("*** HOLE CARDS ***")
                print("Dealt to \(heroName) [\(self.hole?.map({$0.rawValue}).joined(separator: " ") ?? "error")]")
                foundHoleCards = true
            }

            if line.contains("shows") || line.contains("calls") || line.contains("raises") || line.contains("checks") || line.contains("folds") || line.contains("wins") || line.contains("gained") {
                if !foundHoleCards {
                    print("*** HOLE CARDS ***")
                    foundHoleCards = true                 
                }
                let nameIdArray = line.components(separatedBy: "\" ").first?.components(separatedBy: " @ ")
                if let player = self.players.filter({$0.id == nameIdArray?.last}).first {
                    if line.contains("raises") {
                        
                        if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                            self.seats[index].preFlopBet = true
                        }

                        let raiseSize = (Double(line.components(separatedBy: "with ").last ?? "0") ?? 0) * multiplier
                        if isFirstAction {
                            print("\(player.name ?? "unknown"): bets \(String(format: "$%.02f", raiseSize))")
                            uncalledBet = raiseSize
                            currentBet = raiseSize
                            isFirstAction = false
                        } else {
                            print("\(player.name ?? "unknown"): raises \(String(format: "$%.02f", raiseSize - currentBet)) to \(String(format: "$%.02f", raiseSize))")
                            uncalledBet = raiseSize - currentBet
                            currentBet = raiseSize
                        }
                        previousAction[player.id ?? "error"] = raiseSize
                    }

                    if line.contains("calls") {
                        if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                            self.seats[index].preFlopBet = true
                        }

                        let callSize = (Double(line.components(separatedBy: "with ").last ?? "0") ?? 0) * multiplier
                        if isFirstAction {
                            print("\(player.name ?? "unknown"): bets \(String(format: "$%.02f", callSize))")
                            uncalledBet = callSize
                            currentBet = callSize
                            isFirstAction = false
                        } else {
                            let uncalledPortionOfBet = callSize - (previousAction[player.id ?? "error"] ?? 0.0)
                            uncalledBet = 0
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
                            if self.useEmoji {
                                self.seats[index].showedHand = handComponents?.map({ (EmojiCard(rawValue: $0)?.emojiFlip.rawValue ?? "error") }).joined(separator: " ") ?? "error"
                            } else {
                                self.seats[index].showedHand = handComponents?.joined(separator: " ") ?? "error"
                            }
                        }
                    }
                    
                    if line.contains("wins") {
                        let winPotSize = (Double(line.components(separatedBy: " wins ").last?.components(separatedBy: " with ").first ?? "0") ?? 0.0) * multiplier
                        let winDescription = line.components(separatedBy: " wins ").last?.components(separatedBy: " with ").last?.components(separatedBy: " (").first ?? "error"
                        let winningHandComponents = line.components(separatedBy: "hand: ").last?.replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")
                        totalPotSize = winPotSize
                        print("*** SHOW DOWN ***")
                        if self.useEmoji {
                            print("\(player.name ?? "Unknown"): shows [\(winningHandComponents?.map({ (EmojiCard(rawValue: $0)?.emojiFlip.rawValue ?? "error") }).joined(separator: " ") ?? "error")] (\(winDescription))")
                        } else {
                            print("\(player.name ?? "Unknown"): shows [\(winningHandComponents?.joined(separator: " ") ?? "error")] (\(winDescription))")
                        }
                        print("\(player.name ?? "Unknown") collected \(String(format: "$%.02f", winPotSize)) from pot")
                        
                        if let index = self.seats.firstIndex(where: { $0.player?.id == player.id }) {
                            if self.useEmoji {
                                self.seats[index].summary = "\(player.name ?? "Unknown") showed [\(winningHandComponents?.map({ (EmojiCard(rawValue: $0)?.emojiFlip.rawValue ?? "error") }).joined(separator: " ") ?? "error")] and won (\(String(format: "$%.02f", winPotSize))) with \(winDescription)"
                            } else {
                                self.seats[index].summary = "\(player.name ?? "Unknown") showed [\(winningHandComponents?.joined(separator: " ") ?? "error")] and won (\(String(format: "$%.02f", winPotSize))) with \(winDescription)"
                            }
                        }
                    }
                    
                    if line.contains("gained") {
                        var gainedPotSize = (Double(line.components(separatedBy: " gained ").last ?? "0") ?? 0) * multiplier
                        
                        if uncalledBet > 0 {
                            print("Uncalled bet (\(String(format: "$%.02f", uncalledBet))) returned to \(player.name ?? "Unknown")")
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
            
            if line.contains("flop") {
                print("*** FLOP *** [\(self.flop?.map({$0.rawValue}).joined(separator: " ") ?? "error")]")
                isFirstAction = true
                uncalledBet = 0
                currentBet = 0
                for player in self.players {
                    previousAction[player.id ?? "error"] = 0
                }
                streetDescription = "on the Flop"
            }

            if line.contains("turn") {
                print("*** TURN *** [\(self.flop?.map({$0.rawValue}).joined(separator: " ") ?? "error")] [\(self.turn?.rawValue ?? "error")]")
                isFirstAction = true
                uncalledBet = 0
                currentBet = 0                
                for player in self.players {
                    previousAction[player.id ?? "error"] = 0
                }
                streetDescription = "on the Turn"
            }

            if line.contains("river") {
                print("*** RIVER *** [\(self.flop?.map({$0.rawValue}).joined(separator: " ") ?? "error") \(self.turn?.rawValue ?? "error")] [\(self.river?.rawValue ?? "error")]")
                isFirstAction = true
                uncalledBet = 0
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
                var currentIndex = self.seats.firstIndex(where: {$0.player?.name == heroName}) ?? 1
                for seatIndex in 1...(self.seats.count) {
                    let seat = self.seats[currentIndex]

                    var summary = seat.summary
                    if self.dealer?.id == seat.player?.id {
                        summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (button)")
                    }

                    if self.smallBlind?.id == seat.player?.id {
                        summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (small blind)")
                    }

                    for smallBlind in self.missingSmallBlinds {
                        if smallBlind.id == seat.player?.id {
                            summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (missing small blind)")
                        }
                    }
                    for bigBlind in self.bigBlind {
                        if bigBlind.id == seat.player?.id {
                            summary = summary.replacingOccurrences(of: seat.player?.name ?? "Unknown", with: "\(seat.player?.name ?? "Unknown") (big blind)")
                        }
                    }
                    if seat.showedHand != nil {
                        print("Seat \(seatIndex): \(summary) [\(seat.showedHand ?? "error")]")
                    } else {
                        print("Seat \(seatIndex): \(summary)")
                    }

                    currentIndex = currentIndex + 1
                    if currentIndex == self.seats.count {
                        currentIndex = 0
                    }
                }
            }
        }

        
    }
}
