//
//  Timer.swift
//  Flavr
//
//  Created by Timon Fuß on 23.03.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

class Time: TimeModule {
    override init(name: String, time: Int, finish : String, index : Int?=nil) {
        super.init(name: name, time: time, finish: finish, index: index)
        self.time = time
    }
    
    /**
     Setting time of Timer
     */
    func setTimeTo(time: Int) {
        self.time = time
        self.timer.invalidate()
        self.start(withTime: self.time)
    }
    
}
