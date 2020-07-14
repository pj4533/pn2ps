//
//  Seat.swift
//  PNReplay
//
//  Created by PJ Gray on 5/28/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Foundation

struct Seat {
    var player: Player?
    var summary: String = ""
    var preFlopBet: Bool = false
    var showedHand: String?
    var stack: Int?
    var number: Int = 0
}
