//
//  Player.swift
//  PNReplay
//
//  Created by PJ Gray on 5/25/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Foundation

struct Player {
    var creator: Bool = false
    var admin: Bool?
    var sitting: Bool = true
    
    // this is unfortunate -- basically it is the small blind
    var existingPotEquity: Int = 0
    
    var id: String?
    var stack: Int = 0
    var name: String?
}
