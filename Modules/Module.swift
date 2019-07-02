//
//  Module.swift
//  Flavr
//
//  Created by Timon Fuß on 23.03.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

protocol Module {
    
    var identifier: String {get}
    var moduleType: ModuleTypes {get}
    
    func start()
    func stop()
    func getRemainingTime() -> Int
}
