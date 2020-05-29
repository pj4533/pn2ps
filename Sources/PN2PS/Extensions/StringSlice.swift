//
//  StringSlice.swift
//  PNReplay
//
//  Created by PJ Gray on 5/28/20.
//  Copyright © 2020 Say Goodnight Software. All rights reserved.
//

import Foundation

extension String {

    func slice(from: String, to: String) -> String? {

        if self.contains("[") {
            return (range(of: from)?.upperBound).flatMap { substringFrom in
                (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                    String(self[substringFrom..<substringTo])
                }
            }
        } else {
            return self
        }
    }
}
