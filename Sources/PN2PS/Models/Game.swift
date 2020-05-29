//
//  Game.swift
//  PNReplay
//
//  Created by PJ Gray on 5/25/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Foundation
import SwiftCSV


class Game: NSObject {

    var useEmoji: Bool = false
    var debugHandAction: Bool = false
    var showErrors: Bool = false
    
    var players: [Player] = []
    var hands: [Hand] = []
    var currentHand: Hand?

    init(filename: String, useEmoji: Bool = false) {
        super.init()
        
        self.useEmoji = useEmoji
        
        do {
            let csvFile: CSV = try CSV(url: URL(fileURLWithPath: filename))
            var msgKey = "entry"
            if csvFile.namedColumns.keys.contains("msg") ?? false {
                msgKey = "msg"
            }
            for row in (csvFile.namedRows ?? []).reversed() {
                if row[msgKey]?.starts(with: "The player ") ?? false {
                    self.parsePlayerLine(msg: row[msgKey])
                } else if row[msgKey]?.starts(with: "The admin ") ?? false {
                    self.parseAdminLine(msg: row[msgKey])
                } else {
                    self.parseHandLine(msg: row[msgKey], at: row["at"], order: row["order"])
                }
                
            }
        } catch let parseError as CSVParseError {
            print(parseError)
        } catch {
            // Catch errors from trying to load files
        }
    }
    
    private func resetSmallBlind() {
        // reset previous calls
        var players : [Player] = []
        for var player in self.players {
            player.existingPotEquity = 0
            players.append(player)
        }
        self.players = players
    }
    
