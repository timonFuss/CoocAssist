//
//  Intent.swift
//  Flavr
//
//  Created by Timon Fuß on 18.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import UIKit
import PromiseKit

class Intent {
    
    var intentName: String
    var parameters: [NSMutableDictionary] = []
    var extraParams =  NSMutableDictionary()
    var context: [String: contextStatus] = [:]
    var speech : String?
    var dates : [Date]?
    
    init(intentName: String) {
        self.intentName = intentName
    }
    
    /**
     Sets Parameters for Intent Object.
     - Parameter parameters: Dictionary containing context, speech...
     */
    func setParametes(_ parameters: [NSMutableDictionary]) {
        self.parameters = parameters
        //dates = getDate(parameters)
    }
    
    func setExtraParams(_ extraParams: NSMutableDictionary){
        self.extraParams = extraParams
    }
    
    func getDate(_ parameters: NSDictionary) -> [Date]? {
        if let date = parameters["date-time"] as? String {
            var dates = [Date]()
            let datesString = date.split(separator: "/")
            for dateString in datesString {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let dateObj = dateFormatter.date(from: String(dateString)) else {
                    return nil
                }
                dates.append(dateObj)
                
            }
            return dates
        } else {
            return nil
        }
    }
    
}

