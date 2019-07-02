//
//  DecisionManager.swift
//  Flavr
//
//  Created by Timon Fuß on 21.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

class ResponseHandler {
    /// sharedInstance: the ResponseHandler singleton
    public static let sharedInstance = ResponseHandler()
    
    func makeDecision(ai: AI){
        let intent = ai.intent.intentName
        let array = intent.components(separatedBy: ".")
        
        if intent == "default.fallback.intent" && InformationState.sharedInstance.testedInactiveContexts == false {
            RequestHandler.sharedInstance.resendRequest(msg: ai.intent.speech ?? "", ai: ai)
            InformationState.sharedInstance.testedInactiveContexts = true
        }else{
            let action = Action(name: array[1])
            InformationState.sharedInstance.testedInactiveContexts = false
            InformationState.sharedInstance.saveData(ai: ai)
            InstructionManager.sharedInstance.handleInstruction(action: action, ai:ai)
        }
    }
}
