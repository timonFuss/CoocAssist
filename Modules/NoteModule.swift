//
//  NoteModule.swift
//  Flavr
//
//  Created by Timon Fuß on 07.04.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

class NoteModule: Module {
    var identifier: String
    var finishMessage : String!
    var moduleType: ModuleTypes
    
    init(name: String, finish : String) {
        self.identifier = name
        self.finishMessage = finish
        self.moduleType = ModuleTypes.Note
    }
    
    
    func start() {
        SynthesisVoiceManager.sharedInstance.speak(string: self.finishMessage)
    }
    
    func stop() {
        print("STOP")
    }
    
    func getRemainingTime() -> Int {
        return 0
    }
    
    
}
