//
//  Card.swift
//  PNReplay
//
//  Created by PJ Gray on 5/27/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Foundation

enum EmojiCard : String {
    case c2 = "2♣"
    case c3 = "3♣"
    case c4 = "4♣"
    case c5 = "5♣"
    case c6 = "6♣"
    case c7 = "7♣"
    case c8 = "8♣"
    case c9 = "9♣"
    case cT = "10♣"
    case cJ = "J♣"
    case cQ = "Q♣"
    case cK = "K♣"
    case cA = "A♣"

    case d2 = "2♦"
    case d3 = "3♦"
    case d4 = "4♦"
    case d5 = "5♦"
    case d6 = "6♦"
    case d7 = "7♦"
    case d8 = "8♦"
    case d9 = "9♦"
    case dT = "10♦"
    case dJ = "J♦"
    case dQ = "Q♦"
    case dK = "K♦"
    case dA = "A♦"

    case h2 = "2♥"
    case h3 = "3♥"
    case h4 = "4♥"
    case h5 = "5♥"
    case h6 = "6♥"
    case h7 = "7♥"
    case h8 = "8♥"
    case h9 = "9♥"
    case hT = "10♥"
    case hJ = "J♥"
    case hQ = "Q♥"
    case hK = "K♥"
    case hA = "A♥"

    case s2 = "2♠"
    case s3 = "3♠"
    case s4 = "4♠"
    case s5 = "5♠"
    case s6 = "6♠"
    case s7 = "7♠"
    case s8 = "8♠"
    case s9 = "9♠"
    case sT = "10♠"
    case sJ = "J♠"
    case sQ = "Q♠"
    case sK = "K♠"
    case sA = "A♠"
    case error
    
    var emojiFlip: Card {
        switch self {
            case .c2: return Card.c2
            case .c3: return Card.c3
            case .c4: return Card.c4
            case .c5: return Card.c5
            case .c6: return Card.c6
            case .c7: return Card.c7
            case .c8: return Card.c8
            case .c9: return Card.c9
            case .cT: return Card.cT
            case .cJ: return Card.cJ
            case .cQ: return Card.cQ
            case .cK: return Card.cK
            case .cA: return Card.cA

            case .d2: return Card.d2
            case .d3: return Card.d3
            case .d4: return Card.d4
            case .d5: return Card.d5
            case .d6: return Card.d6
            case .d7: return Card.d7
            case .d8: return Card.d8
            case .d9: return Card.d9
            case .dT: return Card.dT
            case .dJ: return Card.dJ
            case .dQ: return Card.dQ
            case .dK: return Card.dK
            case .dA: return Card.dA

            case .h2: return Card.h2
            case .h3: return Card.h3
            case .h4: return Card.h4
            case .h5: return Card.h5
            case .h6: return Card.h6
            case .h7: return Card.h7
            case .h8: return Card.h8
            case .h9: return Card.h9
            case .hT: return Card.hT
            case .hJ: return Card.hJ
            case .hQ: return Card.hQ
            case .hK: return Card.hK
            case .hA: return Card.hA
            
            case .s2: return Card.s2
            case .s3: return Card.s3
            case .s4: return Card.s4
            case .s5: return Card.s5
            case .s6: return Card.s6
            case .s7: return Card.s7
            case .s8: return Card.s8
            case .s9: return Card.s9
            case .sT: return Card.sT
            case .sJ: return Card.sJ
            case .sQ: return Card.sQ
            case .sK: return Card.sK
            case .sA: return Card.sA
            case .error: return Card.error
        }
    }

}


enum Card : String {
    case c2 = "2c"
    case c3 = "3c"
    case c4 = "4c"
    case c5 = "5c"
    case c6 = "6c"
    case c7 = "7c"
    case c8 = "8c"
    case c9 = "9c"
    case cT = "Tc"
    case cJ = "Jc"
    case cQ = "Qc"
    case cK = "Kc"
    case cA = "Ac"

    case d2 = "2d"
    case d3 = "3d"
    case d4 = "4d"
    case d5 = "5d"
    case d6 = "6d"
    case d7 = "7d"
    case d8 = "8d"
    case d9 = "9d"
    case dT = "Td"
    case dJ = "Jd"
    case dQ = "Qd"
    case dK = "Kd"
    case dA = "Ad"

    case h2 = "2h"
    case h3 = "3h"
    case h4 = "4h"
    case h5 = "5h"
    case h6 = "6h"
    case h7 = "7h"
    case h8 = "8h"
    case h9 = "9h"
    case hT = "Th"
    case hJ = "Jh"
    case hQ = "Qh"
    case hK = "Kh"
    case hA = "Ah"

    case s2 = "2s"
    case s3 = "3s"
    case s4 = "4s"
    case s5 = "5s"
    case s6 = "6s"
    case s7 = "7s"
    case s8 = "8s"
    case s9 = "9s"
    case sT = "Ts"
    case sJ = "Js"
    case sQ = "Qs"
    case sK = "Ks"
    case sA = "As"
    case error
}
