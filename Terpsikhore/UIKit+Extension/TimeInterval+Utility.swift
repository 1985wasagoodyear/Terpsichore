//
//  TimeInterval+Utility.swift
//  Created 3/15/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation

extension TimeInterval {
    var string: String {
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int((self / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(self / 3600)
        return String(format: "%02d:%02d:%02d",
                      min(hours, 99),
                      minutes,
                      seconds)
    }
}
