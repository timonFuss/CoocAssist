//
//  AI.swift
//  Flavr
//
//  Created by Timon Fuß on 18.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit

class AI {
    
    var id: String
    var lang: String
    var score: Double
    var intent: Intent
    
    required init(id: String, lang: String, score: Double) {
        self.id = id
        self.lang = lang
        self.score = score
        self.intent = Intent(intentName: "")
    }
    
}
