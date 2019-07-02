//
//  AIService.swift
//  Flavr
//
//  Created by Timon Fuß on 18.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

class AIService {
    
    let aiUrl = URLGenerator.aiApiUrlForPathString(path: "query?v=20150910")
    var aiRequest: AIRequest
    
    init(_ aiRequest: AIRequest) {
        self.aiRequest = aiRequest
    }
    
    /**
     Request to NLP / Response Handling.
     */
    func getAi() {
        let parameters = aiRequest.toParameters()
        let headers = aiRequest.getHeaders()
        //print("REQUEST \(parameters)")
                
        //Alamofire used for Request/Response-Handling
        Alamofire.request(aiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    //Handle Response
                    var ai: AI? = nil
                    let aiManager = AIManager(aiDictionary: responseData.result.value! as! NSDictionary)
                    ai = aiManager.serialize()
                    ResponseHandler.sharedInstance.makeDecision(ai: ai!)
            }
        }
    
    }
        
}
    


