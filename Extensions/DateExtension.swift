//
//  DateExtension.swift
//  Flavr
//
//  Created by Timon Fuß on 18.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_569_800) * 10_000_000)
    }
}
