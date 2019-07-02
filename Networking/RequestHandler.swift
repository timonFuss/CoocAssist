//
//  RequestHandler.swift
//  Flavr
//
//  Created by Timon Fuß on 11.03.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation

import Foundation

class RequestHandler {
    /// sharedInstance: the RequestHandler singleton
    public static let sharedInstance = RequestHandler()
    
    /**
     send Message to NLP.
     - Parameter msg: spoken user interaction
     */
    func newRequest(msg: String) {
        //configure AI Request
        let aiRequest = AIRequest(query: msg, lang: "de")
        let aiService = AIService(aiRequest)
        aiService.getAi()
    }
    
    /**
     resend Message to NLP.
     - Parameter msg: spoken user interaction
     */
    func resendRequest(msg:String, ai: AI){
        ai.intent.setParametes(InformationState.sharedInstance.getAllInactiveContexts())
        
        //configure AI Request
        let aiRequest = AIRequest(query: msg, lang: "de")
        let aiService = AIService(aiRequest)
        aiService.getAi()
    }
    
}