    private func parseHandLine(msg: String?, at: String?, order: String? ) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: at ?? "")
        
        if msg?.starts(with: "-- starting hand ") ?? false {
            self.resetSmallBlind()

            let startingHandComponents = msg?.components(separatedBy: " (dealer: \"")
            let handId = Int(order ?? "???") ?? 0//Int(startingHandComponents?.first?.replacingOccurrences(of: "-- starting hand #", with: "") ?? "0") ?? 0
            let dealerNameIdArray = startingHandComponents?.last?.replacingOccurrences(of: "\") --", with: "").components(separatedBy: " @ ")
            if let dealer = self.players.filter({$0.id == dealerNameIdArray?.last}).first {
                let hand = Hand()
                hand.id = handId
                hand.date = date
                hand.useEmoji = self.useEmoji
                hand.dealer = dealer
                hand.players = self.players.filter({$0.sitting == true})
                self.currentHand = hand
                self.hands.append(hand)
            } else if msg?.contains("dead button") ?? false {
                let hand = Hand()
                hand.date = date
                hand.useEmoji = self.useEmoji
                hand.id = handId
                hand.dealer = nil
                hand.players = self.players.filter({$0.sitting == true})
                self.currentHand = hand
                self.hands.append(hand)
            } else {
                print(self.players)
                if self.showErrors {
                    print("ERROR: Dealer not found: \(dealerNameIdArray ?? [])")
                }
            }
        } else if msg?.starts(with: "-- ending hand ") ?? false {
            self.currentHand?.lines.append(msg ?? "unknown line")

            self.currentHand = nil
            if debugHandAction {
                print("----")
            }
        } else if msg?.starts(with: "Your hand is ") ?? false {
            self.currentHand?.hole = msg?.replacingOccurrences(of: "Your hand is ", with: "").components(separatedBy: ", ").map({
                if self.useEmoji {
                    return EmojiCard(rawValue: $0)?.emojiFlip ?? .error
                } else {
                    return Card(rawValue: $0) ?? .error
                }
            })

            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - hole cards: \(self.currentHand?.hole?.map({$0.rawValue}) ?? [])")
            }
        } else if msg?.starts(with: "flop") ?? false {
            self.resetSmallBlind()
            self.currentHand?.uncalledBet = 0

            let line = msg?.slice(from: "[", to: "]")
            self.currentHand?.flop = line?.replacingOccurrences(of: "flop: ", with: "").components(separatedBy: ", ").map({
                if self.useEmoji {
                    return EmojiCard(rawValue: $0)?.emojiFlip ?? .error
                } else {
                    return Card(rawValue: $0) ?? .error
                }
            })
            
            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - flop: \(self.currentHand?.flop?.map({$0.rawValue}) ?? [])")
            }

        } else if msg?.starts(with: "turn") ?? false {
            self.currentHand?.uncalledBet = 0

            let line = msg?.slice(from: "[", to: "]")
            if self.useEmoji {
                self.currentHand?.turn = EmojiCard(rawValue: line?.replacingOccurrences(of: "turn: ", with: "") ?? "error")?.emojiFlip ?? .error
            } else {
                self.currentHand?.turn = Card(rawValue: line?.replacingOccurrences(of: "turn: ", with: "") ?? "error")
            }
            
            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - turn: \(self.currentHand?.turn?.rawValue ?? "?")")
            }

        } else if msg?.starts(with: "river") ?? false {
            self.currentHand?.uncalledBet = 0

            let line = msg?.slice(from: "[", to: "]")
            if self.useEmoji {
                self.currentHand?.river = EmojiCard(rawValue: line?.replacingOccurrences(of: "river: ", with: "") ?? "error")?.emojiFlip ?? .error
            } else {
                self.currentHand?.river = Card(rawValue: line?.replacingOccurrences(of: "river: ", with: "") ?? "error")
            }

            if debugHandAction {
                print("#\(self.currentHand?.id ?? 0) - river: \(self.currentHand?.river?.rawValue ?? "?")")
            }

        } else {
            let nameIdArray = msg?.components(separatedBy: "\" ").first?.components(separatedBy: " @ ")
            if var player = self.players.filter({$0.id == nameIdArray?.last}).first {
                self.players.removeAll(where: {$0.id == nameIdArray?.last})
                
                if msg?.contains("big blind") ?? false {
                    let bigBlindSize = Int(msg?.components(separatedBy: "big blind of ").last ?? "0") ?? 0
                    self.currentHand?.bigBlindSize = bigBlindSize
                    self.currentHand?.pot = (self.currentHand?.pot ?? 0) + bigBlindSize
                    self.currentHand?.uncalledBet = bigBlindSize
                    self.currentHand?.bigBlind.append(player)

                    if (!(self.currentHand?.seats.contains(where: {$0.player?.id == player.id}) ?? false)) {
                        self.currentHand?.seats.append(Seat(player: player, summary: "\(player.name ?? "Unknown") didn't show and lost", preFlopBet: false))
                    }

                    player.stack = player.stack - bigBlindSize
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") posts big \(bigBlindSize)  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }

                if msg?.contains("small blind") ?? false {
                    let smallBlindSize = Int(msg?.components(separatedBy: "small blind of ").last ?? "0") ?? 0
                    self.currentHand?.smallBlindSize = smallBlindSize
                    self.currentHand?.smallBlind = player
                    player.stack = player.stack - smallBlindSize
                    player.existingPotEquity = smallBlindSize
                    
                    if (!(self.currentHand?.seats.contains(where: {$0.player?.id == player.id}) ?? false)) {
                        self.currentHand?.seats.append(Seat(player: player, summary: "\(player.name ?? "Unknown") didn't show and lost", preFlopBet: false))
                    }

                    self.currentHand?.pot = (self.currentHand?.pot ?? 0) + smallBlindSize
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") posts small \(smallBlindSize)  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }
                
                if msg?.contains("raises") ?? false {
                    let raiseSize = Int(msg?.components(separatedBy: "with ").last ?? "0") ?? 0
                    player.stack = player.stack - raiseSize - player.existingPotEquity
                    self.currentHand?.pot = (self.currentHand?.pot ?? 0) + raiseSize - player.existingPotEquity
                    self.currentHand?.uncalledBet = raiseSize - (self.currentHand?.uncalledBet ?? 0)

                    if (self.currentHand?.flop == nil) && !(self.currentHand?.seats.contains(where: {$0.player?.id == player.id}) ?? false) {
                        self.currentHand?.seats.append(Seat(player: player, summary: "\(player.name ?? "Unknown") didn't show and lost", preFlopBet: false))
                    }

                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") raises \(raiseSize)  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }

                if msg?.contains("calls") ?? false {
                    let callSize = Int(msg?.components(separatedBy: "with ").last ?? "0") ?? 0
                    player.stack = player.stack - callSize - player.existingPotEquity
                    self.currentHand?.pot = (self.currentHand?.pot ?? 0) + callSize - player.existingPotEquity
                    if (self.currentHand?.uncalledBet ?? 0) == 0 {
                        self.currentHand?.uncalledBet = callSize
                    }

                    if (self.currentHand?.flop == nil) && !(self.currentHand?.seats.contains(where: {$0.player?.id == player.id}) ?? false) {
                        self.currentHand?.seats.append(Seat(player: player, summary: "\(player.name ?? "Unknown") didn't show and lost", preFlopBet: false))
                    }

                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") calls \(callSize)  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }
                
                // hand 5 --- folded around - error
                if msg?.contains("gained") ?? false {
                    let gainedPotSize = Int(msg?.components(separatedBy: " gained ").last ?? "0") ?? 0
                    if (gainedPotSize + (self.currentHand?.uncalledBet ?? 0)) != (self.currentHand?.pot) {
                        if debugHandAction {
                            print("ERROR:  error in gained pot size.   Expected: \(self.currentHand?.pot ?? 0)   Got: \((gainedPotSize + (self.currentHand?.uncalledBet ?? 0)))")
                        }
                    }

                    player.stack = player.stack + (gainedPotSize + (self.currentHand?.uncalledBet ?? 0))
                    
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") wins pot of \((gainedPotSize + (self.currentHand?.uncalledBet ?? 0)))  without showdown. (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }

                if msg?.contains("wins") ?? false {
                    let winPotSize = Int(msg?.components(separatedBy: " wins ").last?.components(separatedBy: " with ").first ?? "0") ?? 0
                    player.stack = player.stack + winPotSize
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") wins pot of \(winPotSize)  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }
                
                if msg?.contains("checks") ?? false {
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") checks  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }

                if msg?.contains("folds") ?? false {
                    if (self.currentHand?.flop == nil) && !(self.currentHand?.seats.contains(where: {$0.player?.id == player.id}) ?? false) {
                        self.currentHand?.seats.append(Seat(player: player, summary: "\(player.name ?? "Unknown") didn't show and lost", preFlopBet: false))
                    }
                    if debugHandAction {
                        print("#\(self.currentHand?.id ?? 0) - \(player.name ?? "Unknown Player") folds  (Stack: \(player.stack) Pot: \(self.currentHand?.pot ?? 0))")
                    }
                }

                self.players.append(player)
            }
        }
        self.currentHand?.lines.append(msg ?? "unknown line")
    }
    
    private func parseAdminLine(msg: String?) {
        
        if msg?.contains("approved") ?? false {
            let nameIdArray = msg?.replacingOccurrences(of: "The admin approved the player \"", with: "").split(separator: "\"").first?.components(separatedBy: " @ ")
            if self.players.filter({$0.id == nameIdArray?.last}).count != 1 {
                let startingStackSize = Int(msg?.components(separatedBy: "with a stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0") ?? 0
                let player = Player(admin: false, id: nameIdArray?.last, stack: startingStackSize, name: nameIdArray?.first)
                self.players.append(player)
            } else {
                // approval of player already in game?  error case?
                if var player = self.players.filter({$0.id == nameIdArray?.last}).first {
                    self.players.removeAll(where: {$0.id == nameIdArray?.last})
                    player.sitting = true
                    let startingStackSize = Int(msg?.components(separatedBy: "with a stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0") ?? 0
                    player.stack = startingStackSize

                    self.players.append(player)
                }
            }
        } else if msg?.contains("updated") ?? false {
            let nameIdArray = msg?.replacingOccurrences(of: "The admin updated the player \"", with: "").split(separator: "\"").first?.components(separatedBy: " @ ")

            if var player = self.players.filter({$0.id == nameIdArray?.last}).first {
                self.players.removeAll(where: {$0.id == nameIdArray?.last})
                    
                let stackComponents = msg?.components(separatedBy: "stack from ").last?.replacingOccurrences(of: ".", with: "")
                let currentStackSize = Int(stackComponents?.components(separatedBy: " to ").first ?? "0") ?? 0
                let newStackSize = Int(stackComponents?.components(separatedBy: " to ").last ?? "0") ?? 0
                
                if player.stack != currentStackSize {
                    if self.showErrors {
                        print("ERROR:  \(player.name ?? "Unknown Player") stack size doesn't match.  Expected: \(player.stack)   Got: \(currentStackSize)")
                    }
                }
                
                player.stack = newStackSize

                self.players.append(player)
            }

        }
    }
    
    private func parsePlayerLine(msg: String?) {

        let nameIdArray = msg?.replacingOccurrences(of: "The player \"", with: "").split(separator: "\"").first?.components(separatedBy: " @ ")

        if self.players.filter({$0.id == nameIdArray?.last}).count != 1 {
            let player = Player(admin: false, id: nameIdArray?.last, stack: 0, name: nameIdArray?.first)
            self.players.append(player)
        }

        if var player = self.players.filter({$0.id == nameIdArray?.last}).first {

            self.players.removeAll(where: {$0.id == nameIdArray?.last})
            
            if msg?.contains("quits the game") ?? false {
                let quitStackSize = Int(msg?.components(separatedBy: "with a stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0")
                player.sitting = false
                if player.stack != quitStackSize {
                    if self.showErrors {
                        print("ERROR: \(player.name ?? "Unknown player")  quit stack: \(quitStackSize ?? -1)    current player stack: \(player.stack)")
                    }
                }
            }

            if msg?.contains("created the game with a stack of") ?? false {
                let startingStackSize = Int(msg?.components(separatedBy: "created the game with a stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0")
                player.stack = startingStackSize ?? 0
                player.admin = true
                player.creator = true
            }

            if msg?.contains("joined the game with a stack of") ?? false {
                let startingStackSize = Int(msg?.components(separatedBy: "joined the game with a stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0")
                player.stack = startingStackSize ?? 0
            }

            if msg?.contains("stand up") ?? false {
                let standStackSize = Int(msg?.components(separatedBy: "with the stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0")
                player.sitting = false
                if player.stack != standStackSize {
                    if self.showErrors {
                        print("ERROR: \(player.name ?? "Unknown player")  stand stack: \(standStackSize ?? -1)    current player stack: \(player.stack)")
                    }
                }
            }

            if msg?.contains("sit back with the stack of") ?? false {
                let sitBackStackSize = Int(msg?.components(separatedBy: "sit back with the stack of ").last?.replacingOccurrences(of: ".", with: "") ?? "0")
                player.stack = sitBackStackSize ?? 0
                player.sitting = true
            }

            if msg?.contains("passed the room ownership to") ?? false {
                let newAdmin = msg?.components(separatedBy: "passed the room ownership to ").last?.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ".", with: "")
                
                let newAdminNameIdArray = newAdmin?.components(separatedBy: " @ ")
        
                if var newAdminPlayer = self.players.filter({$0.id == newAdminNameIdArray?.last}).first {
                    player.admin = false
                    newAdminPlayer.admin = true
                } else {
                    if self.showErrors {
                        print("ERROR: could not find player to make admin: \(newAdminNameIdArray?.last ?? "")")
                    }
                }
            }

            self.players.append(player)

        } else {
            if self.showErrors {
                print("ERROR: could not find player: \(nameIdArray?.last ?? "")")
            }
        }
    }
}
