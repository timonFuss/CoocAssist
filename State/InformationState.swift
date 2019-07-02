//
//  InformationState.swift
//  Flavr
//
//  Created by Timon Fuß on 09.03.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

class InformationState {
    public static let sharedInstance = InformationState()
    
    var contextState = [NSMutableDictionary:contextStatus]()
    var viewState : String = ""
    var userQuery:[Intent] = []
    var systemQuery:[Intent] = []
    var expectedUserQuery : Intent?
    var testedInactiveContexts = false
    
    public func saveData(ai: AI){
        var isSet = false
        for context in ai.intent.parameters {
            for key in contextState.keys {
                if context["name"] as! String == key["name"] as! String {
                    key["lifespan"] = context["lifespan"]
                    isSet = true
                }
            }
            if !isSet{
                contextState[context] = contextStatus.active
            }
            isSet = false
        }
    }
    
    /**
     Getting all active Contexts
     - Returns: Array of all active Contexts
     */
    public func getAllActiveContexts() -> [NSMutableDictionary] {
        let activeContexts = contextState.keysForValue(value: contextStatus.active)
        return activeContexts
    }
    
    /**
     Getting all inactive
     - Returns: Array of all inactive Contexts
     */
    public func getAllInactiveContexts() -> [NSMutableDictionary] {
        let inactiveContexts = contextState.keysForValue(value: contextStatus.inactive)
        return inactiveContexts
    }
    
    public func saveAsInactive(context: NSMutableDictionary) {
        contextState[context] = contextStatus.inactive
    }
    
    /**
     Inserts Ingredients (name, measurment and measurementUnit) to Systemanswer
     - Parameter list: Array of Ingredients.
     - Parameter speech: textform of Systemanswer.
     - Returns: revised Systemanswer
     */
    public func adjustSystemAnswer(list: [Ingredient], speech: String) -> String {
        var ingredientString = ""
        for ingredient in list {
            ingredientString.append(contentsOf: " \(ingredient.measurement) \(ingredient.measurementUnit ?? "") \(ingredient.name ?? ""),")
        }
        return speech.replacingOccurrences(of: "Zutaten", with: ingredientString)
    }
    
    /**
     Inserts Moduleinformation (name, remainingTime) to Systemanswer
     - Parameter forTime: textform of Systemanswer for Module.
     - Parameter module: TimeModule.
     - Returns: revised Systemanswer
     */
    public func adjustSystemAnswer(forTime: String, module: Module) -> String {
        let str1 = forTime.replacingOccurrences(of: "TimerName", with: module.identifier)
        let moduleString = str1.replacingOccurrences(of: "Time", with: "\(module.getRemainingTime())")
        return moduleString
    }
    
    /**
     Inserts Portioninformation (amount) to Systemanswer
     - Parameter forPortions: textform of Systemanswer for Portions.
     - Parameter number: amount of Portions the user selected.
     - Returns: revised Systemanswer
     */
    public func adjustSystemAnswer(forPortions: String, number: Int) -> String {
        let portionString = forPortions.replaceFirst(of: "Anzahl", with: "\(number)")
        return portionString
    }
    
    public func addToUserQuery(intent: Intent) {
        for query in userQuery{
            if query.intentName != intent.intentName {
                userQuery.append(intent)
            }
        }
    }
    
    public func removeFromUserQuery(intent: Intent) {
        
    }
    
    public func addToSystemQuery(intent: Intent) {
        for query in systemQuery{
            if query.intentName != intent.intentName {
                systemQuery.append(intent)
            }
        }
        
    }
    
    public func removeFromSystemQuery(intent: Intent) {
        
    }
    
    public func validateUserToSystemQuery(userIntent: Intent, systemIntent: Intent) {
        
    }
}
