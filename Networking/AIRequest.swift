//
//  AIRequest.swift
//  Flavr
//
//  Created by Timon Fuß on 18.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import Alamofire

class AIRequest {
    
    var query: String
    var lang: String
    var sessionId: String
    var contexts: [String]?
    
    init(query: String, lang: String) {
        self.query = query
        self.lang = lang
        self.sessionId = "WB-" + Date().ticks.description
    }
    
    /**
     Returns Headers for http-Request.
     - Returns: HTTP-Headers
     */
    func getHeaders() -> HTTPHeaders {
        let clientAccessToken = "YOUR ACCESS TOKEN"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + clientAccessToken,
            ]
        return headers
    }
    
    /**
     sets Parameters for HTTP-Request.
     - Returns: Parameters
     */
    func toParameters() -> Parameters {
        let contexts = InformationState.sharedInstance.getAllActiveContexts()
        
        for context in contexts{
            if context["lifespan"] as! Int == 1 {
                InformationState.sharedInstance.saveAsInactive(context: context)
            }
        }
        
        let parameters: Parameters = [
            "query": query,
            "lang": lang,
            "sessionId": sessionId,
            "contexts": contexts
        ]
        
        return parameters
    }
    
}
