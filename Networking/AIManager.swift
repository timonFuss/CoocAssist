//
//  AIManager.swift
//  Flavr
//
//  Created by Timon Fuß on 18.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AIManager {
    
    var ai: AI? = nil
    var aiDictionary: NSDictionary
    
    required init(aiDictionary: NSDictionary) {
        self.aiDictionary = aiDictionary
    }
    
    /**
     Serialize NLP Response.
     - Returns: AI-Object
     */
    func serialize() -> AI? {
        
        let json = JSON(self.aiDictionary)
        var id: String? = nil
        var lang: String? = nil
        var score: Double = 0
        
        //print(json)
                
        //ID
        if let value = json["id"].string {
            id = value
        }
        
        //Language
        if let value = json["lang"].string {
            lang = value
        }
        
        
        if id == nil && lang == nil {
            //id or lang is nil for ai Dictionary
            print("id or created is nil for AI Dictionary")
            return nil
        } else {
            //result
            if let result = json["result"].dictionary {
                
                
                //Score
                if let value = result["score"]?.double {
                    score = value
                }
                
                ai = AI(id: id!, lang: lang!, score: score)
                
                //action
                if let value = result["metadata"]?.dictionary {
                    if let intentName = value["intentName"]?.string {
                        ai!.intent = Intent(intentName: intentName)
                    }
                    
                    //fulfillment
                    if let fulfillment = result["fulfillment"]?.dictionary {
                        if let speech = fulfillment["speech"]?.string {
                            ai!.intent.speech = speech
                        }
                    }
                }
                var extraParameters = NSMutableDictionary()
                if let parameters = result["parameters"]?.dictionary , !result.isEmpty {
                    if let timerName = parameters["TimerName"]?.stringValue {
                        extraParameters["TimerName"] = timerName
                    }
                    if let duration = parameters["duration"]?.dictionary{
                        if let timerDuration = duration["amount"]?.int {
                            extraParameters["TimerDuration"] = timerDuration
                        }
                    }
                    if let portions = parameters["number"]?.intValue {
                        extraParameters["Portions"] = portions
                    }
                    if let ingredient = parameters["Ingredient"]?.stringValue {
                        extraParameters["Ingredient"] = ingredient
                    }
                }
                
                ai?.intent.setExtraParams(extraParameters)
                //print("EXTRA: \(ai?.intent.extraParams)")
                
                var array: [String:contextStatus]! = [:]
                var contextArray: [NSMutableDictionary] = []
                //contexts
                if let contextsArr = result["contexts"]?.array {
                    //Read all contexts that were send by NLP
                    for context in contextsArr {
                        //context
                        var contextDict = NSMutableDictionary()
                        if let value = context["name"].string {
                            contextDict["name"] = value
                            
                            
                            if let lifespan =  context["lifespan"].int {
                                contextDict["lifespan"] = lifespan
                                if lifespan == 1 {
                                    array[value] = contextStatus.inactive
                                }else {
                                    array[value] = contextStatus.active
                                    ai?.intent.context[value] = contextStatus.active
                                }
                            }
                            
                            let paramDict = NSMutableDictionary()
                            //contextParameters
                            if let parameters = context["parameters"].dictionary , !result.isEmpty {
                                if let timerName = parameters["TimerName.original"]?.stringValue {
                                    paramDict["TimerName"] = timerName
                                }
                                if let duration = parameters["duration"]?.dictionary{
                                    if let timerDuration = duration["amount"]?.int {
                                        paramDict["TimerDuration"] = timerDuration
                                    }
                                }
                                if let portions = parameters["number"]?.intValue {
                                    paramDict["Portions"] = portions
                                }
                            }
                            contextDict["parameters"] = paramDict
                            
                            
                        }
                        contextArray.append(contextDict)
                        ai?.intent.setParametes(contextArray)
                    }
                }
            }
        }
        return ai
    }
}
