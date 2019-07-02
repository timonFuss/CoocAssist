//
//  TimeModule.swift
//  Flavr
//
//  Created by Timon Fuß on 23.03.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation
import UIKit

class TimeModule: Module {
    var infoState = InformationState.sharedInstance
    var moduleType: ModuleTypes
    var identifier: String
    var initTime: Int = 30
    var time : Int = 30
    var timer = Timer()
    var finishMessage : String!
    var index : Int?
    
    var name:String {
        get {
            return identifier
        }
        set {
            identifier = newValue
        }
    }
    
    init(name: String, time: Int, finish : String, index: Int?=nil) {
        self.time = time
        self.initTime = time
        self.identifier = name
        self.finishMessage = finish
        self.index = index
        self.moduleType = ModuleTypes.Time
    }
    
    /**
     Starting a Module
     */
    func start() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTime), userInfo: nil, repeats: true)
    }
    
    /**
     Staring a TimeModule
     - Parameter withTime: Time that indicates duration of timer.
     */
    func start(withTime: Int) {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTime), userInfo: nil, repeats: true)
    }
    
    /**
     Stopping a Module and sends Notification
     */
    func stop() {
        self.timer.invalidate()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finish"), object: self)
    }
    
    /**
     Stopping a Module and sends Notification
     - Returns: Int-Value of remaining Time of Module.
     */
    func getRemainingTime() -> Int {
        return self.time
    }
    
    /**
     Objective-C-function for updating time -> notificates dependent classes
     */
    @objc func handleTime() {
        if self.time > 0 {
            self.time -= 1
        } else {
            self.stop()
        }
        if self.index != nil {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTime"), object: self)
        }
    }
    
    
}
